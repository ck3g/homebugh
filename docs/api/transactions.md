# Transactions

> **Status: Not yet implemented**

Financial transactions. Each transaction records an amount, belongs to an account and a category, and optionally has a comment. Creating/deleting transactions automatically adjusts the account balance.

## List Transactions

```
GET /api/v1/transactions
```

**Query Parameters:**

| Param | Type | Default | Description |
|---|---|---|---|
| page | integer | 1 | Page number |
| per_page | integer | 20 | Items per page (max 50) |
| updated_since | datetime | none | Only return records updated after this timestamp |
| account_id | integer | none | Filter by account |
| category_id | integer | none | Filter by category |

**Success (200):**
```json
{
  "transactions": [
    {
      "id": 101,
      "amount": 50.00,
      "comment": "Lunch at cafe",
      "account_id": 1,
      "category_id": 7,
      "client_uuid": null,
      "created_at": "2026-04-28T12:00:00.000Z",
      "updated_at": "2026-04-28T12:00:00.000Z"
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
- `amount` maps to the `summ` database column
- Ordered by `created_at` descending by default

## Get Transaction

```
GET /api/v1/transactions/:id
```

**Success (200):** Single transaction object.

## Create Transaction

```
POST /api/v1/transactions
```

**Request:**
```json
{
  "amount": 50.00,
  "comment": "Lunch at cafe",
  "account_id": 1,
  "category_id": 7,
  "client_uuid": "ios-772e8400-e29b-41d4"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| amount | decimal | yes | Amount (>= 0.01) |
| account_id | integer | yes | Account to apply to |
| category_id | integer | yes | Category for this transaction |
| comment | string | no | Optional comment |
| client_uuid | string | no | iOS-generated UUID for sync idempotency |

**Success (201):** Returns the created transaction.

**Side effects:**
- If category is income (category_type_id = 1): deposits `amount` into the account
- If category is expense (category_type_id = 2): withdraws `amount` from the account

## Update Transaction

```
PATCH /api/v1/transactions/:id
```

Only the comment can be updated.

**Request:**
```json
{
  "comment": "Updated comment"
}
```

**Updatable fields:** `comment` only

**Success (200):** Returns the updated transaction.

## Delete Transaction

```
DELETE /api/v1/transactions/:id
```

**Success (200):** `{"status": "ok"}`

**Side effects:**
- Reverses the account balance change (undoes the original deposit or withdrawal)
