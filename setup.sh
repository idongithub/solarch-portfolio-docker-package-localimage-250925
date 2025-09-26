#!/bin/bash

# Kamal Singh Portfolio - Automated Setup Script
# This script automates the local deployment setup for GitHub repository

set -e

echo "======================================"
echo "Kamal Singh Portfolio - Setup Script"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_section() {
    echo -e "\n${BLUE}======================================"
    echo -e "$1"
    echo -e "======================================${NC}\n"
}

# Check if running on supported OS
check_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        print_status "Detected Linux OS"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_status "Detected macOS"
    else
        print_error "Unsupported OS: $OSTYPE"
        print_error "This script supports Linux and macOS only"
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install prerequisites
install_prerequisites() {
    print_section "Installing Prerequisites"
    
    if [[ "$OS" == "linux" ]]; then
        # Update system
        print_status "Updating system packages..."
        sudo apt update
        
        # Install Node.js 18.x
        if ! command_exists node; then
            print_status "Installing Node.js..."
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt-get install -y nodejs
        else
            print_status "Node.js already installed: $(node --version)"
        fi
        
        # Install Yarn
        if ! command_exists yarn; then
            print_status "Installing Yarn..."
            curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
            echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
            sudo apt-get update && sudo apt-get install yarn
        else
            print_status "Yarn already installed: $(yarn --version)"
        fi
        
        # Install Python 3 and pip
        if ! command_exists python3; then
            print_status "Installing Python 3..."
            sudo apt install -y python3 python3-pip python3-venv
        else
            print_status "Python 3 already installed: $(python3 --version)"
        fi
        
        # Install MongoDB
        if ! command_exists mongod; then
            print_status "Installing MongoDB..."
            wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
            echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
            sudo apt-get update
            sudo apt-get install -y mongodb-org
        else
            print_status "MongoDB already installed"
        fi
        
    elif [[ "$OS" == "macos" ]]; then
        # Check if Homebrew is installed
        if ! command_exists brew; then
            print_status "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            print_status "Homebrew already installed"
        fi
        
        # Install Node.js and Yarn
        if ! command_exists node; then
            print_status "Installing Node.js..."
            brew install node
        else
            print_status "Node.js already installed: $(node --version)"
        fi
        
        if ! command_exists yarn; then
            print_status "Installing Yarn..."
            brew install yarn
        else
            print_status "Yarn already installed: $(yarn --version)"
        fi
        
        # Install Python
        if ! command_exists python3; then
            print_status "Installing Python 3..."
            brew install python
        else
            print_status "Python 3 already installed: $(python3 --version)"
        fi
        
        # Install MongoDB
        if ! command_exists mongod; then
            print_status "Installing MongoDB..."
            brew tap mongodb/brew
            brew install mongodb-community
        else
            print_status "MongoDB already installed"
        fi
    fi
}

# Setup MongoDB
setup_mongodb() {
    print_section "Setting up MongoDB"
    
    # Start MongoDB service
    if [[ "$OS" == "linux" ]]; then
        print_status "Starting MongoDB service..."
        sudo systemctl start mongod
        sudo systemctl enable mongod
        
        # Wait for MongoDB to start
        sleep 5
        
        # Check if MongoDB is running
        if sudo systemctl is-active --quiet mongod; then
            print_status "MongoDB service is running"
        else
            print_error "Failed to start MongoDB service"
            exit 1
        fi
        
    elif [[ "$OS" == "macos" ]]; then
        print_status "Starting MongoDB service..."
        brew services start mongodb/brew/mongodb-community
        
        # Wait for MongoDB to start
        sleep 5
    fi
    
    # Create database and test connection
    print_status "Setting up database..."
    
    # Create MongoDB initialization script
    cat > /tmp/mongo_init.js << 'EOF'
// Switch to portfolio database
use portfolio_db

// Create a test document to verify connection
db.status_checks.insertOne({
  client_name: "setup_test",
  timestamp: new Date(),
  message: "Database setup completed successfully"
})

// Verify the document was created
print("Database setup verification:")
printjson(db.status_checks.findOne({client_name: "setup_test"}))
EOF

    # Execute MongoDB initialization
    if command_exists mongosh; then
        mongosh --quiet --file /tmp/mongo_init.js
    elif command_exists mongo; then
        mongo --quiet /tmp/mongo_init.js
    else
        print_warning "MongoDB client not found, skipping database initialization"
    fi
    
    # Clean up
    rm -f /tmp/mongo_init.js
    
    print_status "MongoDB setup completed"
}

