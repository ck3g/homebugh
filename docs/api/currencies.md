# Currencies

> **Status: Not yet implemented**

Read-only. Currencies available in the system (e.g., "US Dollar", "Euro"). Used by accounts and budgets.

## List Currencies

```
GET /api/v1/currencies
```

**Query Parameters:**

| Param | Type | Default | Description |
|---|---|---|---|
| page | integer | 1 | Page number |
| per_page | integer | 20 | Items per page (max 50) |

**Success (200):**
```json
{
  "currencies": [
    {
      "id": 1,
      "name": "US Dollar",
      "unit": "$",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z"
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

## Get Currency

```
GET /api/v1/currencies/:id
```

**Success (200):** Single currency object.

**Errors:**
- 404: Not found
