# Category Types

> **Status: Not yet implemented**

Read-only. The two category types used to classify categories as income or expense.

## List Category Types

```
GET /api/v1/category_types
```

**Success (200):**
```json
{
  "category_types": [
    {"id": 1, "name": "income"},
    {"id": 2, "name": "expense"}
  ]
}
```

**Notes:**
- Category types are a fixed set. This endpoint exists so the iOS app doesn't need to hardcode these values.
- The API returns `"expense"` for type 2. The database currently stores `"spending"` — the blueprint maps this to the correct term.

## Get Category Type

```
GET /api/v1/category_types/:id
```

**Success (200):** Single category type object.

**Errors:**
- 404: Not found
