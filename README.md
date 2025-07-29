# Inventory Control Hub

A modern, comprehensive system for managing product inventory, built with a robust Node.js (Express) backend, a dynamic React frontend, and a reliable PostgreSQL database.

## Core System Capabilities

- **User Authentication:** Secure JWT-based access control with bcrypt for password hashing.
- **Product Lifecycle Management:** Full CRUD operations for all inventory items, including stock tracking.
- **Analytics Overview:** Basic insights into product popularity by tracking additions, data persistently stored in PostgreSQL.
- **Intuitive User Interface:** A contemporary and user-friendly design focused on clarity and ease of navigation.
- **API Guide:** Comprehensive OpenAPI/Swagger documentation detailing all backend endpoints.
- **Secure Configuration:** Sensitive environment variables managed safely.

## Technology Stack

- **Client-Side:** React.js (JavaScript, CSS)
- **Server-Side:** Node.js, Express.js
- **Database Engine:** PostgreSQL
- **Security & Identity:** JWT, bcrypt
- **Package Management:** npm

## Prerequisites Checklist

Before launching the application, please ensure you have:

- Node.js (version 16+ strongly advised)
- An operational PostgreSQL database instance
- Git for repository cloning

## Installation & Setup Guide

### 1. Obtain the Source Code

```bash
git clone <repository-url>
cd "Fi Money" # Move into the project root
```

### 2. Backend Environment Configuration

1.  **Change directory:**
    ```bash
    cd backend
    ```
2.  **Install server dependencies:**
    ```bash
    npm install
    ```
3.  **Set up Environment Variables:**
    Create a `.env` file in the `backend/` directory (you can copy `.env.example`).
    ```env
    DATABASE_URL=postgresql://<username>:<password>@<host>:<port>/<database>?sslmode=require
    JWT_SECRET=your_super_secure_jwt_secret_key
    PORT=8080
    ```
    _Important:_ Replace `DATABASE_URL` with your specific PostgreSQL connection string. Ensure `JWT_SECRET` is a strong, unique value.
4.  **Initialize Database Schema:**
    **Warning:** This operation will clear and re-create your `users` and `products` tables. Backup any crucial data if this isn't a fresh setup.
    ```bash
    npm run init-db
    ```
    This action ensures the `products` table includes the `times_added` column for analytics.
5.  **Start the Backend Service:**
    ```bash
    npm start
    # Alternatively:
    node src/app.js
    ```
    The backend API will become available at `http://localhost:8080`.

### 3. Frontend Environment Configuration

1.  **Change directory:**
    (From the project root, navigate back into `frontend`)
    ```bash
    cd frontend
    ```
2.  **Install client dependencies:**
    ```bash
    npm install
    ```
3.  **Launch Frontend Server:**
    ```bash
    npm start
    ```
    The React application should open in your browser, usually at `http://localhost:3000`.

### 4. Docker Deployment (Optional)

This project can be easily containerized using Docker for simplified deployment and environment consistency.

1.  **Build the Docker Image:**
    Navigate to the root directory of the project (where the `Dockerfile` is located) and run:

    ```bash
    docker build -t fi-money-backend .
    ```

2.  **Run the Docker Container:**
    Start the backend application in a Docker container, mapping port `8080` (or your desired port) and setting the `PORT` environment variable:
    ```bash
    docker run -p 8080:8080 -e PORT=8080 fi-money-backend
    ```
    (You can replace `8080:8080` with `YOUR_HOST_PORT:8080` to map to a different port on your host machine.)

### 5. Testing the Dockerized Application

Once the Docker container is running, you can test the backend API endpoints using `curl` (on Linux/macOS/Git Bash) or `Invoke-WebRequest` (on PowerShell). Replace `http://localhost:8080` with your container's accessible address and port if different.

**A. User Registration (New User):**

To register a new user, send a POST request to the `/register` endpoint:

```powershell
Invoke-WebRequest -Uri http://localhost:8080/register -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username":"newuser","password":"newpassword"}'
```

(Expected: `StatusCode: 201 Created` with a `user_id`)

**B. User Login (Existing or New User):**

To log in and obtain an authentication token, send a POST request to the `/login` endpoint. This token is required for protected routes.

```powershell
# Get the access token (PowerShell)
$accessToken = Invoke-WebRequest -Uri http://localhost:8080/login -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"username":"newuser","password":"newpassword"}' | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty access_token
Write-Host "Access Token: $($accessToken)"
```

**C. View Products List:**

To view the list of products, send a GET request to the `/products` endpoint with your authentication token:

```powershell
Invoke-WebRequest -Uri http://localhost:8080/products -Method GET -Headers @{"Authorization"="Bearer $($accessToken)"} | Select-Object -ExpandProperty Content | ConvertFrom-Json
```

(Expected: A list of product objects)

**D. Add a New Product:**

To add a new product, send a POST request to the `/products` endpoint with product details and your authentication token:

```powershell
Invoke-WebRequest -Uri http://localhost:8080/products -Method POST -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $($accessToken)"} -Body '{"name":"Sample Product","type":"Electronics","sku":"SAMPLE001","quantity":50,"price":29.99,"description":"A description of the sample product."}'
```

(Expected: `StatusCode: 201 Created` with a `product_id` and `message`)

---

## Database Schema Overview

Our application is structured around these key PostgreSQL tables:

### Users (Authentication)

- `id` (Primary Key, Auto-increment)
- `username` (Unique, Not Null)
- `password_hash` (Stores bcrypt hashed passwords, Not Null)

