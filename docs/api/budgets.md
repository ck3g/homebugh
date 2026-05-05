# Budgets

> **Status: Implemented**

Spending limits per category per currency. The budget tracks a `limit` amount; actual spending is calculated from transactions.

## List Budgets

```
GET /api/v1/budgets
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
  "budgets": [
    {
      "id": 5,
      "category_id": 7,
      "currency_id": 1,
      "limit": 500.00,
      "client_uuid": null,
      "created_at": "2026-01-01T00:00:00.000Z",
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

## Get Budget

```
GET /api/v1/budgets/:id
```

**Success (200):** Single budget object.

## Create Budget

```
POST /api/v1/budgets
```

**Request:**
```json
{
  "category_id": 7,
  "currency_id": 1,
  "limit": 500.00,
  "client_uuid": "ios-992e8400-e29b-41d4"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| category_id | integer | yes | Category to budget |
| currency_id | integer | yes | Currency for this budget |
| limit | decimal | yes | Spending limit (> 0) |
| client_uuid | string | no | iOS-generated UUID for sync idempotency |

**Success (201):** Returns the created budget.

## Update Budget

```
PATCH /api/v1/budgets/:id
```

**Updatable fields:** `limit`, `category_id`, `currency_id`

**Success (200):** Returns the updated budget.

## Delete Budget

```
DELETE /api/v1/budgets/:id
```

**Success (200):** `{"status": "ok"}`
