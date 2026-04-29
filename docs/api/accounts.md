# Accounts

> **Status: Not yet implemented**

Financial accounts (e.g., "Cash", "Bank Card", "Savings"). Each account has a balance and belongs to a currency.

## List Accounts

```
GET /api/v1/accounts
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
  "accounts": [
    {
      "id": 1,
      "name": "Cash",
      "balance": 1500.50,
      "currency_id": 1,
      "status": "active",
      "show_in_summary": true,
      "client_uuid": null,
      "created_at": "2024-01-15T10:00:00.000Z",
      "updated_at": "2026-04-28T14:30:00.000Z"
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

**Notes:**
- `balance` maps to the `funds` database column
- Only returns accounts belonging to the authenticated user

## Get Account

```
GET /api/v1/accounts/:id
```

**Success (200):** Single account object (same shape as list item).

**Errors:**
- 404: Account not found (or belongs to another user)

## Create Account

```
POST /api/v1/accounts
```

**Request:**
```json
{
  "name": "Savings",
  "currency_id": 1,
  "show_in_summary": true,
  "client_uuid": "ios-550e8400-e29b-41d4"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| name | string | yes | Account name (unique per user + currency) |
| currency_id | integer | yes | Currency for this account |
| show_in_summary | boolean | no | Show in dashboard summary (default: true) |
| client_uuid | string | no | iOS-generated UUID for sync idempotency |

**Success (201):** Returns the created account.

**Errors:**
- 422: Validation errors

## Update Account

```
PATCH /api/v1/accounts/:id
```

**Request:**
```json
{
  "name": "Updated Name",
  "show_in_summary": false
}
```

**Updatable fields:** `name`, `show_in_summary`

**Success (200):** Returns the updated account.

**Errors:**
- 404: Not found
- 422: Validation errors

## Delete Account

```
DELETE /api/v1/accounts/:id
```

**Success (200):**
```json
{"status": "ok"}
```

**Errors:**
- 404: Not found
- 422: Business rule violation

```json
{"error": "Account cannot be deleted", "details": {"balance": ["must be zero to delete"]}}
```

**Notes:**
- Accounts are soft-deleted (status changes to "deleted")
- Account balance must be zero to delete
