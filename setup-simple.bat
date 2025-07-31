@echo off
setlocal enabledelayedexpansion

:: Clear the screen
cls

echo ========================================
echo    Fi-Money Application Setup
========================================
echo.

echo [*] Checking system requirements...

echo [*] Verifying Docker installation...
docker --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker is not installed or not in PATH.
    echo Please install Docker from: https://docs.docker.com/get-docker/
    pause
    exit /b 1
)
echo [OK] Docker is installed

echo [*] Verifying Docker Compose installation...
docker-compose --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker Compose is not installed or not in PATH.
    echo Please install Docker Compose from: https://docs.docker.com/compose/install/
    pause
    exit /b 1
)
echo [OK] Docker Compose is installed

:: Stop any running containers
echo.
echo [*] Stopping any running containers...
docker-compose down >nul 2>&1

:: Create .env file if it doesn't exist
if not exist .env (
    echo [*] Creating .env file...
    (
        echo # Backend
        echo PORT=8080
        echo DATABASE_URL=postgresql://user:password@db:5432/fimoney_db?sslmode=disable
        echo JWT_SECRET=your_secure_jwt_secret_key_change_this_in_production
        echo.
        echo # Frontend
        echo REACT_APP_API_BASE_URL=http://localhost:8080
    ) > .env
    echo [OK] .env file created
) else (
    echo [*] Using existing .env file
)

echo.
echo [*] Building and starting containers (this may take a few minutes)...
docker-compose up -d --build

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to start containers. Check the error above.
    pause
    exit /b 1
)

echo.
echo [*] Waiting for services to start...
:wait_for_db
docker-compose exec -T db pg_isready -U user -d fimoney_db >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo | set /p=.
    timeout /t 2 >nul
    goto wait_for_db
)
echo.

echo [*] Initializing database with sample data...
(
    echo CREATE TABLE IF NOT EXISTS users (
    echo     id SERIAL PRIMARY KEY,
    echo     username VARCHAR(50) UNIQUE NOT NULL,
    echo     email VARCHAR(100) UNIQUE NOT NULL,
    echo     password_hash VARCHAR(255) NOT NULL,
    echo     role VARCHAR(20) DEFAULT 'user',
    echo     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    echo );
    echo.
    echo CREATE TABLE IF NOT EXISTS products (
    echo     id SERIAL PRIMARY KEY,
    echo     name VARCHAR(100) NOT NULL,
    echo     description TEXT,
    echo     price DECIMAL(10, 2) NOT NULL,
    echo     quantity INTEGER NOT NULL,
    echo     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    echo );
    echo.
    echo -- Insert sample admin user (password: admin123)
    echo INSERT INTO users (username, email, password_hash, role) VALUES (
    echo     'admin',
    echo     'admin@example.com',
    echo     '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    echo     'admin'
    echo ) ON CONFLICT (username) DO NOTHING;
    echo.
    echo -- Insert sample products
    echo INSERT INTO products (name, description, price, quantity) VALUES
    echo     ('Laptop', 'High-performance laptop with 16GB RAM', 1200.00, 15),
    echo     ('Smartphone', 'Latest smartphone with 128GB storage', 800.00, 30),
    echo     ('Headphones', 'Wireless noise-canceling headphones', 250.00, 50)
    echo ON CONFLICT (name) DO NOTHING;
) > .\backend\init-db.sql

docker-compose exec -T db psql -U user -d fimoney_db -f /app/backend/init-db.sql >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [WARNING] Failed to initialize database with sample data.
) else (
    echo [OK] Database initialized with sample data
)

echo.
echo ========================================
echo    SETUP COMPLETED SUCCESSFULLY
echo ========================================
echo.

echo 1. APPLICATION ACCESS
echo    ----------------------------
echo    Frontend (Web Interface):
echo    http://localhost:3001
   API Docs: http://localhost:8080/api-docs

echo.
echo 2. GETTING STARTED
   ----------------------------
   - Open http://localhost:3001 in your browser
   - Register a new account
   - Start managing your inventory!

echo.
echo 3. MANAGEMENT COMMANDS
   ----------------------------
   View logs:         docker-compose logs -f
   Stop application:  docker-compose down
   Restart:           docker-compose restart
   View containers:   docker-compose ps

echo.
echo 4. TROUBLESHOOTING
   ----------------------------
   If the application doesn't load:
   - Check if containers are running: docker-compose ps
   - View logs: docker-compose logs
   - Reset everything: docker-compose down -v && setup-simple.bat

echo.
echo ========================================
echo [*] Starting application logs (Ctrl+C to exit):
echo ========================================

docker-compose logs -f --tail=20

pause
