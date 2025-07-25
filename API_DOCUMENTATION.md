# Fi Money Inventory API Reference

## Introduction

Welcome to the Fi Money Inventory API! This document serves as a complete reference for integrating with our robust backend. The API facilitates secure user authentication, comprehensive product management, and insightful analytics. All protected routes rely on JSON Web Token (JWT) based authentication.

## API Endpoint Base URL

All requests should be sent to:
`http://localhost:8080`

---

## Authentication & Authorization

Access to most API resources requires a valid JWT. Please include your token in the `Authorization` header for all protected endpoints:

`Authorization: Bearer <your-json-web-token>`

### Authentication Flow (Quick Guide)

1.  **Register:** Create your user account via the `/register` endpoint.
2.  **Login:** Authenticate with your credentials at `/login` to obtain your unique JWT.
3.  **Secure Access:** Use this token for all subsequent API calls requiring authentication.

---

## Data Models

Understanding our data structures will help you interact with the API effectively.

### User Object

Represents a user account within the system.

```json
{
  "id": "number", // Unique identifier for the user
  "username": "string", // User's chosen username
  "password_hash": "string" // Hashed representation of the user's password (server-side)
}
```

### Product Object

Defines an item available in the inventory.

```json
{
  "id": "number", // Unique identifier for the product
  "name": "string", // Display name of the product
  "type": "string", // Category or classification of the product
  "sku": "string", // Stock Keeping Unit (unique product code)
  "image_url": "string", // URL to the product's image (can be null)
  "description": "string", // Detailed description of the product (can be null)
  "quantity": "integer", // Current stock quantity (non-negative)
  "price": "number", // Unit price of the product
  "times_added": "integer" // Count of how many times this product has been added (for analytics)
}
```

---

## API Endpoints

### User Authentication

#### 1. Login

**POST** `/login`

Authenticates a user and issues a new JWT.

**Authentication Required**: No

**Request Body**:

```json
{
  "username": "string",
  "password": "string"
}
```

**Parameters**:

- `username` (string, required): The user's registered username.
- `password` (string, required): The user's password.

**Success Response** (200 OK):
Returns the access token.

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Responses**:

- **400 Bad Request**: Missing required credentials.
  ```json
  { "error": "Username is required" }
  ```
- **401 Unauthorized**: Invalid username or password.
  ```json
  { "error": "Invalid credentials" }
  ```

---

#### 2. Register User

**POST** `/register`

Creates a new user account.

**Authentication Required**: No

**Request Body**:

```json
{
  "username": "string",
  "password": "string"
}
```

**Parameters**:

- `username` (string, required): A unique username for the new account.
- `password` (string, required): The password for the new account.

**Success Response** (201 Created):
Indicates successful user creation.

```json
{
  "product_id": 1, // Example ID if returned, or similar success confirmation
  "message": "User created"
}
```

**Error Responses**:

- **400 Bad Request**: Validation failure (e.g., missing fields).
  ```json
  { "error": "Username is required" }
  ```
- **409 Conflict**: Username already taken.
  ```json
  { "error": "User already exists" }
  ```

---

### Inventory Management

#### 3. Retrieve All Products (Paginated)

**GET** `/products`

Fetches a list of all products in the inventory, supporting pagination.

**Authentication Required**: Yes

**Query Parameters**:

- `limit` (integer, optional): Max number of results per page (default: 10).
- `offset` (integer, optional): Number of results to skip (default: 0).

**Success Response** (200 OK):
Returns an array of product objects.

```json
[
  {
    "id": 1,
    "name": "Smartphone X",
    "type": "Electronics",
    "sku": "SPX-001",
    "image_url": "http://example.com/spx.jpg",
    "description": "Latest model smartphone.",
    "quantity": 50,
    "price": "799.99",
    "times_added": 7
  }
]
```

**Error Responses**:

- **401 Unauthorized**: Missing or invalid authentication token.

---

#### 4. Add a Product

**POST** `/products`

Adds a new product to the inventory. Increments `times_added` if an existing product matches the SKU.

**Authentication Required**: Yes

**Request Body**:

```json
{
  "name": "string",
  "type": "string",
  "sku": "string",
  "image_url": "string",
  "description": "string",
  "quantity": "integer",
  "price": "number"
}
```

**Parameters**:

- `name` (string, required): Product name.
- `type` (string, required): Product category.
- `sku` (string, required): Unique SKU.
- `image_url` (string, optional): URL for product image.
- `description` (string, optional): Product description.
- `quantity` (integer, required): Initial stock quantity.
- `price` (number, required): Product price.

