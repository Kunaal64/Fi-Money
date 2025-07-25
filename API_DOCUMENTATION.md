# API Documentation - Fi Money Inventory Application

## Overview

This document provides comprehensive documentation for the Fi Money Inventory Management API. The API offers endpoints for user authentication, product management (CRUD operations), and basic analytics. All authenticated endpoints utilize JWT (JSON Web Token) based authentication.

## Base URL

```
http://localhost:8080
```

## Authentication

Most endpoints require authentication via JWT tokens. Include the token in the `Authorization` header as follows:

```
Authorization: Bearer <your-jwt-token>
```

### Authentication Flow

1.  **Register**: Create a new user account by sending a `POST` request to `/register`.
2.  **Login**: Authenticate with your username and password by sending a `POST` request to `/login` to receive a JWT token.
3.  **Use Token**: Include the received JWT token in the `Authorization` header of all subsequent authenticated API calls.

---

## Endpoints

### Authentication Endpoints

#### 1. User Registration

**POST** `/register`

Registers a new user account in the system.

**Authentication Required**: No

**Request Body**:

```json
{
  "username": "string",
  "password": "string"
}
```

**Request Body Parameters**:

- `username` (string, required): A unique username for the new account.
- `password` (string, required): The password for the new account.

**Success Response** (201 Created):

```json
{
  "product_id": 1, // Example product_id if the API returns it, or other success message
  "message": "User created"
}
```

**Error Responses**:

- **400 Bad Request**: If validation fails (e.g., missing username or password).
  ```json
  {
    "error": "Username is required"
  }
  ```
- **409 Conflict**: If the username already exists.
  ```json
  {
    "error": "User already exists"
  }
  ```

---

#### 2. User Login

**POST** `/login`

Authenticates an existing user and returns an access token (JWT).

**Authentication Required**: No

**Request Body**:

```json
{
  "username": "string",
  "password": "string"
}
```

**Request Body Parameters**:

- `username` (string, required): The user's registered username.
- `password` (string, required): The user's password.

**Success Response** (200 OK):

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Responses**:

- **400 Bad Request**: If validation fails (e.g., missing username or password).
  ```json
  {
    "error": "Username is required"
  }
  ```
- **401 Unauthorized**: If credentials are invalid.
  ```json
  {
    "error": "Invalid credentials"
  }
  ```

---

### Product Management Endpoints

#### 3. Add a New Product

**POST** `/products`

Creates a new product entry. If a product with the same SKU already exists, its `times_added` count will be incremented.

**Authentication Required**: Yes (`bearerAuth`)

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

**Request Body Parameters**:

- `name` (string, required): The name of the product.
- `type` (string, required): The category or type of the product.
- `sku` (string, required): The Stock Keeping Unit, which must be unique.
- `image_url` (string, optional): A URL to an image of the product.
- `description` (string, optional): A description of the product.
- `quantity` (integer, required): The initial quantity of the product (must be non-negative).
- `price` (number, required): The price of the product.

**Success Response** (201 Created):

```json
{
  "product_id": 1,
  "message": "Product created"
}
```

**Error Responses**:

- **400 Bad Request**: Missing or invalid fields.
  ```json
  {
    "error": "Name is required"
  }
  ```
- **401 Unauthorized**: If authentication token is missing or invalid.
- **409 Conflict**: If a product with the same SKU already exists and cannot be handled as an update (e.g., name mismatch).
  ```json
  {
    "error": "SKU already exists"
  }
  ```

---

#### 4. Get Products List

**GET** `/products`

Retrieves a paginated list of all products in the inventory.

**Authentication Required**: Yes (`bearerAuth`)

**Query Parameters**:

- `limit` (integer, optional): The maximum number of products to return (default: 10).
- `offset` (integer, optional): The number of products to skip from the beginning (default: 0).

**Success Response** (200 OK):

```json
[
  {
    "id": 1,
    "name": "Laptop",
    "type": "Electronics",
    "sku": "LAP001",
    "image_url": "http://example.com/laptop.jpg",
    "description": "Powerful laptop for work and gaming",
    "quantity": 15,
    "price": "1200.00",
    "times_added": 3
  },
  {
    "id": 2,
    "name": "Wireless Mouse",
    "type": "Accessories",
    "sku": "MSE002",
    "image_url": null,
    "description": null,
    "quantity": 50,
    "price": "25.00",
    "times_added": 5
  }
]
```

**Error Responses**:

- **401 Unauthorized**: If authentication token is missing or invalid.

---

#### 5. Update Product Quantity

**PUT** `/products/{id}/quantity`

Updates the quantity of a specific product by its ID.

**Authentication Required**: Yes (`bearerAuth`)

**Path Parameters**:

