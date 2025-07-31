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
