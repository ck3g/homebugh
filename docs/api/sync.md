# Sync

> **Status: Implemented**

Bidirectional data synchronization between the iOS app and the server. Handles push (iOS changes to server) and pull (server changes to iOS) in a single request.

For detailed iOS implementation guidance, see the iOS Sync Guide in the project details repository.

## Sync Endpoint

```
POST /api/v1/sync
```

## Request Payload

```json
{
  "last_synced_at": "2026-04-20T12:00:00.000Z",
  "changes": {
    "categories": {
      "created": [
        {
          "client_uuid": "ios-uuid-1",
          "name": "Gym",
          "category_type_id": 2
        }
      ],
      "updated": [
        {
          "id": 42,
          "name": "Groceries",
          "updated_at": "2026-04-27T10:00:00.000Z"
        }
      ],
      "deleted": [
        {"id": 55}
      ]
    },
    "accounts": {
      "created": [...],
      "updated": [...],
      "deleted": [...]
    },
    "transactions": {
      "created": [...],
      "updated": [...],
      "deleted": [...]
    },
    "cash_flows": {
      "created": [...],
      "updated": [...],
      "deleted": [...]
    },
    "budgets": {
      "created": [...],
      "updated": [...],
      "deleted": [...]
    },
    "recurring_payments": {
      "created": [...],
      "updated": [...],
      "deleted": [...]
    },
    "recurring_cash_flows": {
      "created": [...],
      "updated": [...],
      "deleted": [...]
    }
  }
}
```

### Request Fields

| Field | Type | Required | Description |
|---|---|---|---|
| last_synced_at | datetime | no | Timestamp of last successful sync. Null for initial sync (pulls all records). |
| changes | object | no | Push payload. Omit or send empty if only pulling. |

Each resource type in `changes` is optional. Only include types that have changes.

### Created Records

Must include all required fields for the resource plus `client_uuid`:

```json
{
  "client_uuid": "ios-uuid-1",
  "name": "Gym",
  "category_type_id": 2
}
```

The `client_uuid` is used for idempotency — if the server already has a record with the same `client_uuid` for this user, it returns the existing server ID instead of creating a duplicate.

### Updated Records

Must include the server `id`, changed fields, and `updated_at`:

```json
{
  "id": 42,
  "name": "Groceries",
  "updated_at": "2026-04-27T10:00:00.000Z"
}
```

The server compares `updated_at` with its own value. The newer timestamp wins (last-write-wins).

### Deleted Records

Must include the server `id`:

```json
{"id": 55}
```

## Response Payload

```json
{
  "pushed": {
    "categories": {
      "created": [
        {"client_uuid": "ios-uuid-1", "server_id": 89, "status": "ok"}
      ],
      "updated": [
        {"id": 42, "status": "ok"}
      ],
      "deleted": [
        {"id": 55, "status": "ok"}
      ],
      "rejected": [
        {
          "client_uuid": "ios-uuid-2",
          "operation": "create",
          "reason": "Name has already been taken"
        }
      ]
    },
    "accounts": { ... }
  },
  "pull": {
    "categories": [
      {
        "id": 90,
        "name": "Transport",
        "category_type_id": 2,
        "inactive": false,
        "status": "active",
        "client_uuid": null,
        "created_at": "2026-04-25T08:00:00.000Z",
        "updated_at": "2026-04-25T08:00:00.000Z"
      }
    ],
    "accounts": [...],
    "transactions": [...],
    "cash_flows": [...],
    "budgets": [...],
    "recurring_payments": [...],
    "recurring_cash_flows": [...],
    "deletions": [
      {
        "resource_type": "Transaction",
        "resource_id": 60,
        "deleted_at": "2026-04-25T08:00:00.000Z"
      }
    ],
    "has_more": false,
    "cursor": null
  }
}
```

### Response Fields

**`pushed`** — only present if `changes` were sent:
- `created` — server IDs assigned to new records
- `updated` — confirmation of applied updates
- `deleted` — confirmation of applied deletes
- `rejected` — items that failed business rule validation (e.g., can't delete account with balance). Rejections don't block other operations.

**`pull`** — records changed on the server since `last_synced_at`:
- Each resource type contains an array of full record objects
- `deletions` — records deleted on the server since `last_synced_at`
- `has_more` — if true, more data is available
- `cursor` — pass as `last_synced_at` in the next request to continue paging

Pull results are capped at 200 records total across all resource types per response.

## Processing Rules

1. **Push runs first** — pushed records are not echoed back in the pull
2. **Client UUID idempotency** — duplicate `client_uuid` returns existing server ID
3. **Last-write-wins** — updates compared by `updated_at` timestamp
4. **Rejections are per-item** — business rule failures don't block other operations
5. **Hard errors roll back** — database failures roll back the entire chunk
6. **Pull excludes just-pushed records** — avoids echoing back the client's own changes

## Sync Flow

The iOS app sends multiple sync requests to handle dependency ordering:

### Phase 1: Push Parents

Categories and accounts have no dependencies on other user resources. Sync these first.

```
POST /api/v1/sync
{
  "last_synced_at": "2026-04-20T12:00:00.000Z",
  "changes": {
    "categories": { "created": [...], "updated": [...], "deleted": [...] },
    "accounts": { "created": [...], "updated": [...], "deleted": [...] }
  }
}
```

Receive server IDs for created records. Map local IDs to server IDs.

### Phase 2: Push Children

Transactions, cash flows, budgets, recurring payments, and recurring cash flows depend on categories and accounts. Use the server IDs from Phase 1.

```
POST /api/v1/sync
{
  "last_synced_at": "2026-04-20T12:00:00.000Z",
  "changes": {
    "transactions": { "created": [...], "updated": [...], "deleted": [...] },
    "cash_flows": { ... },
    "budgets": { ... },
    "recurring_payments": { ... },
    "recurring_cash_flows": { ... }
  }
}
```

### Phase 3: Pull

After all pushes, page through pull results until `has_more` is false.

```
POST /api/v1/sync
{
  "last_synced_at": "2026-04-15T10:30:00.000Z"
}
```

(No `changes` — pull only. Use the `cursor` from the previous response as `last_synced_at`.)

### Chunking

If any phase has too many records (>50), break into chunks of ~50 records per request. Each chunk is all-or-nothing on the server. Client UUIDs prevent duplicates on retry.

## Initial Sync

When `last_synced_at` is null, the server returns all records paginated. The iOS app pages through using `has_more` + `cursor` until all data is retrieved.

For users with years of data (thousands of transactions), this may require many requests.

## Deletion Tracking

When a record is deleted on the server (via web or API), it is recorded in a `sync_deletions` table. The pull response includes these deletions so the iOS app can remove the corresponding local records.

Deletion records are retained for 90 days. If the iOS app hasn't synced in 90+ days, it should perform a full re-sync (send `last_synced_at` as null).

## Account Balances

The server is authoritative for account balances:
- Push creates: triggers `AccountBalance.apply` (deposit for income, withdrawal for expense)
- Push deletes: triggers `AccountBalance.reverse`
- Pull: returns current `balance` value — iOS should overwrite its local balance
