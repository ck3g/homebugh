# Recurring Cash Flows

> **Status: Not yet implemented**

Templates for automatically creating account transfers on a schedule. Each recurring cash flow defines an amount, source and target accounts, frequency, and next transfer date.

## List Recurring Cash Flows

```
GET /api/v1/recurring_cash_flows
```

**Query Parameters:**

| Param | Type | Default | Description |
|---|---|---|---|
| page | integer | 1 | Page number |
| per_page | integer | 20 | Items per page (max 50) |
| updated_since | datetime | none | Only return records updated after this timestamp |

**Success (200):**
```json
{
  "recurring_cash_flows": [
    {
      "id": 2,
      "amount": 1000.00,
      "from_account_id": 1,
      "to_account_id": 3,
      "frequency": "monthly",
      "frequency_amount": 1,
      "next_transfer_on": "2026-05-01",
      "ends_on": null,
      "client_uuid": null,
      "created_at": "2025-06-01T00:00:00.000Z",
      "updated_at": "2026-04-01T00:00:00.000Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 1,
    "total_count": 1
  }
}
```

## Get Recurring Cash Flow

```
GET /api/v1/recurring_cash_flows/:id
```

**Success (200):** Single recurring cash flow object.

## Create Recurring Cash Flow

```
POST /api/v1/recurring_cash_flows
```

**Request:**
```json
{
  "amount": 1000.00,
  "from_account_id": 1,
  "to_account_id": 3,
  "frequency": "monthly",
  "frequency_amount": 1,
  "next_transfer_on": "2026-05-01",
  "ends_on": null,
  "client_uuid": "ios-bb2e8400-e29b-41d4"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| amount | decimal | yes | Transfer amount (>= 0.01) |
| from_account_id | integer | yes | Source account |
| to_account_id | integer | yes | Target account (must differ from source) |
| frequency | string | yes | `daily`, `weekly`, `monthly`, `yearly` |
| frequency_amount | integer | yes | Interval (>= 1) |
| next_transfer_on | date | yes | Next scheduled date |
| ends_on | date | no | End date (null = indefinite) |
| client_uuid | string | no | iOS-generated UUID for sync idempotency |

**Success (201):** Returns the created recurring cash flow.

## Update Recurring Cash Flow

```
PATCH /api/v1/recurring_cash_flows/:id
```

**Updatable fields:** `amount`, `from_account_id`, `to_account_id`, `frequency`, `frequency_amount`, `next_transfer_on`, `ends_on`

**Success (200):** Returns the updated recurring cash flow.

## Delete Recurring Cash Flow

```
DELETE /api/v1/recurring_cash_flows/:id
```

**Success (200):** `{"status": "ok"}`

## Special Actions

### Move to Next Transfer

Advances `next_transfer_on` to the next occurrence without creating a cash flow.

```
PUT /api/v1/recurring_cash_flows/:id/move_to_next_transfer
```

**Success (200):** Returns the updated recurring cash flow with the new `next_transfer_on`.

### Perform Transfer

Creates a real cash flow from the template and advances the schedule.

```
POST /api/v1/recurring_cash_flows/:id/perform_transfer
```

**Success (201):** Returns the created cash flow.

**Side effects:**
- Creates a cash flow between the two accounts
- Adjusts both account balances
- Advances `next_transfer_on` to the next occurrence
