# Cash Flows

> **Status: Implemented**

Transfers between two accounts. Supports cross-currency transfers via the `initial_amount` field.

## List Cash Flows

```
GET /api/v1/cash_flows
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
  "cash_flows": [
    {
      "id": 10,
      "amount": 500.00,
      "initial_amount": 550.00,
      "from_account_id": 1,
      "to_account_id": 2,
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
- `initial_amount` supports cross-currency transfers: `initial_amount` is withdrawn from the source account, `amount` is deposited into the target
- If `initial_amount` is null, `amount` is used for both

## Get Cash Flow

```
GET /api/v1/cash_flows/:id
```

**Success (200):** Single cash flow object.

## Create Cash Flow

```
POST /api/v1/cash_flows
```

**Request:**
```json
{
  "amount": 500.00,
  "initial_amount": 550.00,
  "from_account_id": 1,
  "to_account_id": 2,
  "client_uuid": "ios-882e8400-e29b-41d4"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| amount | decimal | yes | Amount deposited into target (>= 0.01) |
| from_account_id | integer | yes | Source account |
| to_account_id | integer | yes | Target account (must differ from source) |
| initial_amount | decimal | no | Amount withdrawn from source (>= 0.01, defaults to `amount`) |
| client_uuid | string | no | iOS-generated UUID for sync idempotency |

**Success (201):** Returns the created cash flow.

**Side effects:**
- Withdraws `initial_amount` (or `amount` if not specified) from source account
- Deposits `amount` into target account

## Delete Cash Flow

```
DELETE /api/v1/cash_flows/:id
```

**Success (200):** `{"status": "ok"}`

**Side effects:**
- Reverses the balance changes on both accounts