# Setup Backend
setup_backend() {
    print_section "Setting up Backend"
    
    # Navigate to backend directory
    cd "$PROJECT_DIR/backend"
    
    # Create virtual environment
    if [ ! -d "venv" ]; then
        print_status "Creating Python virtual environment..."
        python3 -m venv venv
    else
        print_status "Virtual environment already exists"
    fi
    
    # Activate virtual environment
    print_status "Activating virtual environment..."
    source venv/bin/activate
    
    # Upgrade pip
    print_status "Upgrading pip..."
    pip install --upgrade pip
    
    # Install dependencies
    print_status "Installing Python dependencies..."
    pip install -r requirements.txt
    
    # Create .env file from template if it doesn't exist
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            print_status "Creating backend .env file from template..."
            cp .env.example .env
            print_status "Backend .env file created from template"
            print_warning "Please review and update the .env file with your specific configuration"
        else
            print_status "Creating default backend .env file..."
            cat > .env << 'EOF'
# Database Configuration
MONGO_URL=mongodb://localhost:27017
DB_NAME=portfolio_db

# Server Configuration
HOST=0.0.0.0
PORT=8001

# Environment
ENVIRONMENT=development
DEBUG=True

# Security (generate your own secret key)
SECRET_KEY=kamal-singh-portfolio-secret-key-2024

# CORS Settings
ALLOWED_ORIGINS=["http://localhost:3000", "http://127.0.0.1:3000"]
EOF
        fi
    else
        print_status "Backend .env file already exists"
    fi
    
    # Test backend
    print_status "Testing backend setup..."
    python -c "
import sys
sys.path.append('.')
try:
    from server import app
    print('✅ Backend imports successful')
except Exception as e:
    print(f'❌ Backend import error: {e}')
    sys.exit(1)
"
    
    cd "$PROJECT_DIR"
    print_status "Backend setup completed"
}

# Setup Frontend
setup_frontend() {
    print_section "Setting up Frontend"
    
    # Navigate to frontend directory
    cd "$PROJECT_DIR/frontend"
    
    # Install dependencies
    print_status "Installing Node.js dependencies..."
    yarn install
    
    # Create .env file from template if it doesn't exist
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            print_status "Creating frontend .env file from template..."
            cp .env.example .env
            print_status "Frontend .env file created from template"
        else
            print_status "Creating default frontend .env file..."
            cat > .env << 'EOF'
# Backend API URL
REACT_APP_BACKEND_URL=http://localhost:8001

# Environment
NODE_ENV=development

# Port (optional - defaults to 3000)
PORT=3000

# Other configurations
GENERATE_SOURCEMAP=true
BROWSER=none
EOF
        fi
    else
        print_status "Frontend .env file already exists"
    fi
    
    # Test frontend build
    print_status "Testing frontend setup..."
    if yarn build --dry-run > /dev/null 2>&1; then
        print_status "Frontend build test successful"
    else
        print_warning "Frontend build test failed, but continuing..."
    fi
    
    cd "$PROJECT_DIR"
    print_status "Frontend setup completed"
}

# Create startup scripts
create_startup_scripts() {
    print_section "Creating Startup Scripts"
    
    cd "$PROJECT_DIR"
    
    # Create start script
    cat > start_portfolio.sh << 'EOF'
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
    if lsof -Pi :8001 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${RED}❌ Port 8001 is already in use${NC}"
        echo "Please stop the process using port 8001 or run: ./stop_portfolio.sh"
        exit 1
    fi
    
    if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
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
    echo "$BACKEND_PID,$FRONTEND_PID" > .portfolio_pids
    
    # Wait for Ctrl+C
    trap 'echo -e "\n${YELLOW}Stopping services...${NC}"; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; rm -f .portfolio_pids; echo -e "${GREEN}Services stopped${NC}"; exit' INT
    wait
}

# Run main function
main "$@"
EOF
#!/bin/bash

# Kamal Singh Portfolio - Start Script

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting Kamal Singh Portfolio...${NC}"

# Function to start backend
start_backend() {
    echo -e "${GREEN}Starting Backend...${NC}"
    cd backend
    source venv/bin/activate
    uvicorn server:app --host 0.0.0.0 --port 8001 --reload &
    BACKEND_PID=$!
    echo "Backend started with PID: $BACKEND_PID"
    cd ..
}

# Function to start frontend
start_frontend() {
    echo -e "${GREEN}Starting Frontend...${NC}"
    cd frontend
    yarn start &
    FRONTEND_PID=$!
    echo "Frontend started with PID: $FRONTEND_PID"
    cd ..
}

# Start services
start_backend
sleep 3
start_frontend

echo -e "${BLUE}Portfolio started successfully!${NC}"
echo "Frontend: http://localhost:3000"
echo "Backend API: http://localhost:8001"
echo "API Docs: http://localhost:8001/docs"
echo ""
echo "Press Ctrl+C to stop both services"

# Wait for Ctrl+C
trap 'echo "Stopping services..."; kill $BACKEND_PID $FRONTEND_PID; exit' INT
wait
EOF

    # Create stop script
    cat > stop_portfolio.sh << 'EOF'
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
pkill -f "yarn.*start" 2>/dev/null && echo "Stopped remaining yarn processes"

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
EOF
#!/bin/bash

# Kamal Singh Portfolio - Stop Script

echo "Stopping Kamal Singh Portfolio services..."

