#!/bin/bash

# Kamal Singh Portfolio - Stop Script

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${YELLOW}Stopping Kamal Singh Portfolio services...${NC}"

cd "$SCRIPT_DIR"

# Function to stop process by PID
stop_by_pid() {
    local pid=$1
    local name=$2
    
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        echo "Stopping $name (PID: $pid)..."
        kill "$pid" 2>/dev/null
        
        # Wait a bit and force kill if necessary
        sleep 2
        if kill -0 "$pid" 2>/dev/null; then
            echo "Force stopping $name..."
            kill -9 "$pid" 2>/dev/null
        fi
        
        echo -e "${GREEN}✅ $name stopped${NC}"
    else
        echo "❌ $name not running or PID not found"
    fi
}

# Function to stop process by port
stop_by_port() {
    local port=$1
    local name=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "Stopping $name (port $port)..."
        local pids=$(lsof -Pi :$port -sTCP:LISTEN -t)
        for pid in $pids; do
            kill "$pid" 2>/dev/null
        done
        
        # Wait a bit and force kill if necessary
        sleep 2
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo "Force stopping $name..."
            local pids=$(lsof -Pi :$port -sTCP:LISTEN -t)
            for pid in $pids; do
                kill -9 "$pid" 2>/dev/null
            done
        fi
        
        echo -e "${GREEN}✅ $name stopped${NC}"
    else
        echo "❌ No process found on port $port"
    fi
}

# Try to stop using PID file first
if [ -f ".portfolio_pids" ]; then
    echo "Found PID file, stopping services..."
    pids=$(cat .portfolio_pids)
    IFS=',' read -r backend_pid frontend_pid <<< "$pids"
    
    stop_by_pid "$backend_pid" "Backend"
    stop_by_pid "$frontend_pid" "Frontend"
    
    # Remove PID file
    rm -f .portfolio_pids
    echo "PID file removed"
else
    echo "No PID file found, stopping by port..."
    
    # Stop by port as fallback
    stop_by_port "8001" "Backend"
    stop_by_port "3000" "Frontend"
fi

# Additional cleanup - stop any remaining processes
echo "Performing additional cleanup..."

# Stop any remaining uvicorn processes
pkill -f "uvicorn server:app" 2>/dev/null && echo "Stopped remaining uvicorn processes"

# Stop any remaining yarn/npm processes for this project
if [ -d "frontend" ]; then
    cd frontend
    # Get processes related to this specific frontend directory
    local frontend_dir=$(pwd)
    pkill -f "yarn.*start" 2>/dev/null && echo "Stopped remaining yarn processes"
    cd ..
fi

# Stop any Node.js processes that might be running React dev server
pkill -f "react-scripts start" 2>/dev/null && echo "Stopped remaining React processes"

# Final verification
echo ""
echo "Verification:"
if lsof -Pi :8001 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${RED}⚠️ Port 8001 still in use${NC}"
else
    echo -e "${GREEN}✅ Port 8001 is free${NC}"
fi

if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${RED}⚠️ Port 3000 still in use${NC}"
else
    echo -e "${GREEN}✅ Port 3000 is free${NC}"
fi

echo ""
echo -e "${GREEN}All Kamal Singh Portfolio services stopped successfully! 🛑${NC}"
echo ""
echo "To start the services again, run: ./start_portfolio.sh"