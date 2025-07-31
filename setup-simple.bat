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

:: Create or update .env file with valid values
echo [*] Configuring environment variables...
(
    echo # Backend
    echo PORT=8080
    echo DATABASE_URL=postgresql://user:password@db:5432/fimoney_db?sslmode=disable
    echo # This JWT_SECRET must match the one used in db_init.sql for the seeded users
    echo JWT_SECRET=92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi
    echo.
    echo # Frontend
    echo REACT_APP_API_BASE_URL=http://localhost:8080
) > .env
echo [OK] Environment variables configured (this may take a few minutes)...
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

:: Copy the db_init.sql file to the container
docker cp .\backend\db_init.sql fi-money-db-1:/docker-entrypoint-initdb.d/

:: Wait for PostgreSQL to be ready
echo [*] Waiting for PostgreSQL to be ready...
:wait_for_db
    docker-compose exec -T db pg_isready -U user -d fimoney_db >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        timeout /t 2 >nul
        goto wait_for_db
    )

:: Execute the initialization script
docker-compose exec -T db psql -U user -d fimoney_db -f /docker-entrypoint-initdb.d/db_init.sql >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [WARNING] Failed to initialize database with sample data.
) else (
    echo [OK] Database initialized with sample data
)

echo.
echo ========================================
echo    Setup Completed Successfully!
echo ========================================
echo.
echo Access the dashboard: http://localhost:3001
echo For more information, please refer to the README.md file
echo To stop the application, run: docker-compose down
echo.

echo.
echo [*] Setup completed successfully!
echo.
echo To view logs, run: docker-compose logs -f
echo To stop the application, run: docker-compose down

pause
