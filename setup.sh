#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}   Fi-Money Application Setup${NC}"
echo -e "${YELLOW}========================================${NC}"
echo

echo "[*] Checking system requirements..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Docker
if ! command_exists docker; then
    echo -e "${RED}[ERROR] Docker is not installed or not in PATH.${NC}"
    echo "Please install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi
echo -e "${GREEN}[OK]${NC} Docker is installed"

# Check Docker Compose
if ! command_exists docker-compose; then
    # Check for Docker Compose plugin (newer Docker Desktop versions)
    if ! docker compose version &>/dev/null; then
        echo -e "${RED}[ERROR] Docker Compose is not installed or not in PATH.${NC}"
        echo "Please install Docker Compose from: https://docs.docker.com/compose/install/"
        exit 1
    fi
    DOCKER_COMPOSE_CMD="docker compose"
else
    DOCKER_COMPOSE_CMD="docker-compose"
fi
echo -e "${GREEN}[OK]${NC} Docker Compose is available"

# Stop any running containers
echo
read -p "Do you want to stop any running containers? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "[*] Stopping any running containers..."
    $DOCKER_COMPOSE_CMD down
fi

# Create or update .env file with valid values
echo "[*] Configuring environment variables..."
cat > .env <<EOL
# Backend
PORT=8080
DATABASE_URL=postgresql://user:password@db:5432/fimoney_db?sslmode=disable
# This JWT_SECRET must match the one used in db_init.sql for the seeded users
JWT_SECRET=92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi

# Frontend
REACT_APP_API_BASE_URL=http://localhost:8080
EOL
echo "[OK] Environment variables configured"

# Build and start the application
echo
read -p "Do you want to build and start the application? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "[*] Building and starting the application..."
    $DOCKER_COMPOSE_CMD up --build -d
    
    # Wait for PostgreSQL to be ready
    echo -n "[*] Waiting for PostgreSQL to be ready..."
    until $DOCKER_COMPOSE_CMD exec -T db pg_isready -U user -d fimoney_db >/dev/null 2>&1; do
        echo -n "."
        sleep 1
    done
    echo -e "\n${GREEN}[OK]${NC} PostgreSQL is ready"

    # Copy the db_init.sql file to the container
    echo -n "[*] Copying database initialization script..."
    $DOCKER_COMPOSE_CMD cp ./backend/db_init.sql db:/docker-entrypoint-initdb.d/
    if [ $? -eq 0 ]; then
        echo -e " ${GREEN}[OK]${NC} Initialization script copied"
    else
        echo -e " ${RED}[ERROR]${NC} Failed to copy initialization script"
        exit 1
    fi

    # Execute the initialization script
    echo -n "[*] Initializing database with sample data..."
    $DOCKER_COMPOSE_CMD exec -T db psql -U user -d fimoney_db -f /docker-entrypoint-initdb.d/db_init.sql >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e " ${GREEN}[OK]${NC} Database initialized with sample data"
    else
        echo -e " ${YELLOW}[WARNING]${NC} Database initialization completed with warnings"
    fi

    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}========================================${NC}"
        echo -e "    ${GREEN}Setup Completed Successfully!${NC}"
        echo -e "${GREEN}========================================${NC}\n"
        echo -e "Access the dashboard: ${GREEN}http://localhost:3001${NC}"
        echo -e "For more information, please refer to the README.md file\n"
        echo -e "${YELLOW}Management Commands:${NC}"
        echo -e "  View logs:         $DOCKER_COMPOSE_CMD logs -f"
        echo -e "  Stop application:  $DOCKER_COMPOSE_CMD down"
        echo -e "  View containers:   $DOCKER_COMPOSE_CMD ps\n"
        echo -e "${GREEN}The application is now running in the background.${NC}"
    else
        echo -e "\n${RED}[ERROR]${NC} Failed to start the application. Check the logs for more details."
        exit 1
    fi
else
    echo -e "\n${YELLOW}[INFO]${NC} Skipping application startup. You can start it later with:\n"
    echo -e "  ${YELLOW}$DOCKER_COMPOSE_CMD up -d${NC}\n"
fi

echo -e "\n🎉 ${GREEN}Setup complete!${NC}"
