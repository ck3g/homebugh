# Categories

> **Status: Not yet implemented**

Transaction categories (e.g., "Food", "Salary"). Each category has a type: income (category_type_id=1) or expense (category_type_id=2).

## List Categories

```
GET /api/v1/categories
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
  "categories": [
    {
      "id": 7,
      "name": "Food",
      "category_type_id": 2,
      "inactive": false,
      "status": "active",
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

## Get Category

```
GET /api/v1/categories/:id
```

**Success (200):** Single category object.

**Errors:**
- 404: Not found

## Create Category

```
POST /api/v1/categories
```

**Request:**
```json
{
  "name": "Gym",
  "category_type_id": 2,
  "client_uuid": "ios-662e8400-e29b-41d4"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| name | string | yes | Category name (unique per user) |
| category_type_id | integer | yes | 1 = income, 2 = expense |
| client_uuid | string | no | iOS-generated UUID for sync idempotency |

**Success (201):** Returns the created category.

## Update Category

```
PATCH /api/v1/categories/:id
```

**Updatable fields:** `name`, `inactive`

**Success (200):** Returns the updated category.

## Delete Category

```
DELETE /api/v1/categories/:id
```

**Success (200):** `{"status": "ok"}`

**Notes:**
- Categories are soft-deleted (status changes to "deleted")
- Categories with existing transactions, budgets, or recurring payments cannot be deleted (returns 422)
