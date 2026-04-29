# Recurring Payments

> **Status: Not yet implemented**

Templates for automatically creating transactions on a schedule. Each recurring payment defines an amount, account, category, frequency, and next payment date.

## List Recurring Payments

```
GET /api/v1/recurring_payments
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
  "recurring_payments": [
    {
      "id": 3,
      "title": "Netflix",
      "amount": 15.99,
      "account_id": 1,
      "category_id": 12,
      "frequency": "monthly",
      "frequency_amount": 1,
      "next_payment_on": "2026-05-01",
      "ends_on": null,
      "client_uuid": null,
      "created_at": "2025-01-01T00:00:00.000Z",
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

**Notes:**
- `frequency` values: `daily`, `weekly`, `monthly`, `yearly`
- `frequency_amount` is the interval (e.g., frequency=monthly, frequency_amount=2 means every 2 months)
- `ends_on` is null for payments that repeat indefinitely

## Get Recurring Payment

```
GET /api/v1/recurring_payments/:id
```

**Success (200):** Single recurring payment object.

## Create Recurring Payment

```
POST /api/v1/recurring_payments
```

**Request:**
```json
{
  "title": "Netflix",
  "amount": 15.99,
  "account_id": 1,
  "category_id": 12,
  "frequency": "monthly",
  "frequency_amount": 1,
  "next_payment_on": "2026-05-01",
  "ends_on": null,
  "client_uuid": "ios-aa2e8400-e29b-41d4"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| title | string | yes | Payment title |
| amount | decimal | yes | Amount (>= 0.01) |
| account_id | integer | yes | Account to charge |
| category_id | integer | yes | Category for created transactions |
| frequency | string | yes | `daily`, `weekly`, `monthly`, `yearly` |
| frequency_amount | integer | yes | Interval (>= 1) |
| next_payment_on | date | yes | Next scheduled date |
| ends_on | date | no | End date (null = indefinite) |
| client_uuid | string | no | iOS-generated UUID for sync idempotency |

**Success (201):** Returns the created recurring payment.

## Update Recurring Payment

```
PATCH /api/v1/recurring_payments/:id
```

**Updatable fields:** `title`, `amount`, `account_id`, `category_id`, `frequency`, `frequency_amount`, `next_payment_on`, `ends_on`

**Success (200):** Returns the updated recurring payment.

## Delete Recurring Payment

```
DELETE /api/v1/recurring_payments/:id
```

**Success (200):** `{"status": "ok"}`

## Special Actions

### Move to Next Payment

Advances `next_payment_on` to the next occurrence without creating a transaction.

```
PUT /api/v1/recurring_payments/:id/move_to_next_payment
```

**Success (200):** Returns the updated recurring payment with the new `next_payment_on`.

### Create Transaction

Creates a real transaction from the recurring payment template and advances the schedule.

```
POST /api/v1/recurring_payments/:id/create_transaction
```

**Success (201):** Returns the created transaction.

**Side effects:**
- Creates a transaction in the linked account and category
- Adjusts account balance via `AccountBalance.apply`
- Advances `next_payment_on` to the next occurrence