- `id` (integer, required): The unique ID of the product to update.

**Request Body**:

```json
{
  "quantity": "integer"
}
```

**Request Body Parameters**:

- `quantity` (integer, required): The new quantity for the product (must be a non-negative integer).

**Success Response** (200 OK):

```json
{
  "id": 1,
  "name": "Laptop",
  "type": "Electronics",
  "sku": "LAP001",
  "image_url": "http://example.com/laptop.jpg",
  "description": "Powerful laptop for work and gaming",
  "quantity": 20,
  "price": "1200.00",
  "times_added": 3
}
```

**Error Responses**:

- **400 Bad Request**: Invalid quantity provided.
  ```json
  {
    "error": "Quantity must be a non-negative integer"
  }
  ```
- **401 Unauthorized**: If authentication token is missing or invalid.
- **404 Not Found**: If the product with the given ID does not exist.
  ```json
  {
    "error": "Product not found"
  }
  ```

---

#### 6. Delete a Product

**DELETE** `/products/{id}`

Deletes a product from the inventory by its ID.

**Authentication Required**: Yes (`bearerAuth`)

**Path Parameters**:

- `id` (integer, required): The unique ID of the product to delete.

**Success Response** (200 OK):

```json
{
  "message": "Product deleted"
}
```

**Error Responses**:

- **401 Unauthorized**: If authentication token is missing or invalid.
- **404 Not Found**: If the product with the given ID does not exist.
  ```json
  {
    "error": "Product not found"
  }
  ```

---

### Analytics Endpoints

#### 7. Get Most Added Products

**GET** `/products/analytics/most-added`

Retrieves a list of products ordered by how many times they have been added, providing basic analytics on popular additions.

**Authentication Required**: Yes (`bearerAuth`)

**Query Parameters**:

- `limit` (integer, optional): The maximum number of most added products to return (default: 5).

**Success Response** (200 OK):

```json
[
  {
    "id": 2,
    "name": "Wireless Mouse",
    "times_added": 5
  },
  {
    "id": 1,
    "name": "Laptop",
    "times_added": 3
  },
  {
    "id": 3,
    "name": "Keyboard",
    "times_added": 2
  }
]
```

**Error Responses**:

- **401 Unauthorized**: If authentication token is missing or invalid.

---

## Data Models

### User

Represents a user account in the system.

```json
{
  "id": "number",
  "username": "string",
  "password_hash": "string" // Hashed password
}
```

### Product

Represents an inventory item.

```json
{
  "id": "number",
  "name": "string",
  "type": "string",
  "sku": "string",
  "image_url": "string",
  "description": "string",
  "quantity": "integer",
  "price": "number",
  "times_added": "integer" // Number of times this product has been added
}
```

---

## Error Handling

All API endpoints adhere to a consistent error response pattern.

### Common HTTP Status Codes

**Success Codes:**

- **200 OK**: The request was successful, and the response body contains the requested data.
- **201 Created**: The request has resulted in a new resource being created.

**Error Codes:**

- **400 Bad Request**: The server cannot process the request due to client error (e.g., malformed syntax, invalid request parameters, failed validation).
- **401 Unauthorized**: Authentication is required or has failed (e.g., missing or invalid JWT token).
- **404 Not Found**: The requested resource could not be found.
- **409 Conflict**: The request could not be completed due to a conflict with the current state of the target resource (e.g., duplicate unique identifier).
- **500 Internal Server Error**: A generic error message, given when an unexpected condition was encountered on the server.

### Error Response Format

All error responses will have the following JSON structure:

```json
{
  "error": "A descriptive message explaining the error"
}
```

---

## Authentication Details

### JWT Token Structure

The JWT token generated upon successful login contains the following claims:

- `id`: The unique ID of the user.
- `username`: The username of the authenticated user.
- `iat`: (Issued At) Timestamp when the token was issued.
- `exp`: (Expiration Time) Timestamp when the token expires (typically 24 hours from issue).

### Token Usage

After logging in, clients must include the obtained JWT token in the `Authorization` header of all subsequent requests to protected endpoints.

Example:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJ0ZXN0dXNlciIsImlhdCI6MTY3ODU2NzQyMCwiZXhwIjoxNjc4NjUzODIwfQ.your_jwt_signature_here
```

### Token Expiration

JWT tokens are valid for 24 hours. Once a token expires, users must re-authenticate by logging in again to obtain a new valid token.

---

## Environment Variables

The backend requires the following environment variables to be configured in a `.env` file in the `backend/` directory:

- `DATABASE_URL`: The connection string for your PostgreSQL database (e.g., `postgresql://user:password@host:port/database?sslmode=require`).
- `JWT_SECRET`: A strong, secret key used for signing and verifying JWT tokens.
