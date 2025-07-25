# Fi Money Inventory Application

This is a full-stack inventory management application with a Node.js/Express backend and a React frontend.

## Features

- User registration and login (JWT-based)
- CRUD for products (with image, description, quantity, price, etc.)
- Input validation and consistent error handling
- Swagger/OpenAPI documentation for backend API
- Environment-based config with `.env` and `.env.example`
- **Modern and minimalistic UI for enhanced user experience**
- **Basic product analytics: Tracks and displays most added products (data stored in PostgreSQL)**

## Requirements

- Node.js (v16+ recommended)
- PostgreSQL database

## Setup

### Backend Setup

1.  **Navigate to the `backend` directory:**
    ```sh
    cd backend
    ```
2.  **Install dependencies:**
    ```sh
    npm install
    ```
3.  **Configure environment variables:**
    - Copy `.env.example` to `.env` in the `backend/` directory and fill in your real credentials.
    - Example:
      ```env
      DATABASE_URL=postgresql://<username>:<password>@<host>:<port>/<database>?sslmode=require
      JWT_SECRET=your_jwt_secret
      PORT=8080
      ```
4.  **Initialize the database:**
    - **Important:** This step will drop existing tables and recreate them. Ensure you have backed up any important data if this is not a fresh setup.
    ```sh
    npm run init-db
    ```
    This will create the necessary `users` and `products` tables, including the `times_added` column for product analytics.
5.  **Start the backend server:**
    ```sh
    npm start
    # or
    node src/app.js
    ```
    The backend server will typically run on `http://localhost:8080`.

### Frontend Setup

1.  **Navigate to the `frontend` directory:**
    ```sh
    cd frontend
    ```
2.  **Install dependencies:**
    ```sh
    npm install
    ```
3.  **Start the frontend development server:**
    ```sh
    npm start
    ```
    The frontend application will typically open in your browser at `http://localhost:3000`.

## Assumptions

- It is assumed that a PostgreSQL database instance is available and accessible with the provided `DATABASE_URL`.
- The application runs on `http://localhost:8080` for the backend and `http://localhost:3000` for the frontend. Adjust proxy settings in `frontend/package.json` if your backend runs on a different port.
- Basic validation is implemented, but comprehensive error handling and edge-case management for all API interactions might require further refinement.
- The `times_added` analytic tracks product additions but does not account for edits or deletions in the current implementation.

## API Documentation

- Swagger UI is available at: [http://localhost:8080/api-docs](http://localhost:8080/api-docs)
- See `backend/swagger.yaml` for the OpenAPI spec.

## Example API Requests

### Register

```sh
curl -X POST http://localhost:8080/register \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "testpass"}'
```

### Login

```sh
curl -X POST http://localhost:8080/login \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "testpass"}'
```

### Add Product

```sh
curl -X POST http://localhost:8080/products \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sample Product",
    "type": "Electronics",
    "sku": "SKU123",
    "quantity": 10,
    "price": 99.99,
    "image_url": "",
    "description": ""
  }'
```

### List Products

```sh
curl -X GET http://localhost:8080/products \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

### Get Most Added Products (Analytics)

```sh
curl -X GET http://localhost:8080/products/analytics/most-added \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

### Update Product Quantity

```sh
curl -X PUT http://localhost:8080/products/1/quantity \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"quantity": 20}'
```

### Delete Product

```sh
curl -X DELETE http://localhost:8080/products/1 \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

## Test Server API

- To run the server with a test config, create a `.env.test` file (see `.env.example`).
- Start the test server with:
  ```sh
  NODE_ENV=test node src/app.js
  # or (if you add a script)
  npm run test-server
  ```

## Development

- All secrets/config are managed via environment variables.
- All endpoints have input validation and consistent error responses.
- Contributions welcome!

## Stretch Work (Future Enhancements)

- **Advanced Analytics**: Implement more sophisticated analytics, such as least sold products, revenue by product type, or daily sales trends.
- **User Roles and Permissions**: Introduce different user roles (e.g., admin, standard user) with varying levels of access and permissions to product management.
- **Search and Filtering**: Add robust search and filtering capabilities to the product list for easier navigation and data retrieval.
- **Pagination on Product List**: Implement server-side pagination for the product list to efficiently handle large datasets.
- **Image Uploads**: Integrate a file storage service (e.g., AWS S3, Cloudinary) for direct image uploads instead of just URL input.
- **Real-time Updates**: Use WebSockets to provide real-time updates for product quantity changes or new product additions across multiple connected clients.
- **Comprehensive Testing**: Expand unit, integration, and end-to-end tests for both frontend and backend to ensure robustness and stability.
- **Error Logging**: Implement a centralized error logging system to monitor and debug issues in production environments.
- **Frontend State Management**: For larger applications, consider using a dedicated state management library like Redux or Zustand for more complex state handling.

## License

MIT