# Kill processes by port
if lsof -Pi :8001 -sTCP:LISTEN -t >/dev/null ; then
    echo "Stopping backend (port 8001)..."
    kill $(lsof -Pi :8001 -sTCP:LISTEN -t) 2>/dev/null
fi

if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
    echo "Stopping frontend (port 3000)..."
    kill $(lsof -Pi :3000 -sTCP:LISTEN -t) 2>/dev/null
fi

echo "All services stopped"
EOF

    # Make scripts executable
    chmod +x start_portfolio.sh
    chmod +x stop_portfolio.sh
    
    print_status "Startup scripts created:"
    print_status "  - start_portfolio.sh: Start both services"
    print_status "  - stop_portfolio.sh: Stop both services"
}

# Verify installation
verify_installation() {
    print_section "Verifying Installation"
    
    # Check prerequisites
    local all_good=true
    
    if command_exists node; then
        print_status "✅ Node.js: $(node --version)"
    else
        print_error "❌ Node.js not found"
        all_good=false
    fi
    
    if command_exists yarn; then
        print_status "✅ Yarn: $(yarn --version)"
    else
        print_error "❌ Yarn not found"
        all_good=false
    fi
    
    if command_exists python3; then
        print_status "✅ Python: $(python3 --version)"
    else
        print_error "❌ Python 3 not found"
        all_good=false
    fi
    
    if command_exists mongod; then
        print_status "✅ MongoDB installed"
    else
        print_error "❌ MongoDB not found"
        all_good=false
    fi
    
    # Check MongoDB service
    if [[ "$OS" == "linux" ]]; then
        if sudo systemctl is-active --quiet mongod; then
            print_status "✅ MongoDB service running"
        else
            print_warning "⚠️ MongoDB service not running"
        fi
    elif [[ "$OS" == "macos" ]]; then
        if brew services list | grep mongodb-community | grep started > /dev/null; then
            print_status "✅ MongoDB service running"
        else
            print_warning "⚠️ MongoDB service not running"
        fi
    fi
    
    # Check project files
    if [ -f "backend/requirements.txt" ]; then
        print_status "✅ Backend files found"
    else
        print_error "❌ Backend files missing"
        all_good=false
    fi
    
    if [ -f "frontend/package.json" ]; then
        print_status "✅ Frontend files found"
    else
        print_error "❌ Frontend files missing"
        all_good=false
    fi
    
    if [ -f "backend/.env" ]; then
        print_status "✅ Backend .env file created"
    else
        print_warning "⚠️ Backend .env file missing"
    fi
    
    if [ -f "frontend/.env" ]; then
        print_status "✅ Frontend .env file created"
    else
        print_warning "⚠️ Frontend .env file missing"
    fi
    
    if $all_good; then
        print_status "✅ All components verified successfully"
        return 0
    else
        print_error "❌ Some components failed verification"
        return 1
    fi
}

# Main execution
main() {
    print_section "Kamal Singh Portfolio - Automated Setup"
    
    # Check OS
    check_os
    
    # Ask for confirmation
    echo -e "${YELLOW}This script will install and configure:${NC}"
    echo "  - Node.js and Yarn"
    echo "  - Python 3 and pip"
    echo "  - MongoDB"
    echo "  - Project dependencies"
    echo "  - Environment configuration"
    echo ""
    
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Setup cancelled by user"
        exit 0
    fi
    
    # Install prerequisites
    install_prerequisites
    
    # Setup MongoDB
    setup_mongodb
    
    # Setup Backend
    setup_backend
    
    # Setup Frontend
    setup_frontend
    
    # Create startup scripts
    create_startup_scripts
    
    # Verify installation
    if verify_installation; then
        print_section "Setup Completed Successfully!"
        
        echo -e "${GREEN}Kamal Singh Portfolio is ready to run!${NC}"
        echo ""
        echo -e "${BLUE}To start the application:${NC}"
        echo "  ./start_portfolio.sh"
        echo ""
        echo -e "${BLUE}To stop the application:${NC}"
        echo "  ./stop_portfolio.sh"
        echo ""
        echo -e "${BLUE}Manual startup:${NC}"
        echo "  1. Backend: cd backend && source venv/bin/activate && uvicorn server:app --host 0.0.0.0 --port 8001 --reload"
        echo "  2. Frontend: cd frontend && yarn start"
        echo ""
        echo -e "${BLUE}Access URLs:${NC}"
        echo "  - Frontend: http://localhost:3000"
        echo "  - Backend API: http://localhost:8001"
        echo "  - API Documentation: http://localhost:8001/docs"
        echo ""
        echo -e "${GREEN}Setup completed successfully! 🎉${NC}"
        
    else
        print_section "Setup Completed with Issues"
        print_warning "Some components may not be working correctly."
        print_warning "Please check the error messages above and fix any issues."
        print_warning "You can also refer to DEPLOYMENT_GUIDE.md for manual setup instructions."
        exit 1
    fi
}

# Run main function
main "$@"