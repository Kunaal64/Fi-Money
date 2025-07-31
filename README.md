# Fi-Money Inventory System

A simple inventory management system with React frontend, Node.js/Express backend, and PostgreSQL database.

## Tech Stack

- **Frontend**: React.js, HTML/CSS, Axios
- **Backend**: Node.js, Express.js, JWT
- **Database**: PostgreSQL
- **Containerization**: Docker, Docker Compose
- **API Documentation**: Swagger/OpenAPI

## Features

- User authentication (Register/Login)
- Product management (CRUD operations)
- Real-time inventory tracking
- Responsive web interface
- Secure API with JWT authentication
- Interactive API documentation

## Prerequisites

- Docker and Docker Compose (for containerized setup)
- Node.js 16+ and npm (for manual setup)
- PostgreSQL 12+ (for manual setup)
- Git

## Quick Start

### Option 1: Using Docker (Recommended)

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/Fi-Money.git
   cd Fi-Money
   ```

2. Run the setup script:

   **Windows:**
   ```bash
   .\setup-simple.bat
   ```

   **Linux/macOS:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. Access the application:
   - Frontend: http://localhost:3001
   - API: http://localhost:8080
   - API Docs: http://localhost:8080/api-docs

## Default Users

The application comes with the following pre-configured users:

| Username | Password   |
|----------|------------|
| admin    | password   | 
| user1    | password   | 
| user2    | password   | 

> **Note**: These are default credentials. Please change the passwords after your first login for security.

### Option 2: Manual Setup

1. **Backend Setup**
   ```bash
   cd backend
   npm install
   cp .env.example .env
   # Update .env with your database credentials
   npm run migrate
   npm start
   ```

2. **Frontend Setup**
   ```bash
   cd frontend
   npm install
   cp .env.example .env
   # Update API URL in .env if needed
   npm start
   ```

## Project Structure

```
Fi-Money/
├── backend/                 # Node.js/Express API
│   ├── src/
│   │   ├── controllers/    # Request handlers
│   │   ├── middleware/     # Authentication & validation
│   │   ├── models/         # Database models
│   │   ├── routes/         # API routes
│   │   ├── utils/          # Helper functions
│   │   └── app.js          # Express app setup
│   ├── .env.example        # Environment variables template
│   ├── package.json        # Backend dependencies
│   └── db/                 # Database migrations/seeds
│
├── frontend/               # React application
│   ├── public/             # Static files
│   ├── src/
│   │   ├── components/     # Reusable UI components
│   │   ├── pages/          # Page components
│   │   ├── services/       # API service layer
│   │   ├── App.js          # Main app component
│   │   └── index.js        # Entry point
│   ├── .env.example        # Frontend env template
│   └── package.json        # Frontend dependencies
│
├── docker/                 # Docker configuration
├── .gitignore             # Git ignore rules
├── docker-compose.yml     # Docker compose config
├── setup.sh              # Linux/macOS setup script
└── setup-simple.bat      # Windows setup script
```

## API Endpoints

### Authentication
- `POST /register` - Register new user
- `POST /login` - User login

### Products
- `GET /products` - List all products
- `GET /products/:id` - Get single product
- `POST /products` - Create new product
- `PUT /products/:id` - Update product
- `DELETE /products/:id` - Delete product
- `PUT /products/:id/quantity` - Update product quantity

## Available Commands

### Docker Commands
- Start services: `docker-compose up -d`
- Stop services: `docker-compose down`
- View logs: `docker-compose logs -f`
- Check containers: `docker-compose ps`

### Development Commands
- Install dependencies: `npm install` (in both frontend/backend)
- Start development server: `npm start`
- Run tests: `npm test`

## Troubleshooting

1. **Docker not running**
   - Start Docker Desktop or Docker service
   - Run `docker ps` to verify

2. **Port conflicts**
   - Check if ports 3001 (frontend) or 8080 (backend) are in use
   - Update ports in `docker-compose.yml` if needed

3. **Database connection issues**
   - Verify database credentials in `.env`
   - Ensure database service is running

4. **Reset everything**
   ```bash
   docker-compose down -v
   # Then run the setup script again
   ```