**Success Response** (201 Created):
Confirmation of product addition.

```json
{
  "product_id": 1,
  "message": "Product created"
}
```

**Error Responses**:

- **400 Bad Request**: Input validation failure (e.g., missing `name`).
  ```json
  { "error": "Name is required" }
  ```
- **401 Unauthorized**: Authentication token invalid or missing.
- **409 Conflict**: SKU already exists and conflicts with current data.
  ```json
  { "error": "SKU already exists" }
  ```

---

#### 5. Update Product Quantity

**PUT** `/products/{id}/quantity`

Modifies the stock quantity for a specified product.

**Authentication Required**: Yes

**Path Parameters**:

- `id` (integer, required): The unique ID of the product to update.

**Request Body**:

```json
{
  "quantity": "integer"
}
```

**Parameters**:

- `quantity` (integer, required): The new, non-negative quantity.

**Success Response** (200 OK):
Returns the updated product details.

```json
{
  "id": 1,
  "name": "Smartphone X",
  "type": "Electronics",
  "sku": "SPX-001",
  "image_url": "http://example.com/spx.jpg",
  "description": "Latest model smartphone.",
  "quantity": 75,
  "price": "799.99",
  "times_added": 7
}
```

**Error Responses**:

- **400 Bad Request**: Invalid quantity input.
  ```json
  { "error": "Quantity must be a non-negative integer" }
  ```
- **401 Unauthorized**: Missing or invalid authentication token.
- **404 Not Found**: Product with the given ID does not exist.
  ```json
  { "error": "Product not found" }
  ```

---

#### 6. Delete a Product

**DELETE** `/products/{id}`

Removes a product from the inventory.

**Authentication Required**: Yes

**Path Parameters**:

- `id` (integer, required): The unique ID of the product to delete.

**Success Response** (200 OK):
Confirms product deletion.

```json
{
  "message": "Product deleted"
}
```

**Error Responses**:

- **401 Unauthorized**: Missing or invalid authentication token.
- **404 Not Found**: Product with the given ID does not exist.
  ```json
  { "error": "Product not found" }
  ```

---

### Analytics & Insights

#### 7. Get Most Added Products

**GET** `/products/analytics/most-added`

Provides a list of products ranked by how many times they've been added, offering a basic popularity metric.

**Authentication Required**: Yes

**Query Parameters**:

- `limit` (integer, optional): The maximum number of products to return (default: 5).

**Success Response** (200 OK):
Returns an array of products with their add counts.

```json
[
  {
    "id": 5,
    "name": "Bluetooth Headphones",
    "times_added": 12
  },
  {
    "id": 3,
    "name": "Portable Charger",
    "times_added": 9
  }
]
```

**Error Responses**:

- **401 Unauthorized**: Missing or invalid authentication token.

---

## Error Handling Standards

All API errors are returned in a consistent JSON format to facilitate easier client-side handling.

### Common HTTP Status Codes

**Success Codes:**

- **200 OK**: Request processed successfully, data returned.
- **201 Created**: A new resource was successfully created.

**Error Codes:**

- **400 Bad Request**: Client-side input validation failed.
- **401 Unauthorized**: Authentication required; token is missing, invalid, or expired.
- **404 Not Found**: The requested resource does not exist.
- **409 Conflict**: Request could not be completed due to a data conflict (e.g., unique constraint violation).
- **500 Internal Server Error**: An unexpected server-side error occurred.

### Standard Error Response Format

```json
{
  "error": "A concise, human-readable message describing the error."
}
```

---

## JWT Details

### Token Structure

Our JWTs encode essential user information:

- `id`: The unique identifier of the user.
- `username`: The username associated with the token.
- `iat`: (Issued At) Timestamp indicating when the token was generated.
- `exp`: (Expiration Time) Timestamp indicating when the token becomes invalid (24 hours after `iat`).

### Token Usage Example

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTIsInVzZXJuYW1lIjoiZGV2dXNlciIsImlhdCI6MTY3ODU2NzQyMCwiZXhwIjoxNjc4NjUzODIwfQ.another_signature_string
```

### Token Expiration

For security, JWTs are short-lived, expiring 24 hours after issuance. Clients should handle expired tokens by prompting the user to log in again to acquire a new token.

---

## Environment Configuration

The backend application requires the following environment variables, typically loaded from a `.env` file in the `backend/` directory:

- `DATABASE_URL`: Your PostgreSQL connection string.
- `JWT_SECRET`: A strong, confidential key for cryptographic signing of JWTs.
