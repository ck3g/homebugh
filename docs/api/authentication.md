# Authentication

> **Status: Implemented**

Token-based authentication using Bearer tokens. Tokens are stored in the `auth_sessions` table with a 90-day expiry that auto-extends on each authenticated request.

## Login

Creates an authentication token.

```
POST /api/v1/token
```

No authentication required.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "secret"
}
```

**Success (201):**
```json
{
  "token": "550e8400-e29b-41d4-a716-446655440000",
  "user_id": 1
}
```

**Errors:**

| Status | Body | Cause |
|---|---|---|
| 401 | `{"error": "Invalid email or password"}` | Wrong credentials |
| 401 | `{"error": "User not confirmed"}` | Email not yet confirmed |

**Notes:**
- Token is a UUID v4
- Valid for 90 days from creation
- Expiry is extended by 90 days on every authenticated request
- User registration is only available via the web interface

## Logout

Revokes the current authentication token.

```
DELETE /api/v1/token
```

**Headers:** `Authorization: Bearer <token>` (required)

**Success (200):**
```json
{"status": "ok"}
```

**Errors:**
- 401: Missing or invalid token

## Using the Token

Include the token in the `Authorization` header on all subsequent requests:

```
Authorization: Bearer 550e8400-e29b-41d4-a716-446655440000
```

If the token is missing, invalid, or expired:

```
HTTP 401

{"error": "Unauthorized"}
```
