# Homebugh API Documentation

REST API for the Homebugh financial management application. Designed to support an iOS app with offline-first capabilities and bidirectional sync.

Base URL: `https://<your-server>/api/v1`

## Implementation Status

| Resource | Status |
|---|---|
| [Authentication](authentication.md) | Not yet implemented |
| [Accounts](accounts.md) | Not yet implemented |
| [Categories](categories.md) | Not yet implemented |
| [Transactions](transactions.md) | Not yet implemented |
| [Cash Flows](cash_flows.md) | Not yet implemented |
| [Budgets](budgets.md) | Not yet implemented |
| [Recurring Payments](recurring_payments.md) | Not yet implemented |
| [Recurring Cash Flows](recurring_cash_flows.md) | Not yet implemented |
| [Currencies](currencies.md) | Not yet implemented |
| [Category Types](category_types.md) | Not yet implemented |
| [Statistics](statistics.md) | Not yet implemented |
| [Sync](sync.md) | Not yet implemented |

## Conventions

### Authentication

All endpoints (except login) require a Bearer token in the `Authorization` header:

```
Authorization: Bearer <token>
```

Tokens are obtained via the [login endpoint](authentication.md). Tokens are valid for 90 days and auto-extend on each use.

### Request/Response Format

- Content-Type: `application/json`
- All keys use `snake_case`
- All fields are always present in responses (nullable fields return `null`, never omitted)
- All timestamps are ISO 8601 UTC (e.g., `2026-04-28T14:30:00.000Z`)

### Field Name Mappings

The API uses clean field names that differ from legacy database column names:

| API field | Database column | Resource |
|---|---|---|
| `amount` | `summ` | Transactions |
| `balance` | `funds` | Accounts |

### Pagination

All list endpoints support pagination:

| Param | Type | Default | Description |
|---|---|---|---|
| `page` | integer | 1 | Page number |
| `per_page` | integer | 20 | Items per page (max 50) |

Response includes metadata:

```json
{
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 5,
    "total_count": 100
  }
}
```

### Incremental Fetching

All list endpoints support an `updated_since` query parameter (ISO 8601 datetime) to return only records updated after the given timestamp.

### HTTP Status Codes

| Code | Meaning |
|---|---|
| 200 | Success |
| 201 | Created |
| 401 | Authentication failed / token expired |
| 403 | Not authorized (another user's data) |
| 404 | Resource not found |
| 422 | Validation errors |
| 429 | Rate limited |
| 500 | Server error |

### Error Responses

Validation errors (422):
```json
{
  "error": "Validation failed",
  "details": {
    "name": ["can't be blank", "has already been taken"],
    "amount": ["must be greater than or equal to 0.01"]
  }
}
```

Not found (404):
```json
{"error": "Not found"}
```

Rate limited (429):
```json
{"error": "Rate limit exceeded"}
```

### Rate Limiting

All endpoints are rate-limited to 2 requests per second per IP, with a burst allowance of 4. Exceeding the limit returns 429.
