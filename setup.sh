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

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "[*] Creating .env file..."
    cat > .env <<EOL
# Backend
PORT=8080
DATABASE_URL=postgresql://user:password@db:5432/fimoney_db?sslmode=disable
JWT_SECRET=your_secure_jwt_secret_key_change_this_in_production

# Frontend
REACT_APP_API_BASE_URL=http://localhost:8080
EOL
    echo -e "${GREEN}[OK]${NC} Created .env file"
else
    echo -e "${YELLOW}[INFO]${NC} .env file already exists, skipping creation"
fi

# Build and start the application
echo
read -p "Do you want to build and start the application? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "[*] Building and starting the application..."
    $DOCKER_COMPOSE_CMD up --build -d
    
    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}[SUCCESS]${NC} Application is starting up!"
        echo -e "\n🌐 Access the application at: ${GREEN}http://localhost:3001${NC}"
        echo -e "📚 API Documentation: ${GREEN}http://localhost:8080/api-docs${NC}"
        echo -e "\nYou can view the logs with: ${YELLOW}$DOCKER_COMPOSE_CMD logs -f${NC}"
    else
        echo -e "\n${RED}[ERROR]${NC} Failed to start the application. Check the logs for more details."
        exit 1
    fi
else
    echo -e "\n${YELLOW}[INFO]${NC} Skipping application startup. You can start it later with:\n"
    echo -e "  ${YELLOW}$DOCKER_COMPOSE_CMD up -d${NC}\n"
fi

echo -e "\n🎉 ${GREEN}Setup complete!${NC}"
