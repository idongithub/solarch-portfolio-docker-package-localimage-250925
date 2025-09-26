#!/bin/bash

# Kamal Singh Portfolio - Start Script

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Starting Kamal Singh Portfolio...${NC}"

# Check if MongoDB is running
check_mongodb() {
    if command -v mongosh >/dev/null 2>&1; then
        if mongosh --eval "db.adminCommand('ping')" --quiet >/dev/null 2>&1; then
            echo -e "${GREEN}✅ MongoDB is running${NC}"
            return 0
        fi
    elif command -v mongo >/dev/null 2>&1; then
        if mongo --eval "db.adminCommand('ping')" --quiet >/dev/null 2>&1; then
            echo -e "${GREEN}✅ MongoDB is running${NC}"
            return 0
        fi
    fi
    
    echo -e "${RED}❌ MongoDB is not running${NC}"
    echo -e "${YELLOW}Please start MongoDB first:${NC}"
    echo "  Linux: sudo systemctl start mongod"
    echo "  macOS: brew services start mongodb/brew/mongodb-community"
    echo "  Windows: Start MongoDB service from Services"
    return 1
}

# Function to start backend
start_backend() {
    echo -e "${GREEN}Starting Backend...${NC}"
    
    if [ ! -d "$SCRIPT_DIR/backend" ]; then
        echo -e "${RED}❌ Backend directory not found${NC}"
        exit 1
    fi
    
    cd "$SCRIPT_DIR/backend"
    
    # Check if virtual environment exists
    if [ ! -d "venv" ]; then
        echo -e "${RED}❌ Virtual environment not found${NC}"
        echo -e "${YELLOW}Please run setup.sh first${NC}"
        exit 1
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Check if .env file exists
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}⚠️ .env file not found, using .env.example...${NC}"
        if [ -f ".env.example" ]; then
            cp .env.example .env
        else
            echo -e "${RED}❌ No .env or .env.example file found${NC}"
            exit 1
        fi
    fi
    
    # Start backend
    echo "Backend starting on http://localhost:8001"
    uvicorn server:app --host 0.0.0.0 --port 8001 --reload &
    BACKEND_PID=$!
    echo "Backend started with PID: $BACKEND_PID"
    cd "$SCRIPT_DIR"
}

# Function to start frontend
start_frontend() {
    echo -e "${GREEN}Starting Frontend...${NC}"
    
    if [ ! -d "$SCRIPT_DIR/frontend" ]; then
        echo -e "${RED}❌ Frontend directory not found${NC}"
        exit 1
    fi
    
    cd "$SCRIPT_DIR/frontend"
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}⚠️ Dependencies not installed, installing...${NC}"
        yarn install
    fi
    
    # Check if .env file exists
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}⚠️ .env file not found, using .env.example...${NC}"
        if [ -f ".env.example" ]; then
            cp .env.example .env
        else
            echo -e "${RED}❌ No .env or .env.example file found${NC}"
            exit 1
        fi
    fi
    
    # Start frontend
    echo "Frontend starting on http://localhost:3000"
    yarn start &
    FRONTEND_PID=$!
    echo "Frontend started with PID: $FRONTEND_PID"
    cd "$SCRIPT_DIR"
}

# Function to check if ports are available
check_ports() {
    if lsof -Pi :8001 -sTCP:LISTEN -t >/dev/null ; then
        echo -e "${RED}❌ Port 8001 is already in use${NC}"
        echo "Please stop the process using port 8001 or run: ./stop_portfolio.sh"
        exit 1
    fi
    
    if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
        echo -e "${RED}❌ Port 3000 is already in use${NC}"
        echo "Please stop the process using port 3000 or run: ./stop_portfolio.sh"
        exit 1
    fi
}

# Main execution
main() {
    # Check MongoDB
    if ! check_mongodb; then
        exit 1
    fi
    
    # Check ports
    check_ports
    
    # Start services
    start_backend
    sleep 5
    start_frontend
    sleep 5
    
    echo -e "${BLUE}Portfolio started successfully! 🎉${NC}"
    echo ""
    echo -e "${GREEN}Access URLs:${NC}"
    echo "  🌐 Frontend: http://localhost:3000"
    echo "  🔧 Backend API: http://localhost:8001"
    echo "  📚 API Docs: http://localhost:8001/docs"
    echo ""
    echo -e "${YELLOW}Pages Available:${NC}"
    echo "  🏠 Home: http://localhost:3000/"
    echo "  👤 About: http://localhost:3000/about"
    echo "  🛠️ Skills: http://localhost:3000/skills"
    echo "  💼 Experience: http://localhost:3000/experience"
    echo "  🚀 Projects: http://localhost:3000/projects"
    echo "  📞 Contact: http://localhost:3000/contact"
    echo ""
    echo -e "${BLUE}Press Ctrl+C to stop both services${NC}"
    
    # Create PID file for easy stopping
    echo "$BACKEND_PID,$FRONTEND_PID" > "$SCRIPT_DIR/.portfolio_pids"
    
    # Wait for Ctrl+C
    trap 'echo -e "\n${YELLOW}Stopping services...${NC}"; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; rm -f "$SCRIPT_DIR/.portfolio_pids"; echo -e "${GREEN}Services stopped${NC}"; exit' INT
    wait
}

# Run main function
main "$@"