### Products (Inventory Items)

- `id` (Primary Key, Auto-increment)
- `name` (Not Null)
- `type` (Not Null)
- `sku` (Unique identifier, Not Null)
- `image_url` (Optional)
- `description` (Optional)
- `quantity` (Integer, Not Null)
- `price` (Numeric(10,2), Not Null)
- `times_added` (Integer, Default 0; for analytics on product additions)

---

## Available Commands

These commands are executed from within their respective `backend/` or `frontend/` directories.

| Command           | Location    | Purpose                                       |
| :---------------- | :---------- | :-------------------------------------------- |
| `npm install`     | `backend/`  | Installs server-side project dependencies     |
| `npm start`       | `backend/`  | Initiates the Node.js API server              |
| `npm run init-db` | `backend/`  | Initializes or resets the PostgreSQL database |
| `npm install`     | `frontend/` | Installs client-side project dependencies     |
| `npm start`       | `frontend/` | Launches the React development server         |

---

## API Endpoint Reference

All API services are available at `http://localhost:8080`. For comprehensive details on request/response formats, parameters, and authentication, please consult the `API_DOCUMENTATION.md` file.

### Identity & Security Endpoints

- **POST** `/register` - New user account creation
- **POST** `/login` - User authentication and JWT issuance

### Inventory Operations Endpoints

- **POST** `/products` - Add a new product (or increment count if SKU exists)
- **GET** `/products` - Retrieve list of products (with pagination)
- **PUT** `/products/{id}/quantity` - Update specific product quantity
- **DELETE** `/products/{id}` - Remove a product

### Analytics & Data Insights

- **GET** `/products/analytics/most-added` - Fetch data on most frequently added products

---

## Authentication Process Details

1.  **Account Creation:** Users register via the `/register` endpoint.
2.  **Token Acquisition:** A successful login (`POST` to `/login`) provides a JWT, crucial for authenticated requests.
3.  **Authorized Requests:** This JWT must be included in the `Authorization` header (`Bearer <token>`) for all protected API calls.
4.  **Token Validity:** JWTs are valid for 24 hours; re-login is necessary upon expiration.

---

## Project Directory Structure

```
Fi Money/
├── backend/                 # Node.js/Express API (server-side logic)
│   ├── db_init.sql          # Database schema definition
│   ├── init-db.js           # Script for database setup
│   ├── src/                 # Backend application source code
│   │   ├── app.js           # Main Express application
│   │   ├── controllers/     # API request handlers
│   │   ├── middleware/      # Authentication & other middleware
│   │   ├── models/          # Database interaction layer
│   │   ├── routes/          # API endpoint routing
│   │   └── utils/           # General utility functions
│   └── swagger.yaml         # OpenAPI specification file
├── frontend/                # React Application (client-side UI)
│   ├── public/              # Static web assets
│   ├── src/                 # Frontend source code
│   │   ├── App.js           # Primary application component & routing
│   │   ├── App.css          # Global and component styling
│   │   ├── Login.js         # User login interface
│   │   ├── Register.js      # User registration interface
│   │   └── ProductList.js   # Product display and management UI
│   └── package.json         # Frontend dependencies & scripts
├── README.md                # Comprehensive project documentation (this file)
├── API_DOCUMENTATION.md     # Detailed API endpoint reference
└── package.json             # Root-level package manager config (if applicable)
```

---

## Security Implementation

- **Password Safeguarding:** User passwords are encrypted using bcrypt before being stored, significantly enhancing security.
- **JWT Access Control:** Critical API routes are meticulously protected with JWTs, ensuring only validated and authorized users can interact with them.
- **Input Integrity Validation:** A robust validation system actively scrutinizes all incoming data for API requests, preventing malformed inputs and thwarting potential injection vulnerabilities.
- **Environmental Isolation:** Sensitive configuration data, such as database credentials and cryptographic keys, are strictly segregated via environment variables, eliminating their exposure in the source code.

---

## Future Enhancements & Expansion Ideas

Potential areas for evolving this project include:

- **Advanced Reporting Modules:** Developing more sophisticated analytics, such as identifying least-performing products, revenue breakdown by product type, or trend analysis for sales over time.
- **Role-Based Access Control (RBAC):** Implementing distinct user roles with fine-grained permissions (e.g., read-only users, inventory managers, administrators).
- **Dynamic Search & Filtering:** Introducing powerful search capabilities and flexible filtering options for the product catalog to enhance data discovery and user experience.
- **Optimized Product Listing:** Implementing server-side pagination for the product display to ensure efficient handling and faster loading times for very large datasets.
- **Integrated Image Uploads:** Developing functionality for direct image uploads to a cloud storage service (e.g., AWS S3, Cloudinary), moving beyond URL-based inputs.
- **Real-time Interactions:** Leveraging WebSocket technology to enable instant updates across all connected client applications for inventory changes or new product additions.
- **Thorough Testing Suites:** Expanding comprehensive unit, integration, and end-to-end tests for both frontend and backend to guarantee high reliability, stability, and bug prevention.
- **Centralized Logging & Monitoring:** Establishing a robust logging infrastructure to monitor application behavior, track errors, and streamline debugging in production environments.
- **Advanced Frontend State Management:** For growing application complexity, consider adopting a dedicated state management library (e.g., Redux, Zustand) for more predictable and maintainable frontend state.

---

## Licensing Information

MIT
