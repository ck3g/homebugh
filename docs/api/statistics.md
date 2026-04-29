# Statistics

> **Status: Not yet implemented**

Read-only. Income/expense totals and per-category breakdowns for a given month. The server handles the distinction between live transaction data (current month) and pre-aggregated historical data internally — the response shape is identical regardless.

## Get Monthly Statistics

```
GET /api/v1/statistics?year=2026&month=4&currency_id=1
```

**Query Parameters:**

| Param | Type | Required | Description |
|---|---|---|---|
| year | integer | yes | Year |
| month | integer | yes | Month (1-12) |
| currency_id | integer | no | Filter by currency (returns all currencies if omitted) |

**Success (200):**
```json
{
  "year": 2026,
  "month": 4,
  "currency_id": 1,
  "total_income": 5000.00,
  "total_expenses": 3200.00,
  "categories": [
    {"category_id": 7, "name": "Food", "amount": 800.00, "category_type_id": 2},
    {"category_id": 3, "name": "Salary", "amount": 5000.00, "category_type_id": 1}
  ]
}
```

## List Available Months

Returns all months that have transaction data, for building a month picker.

```
GET /api/v1/statistics/months?currency_id=1
```

**Query Parameters:**

| Param | Type | Required | Description |
|---|---|---|---|
| currency_id | integer | no | Filter by currency |

**Success (200):**
```json
[
  {"year": 2026, "month": 4},
  {"year": 2026, "month": 3},
  {"year": 2026, "month": 2},
  {"year": 2026, "month": 1},
  {"year": 2025, "month": 12}
]
```
