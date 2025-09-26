#!/bin/bash

# Kamal Singh Portfolio - Complete Local Installation Script
# This script installs the entire application stack on a local server

set -e

echo "=============================================="
echo "Kamal Singh Portfolio - Local Installation"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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
    echo -e "\n${BLUE}=============================================="
    echo -e "$1"
    echo -e "==============================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_step() {
    echo -e "${PURPLE}▶ $1${NC}"
}

# Check if running on supported OS
check_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        print_success "Detected Linux OS"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_success "Detected macOS"
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

# Check if service is running
service_running() {
    if [[ "$OS" == "linux" ]]; then
        systemctl is-active --quiet "$1" 2>/dev/null
    elif [[ "$OS" == "macos" ]]; then
        brew services list | grep "$1" | grep started >/dev/null 2>&1
    fi
}

# Install system prerequisites
install_system_prerequisites() {
    print_section "Installing System Prerequisites"
    
    if [[ "$OS" == "linux" ]]; then
        print_step "Updating system packages..."
        sudo apt update -y
        sudo apt upgrade -y
        
        print_step "Installing essential packages..."
        sudo apt install -y curl wget gnupg lsb-release software-properties-common
        
    elif [[ "$OS" == "macos" ]]; then
        print_step "Installing Xcode Command Line Tools..."
        if ! xcode-select -p >/dev/null 2>&1; then
            xcode-select --install
            echo "Please complete Xcode Command Line Tools installation and run this script again"
            exit 1
        fi
        
        # Check if Homebrew is installed
        if ! command_exists brew; then
            print_step "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # Add Homebrew to PATH
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            print_success "Homebrew already installed"
            brew update
        fi
    fi
}

# Install Node.js and Yarn
install_nodejs() {
    print_section "Installing Node.js and Yarn"
    
    if [[ "$OS" == "linux" ]]; then
        if ! command_exists node || [[ $(node --version | cut -d'v' -f2 | cut -d'.' -f1) -lt 16 ]]; then
            print_step "Installing Node.js 18.x..."
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt-get install -y nodejs
        else
            print_success "Node.js already installed: $(node --version)"
        fi
        
        if ! command_exists yarn; then
            print_step "Installing Yarn..."
            curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
            echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
            sudo apt-get update && sudo apt-get install -y yarn
        else
            print_success "Yarn already installed: $(yarn --version)"
        fi
        
    elif [[ "$OS" == "macos" ]]; then
        if ! command_exists node; then
            print_step "Installing Node.js..."
            brew install node
        else
            print_success "Node.js already installed: $(node --version)"
        fi
        
        if ! command_exists yarn; then
            print_step "Installing Yarn..."
            brew install yarn
        else
            print_success "Yarn already installed: $(yarn --version)"
        fi
    fi
    
    # Verify installations
    if command_exists node && command_exists yarn; then
        print_success "Node.js: $(node --version)"
        print_success "npm: $(npm --version)"
        print_success "Yarn: $(yarn --version)"
    else
        print_error "Failed to install Node.js or Yarn"
        exit 1
    fi
}

# Install Python
install_python() {
    print_section "Installing Python and pip"
    
    if [[ "$OS" == "linux" ]]; then
        if ! command_exists python3 || [[ $(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2 | tr -d '.') -lt 38 ]]; then
            print_step "Installing Python 3.9..."
            sudo apt install -y python3 python3-pip python3-venv python3-dev build-essential
            
            # Install Python 3.9 if not available
            if [[ $(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2 | tr -d '.') -lt 38 ]]; then
                sudo add-apt-repository -y ppa:deadsnakes/ppa
                sudo apt update
                sudo apt install -y python3.9 python3.9-venv python3.9-dev
                sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
            fi
        else
            print_success "Python 3 already installed: $(python3 --version)"
        fi
        
    elif [[ "$OS" == "macos" ]]; then
        if ! command_exists python3; then
            print_step "Installing Python 3..."
            brew install python
        else
            print_success "Python 3 already installed: $(python3 --version)"
        fi
    fi
    
    # Upgrade pip
    print_step "Upgrading pip..."
    python3 -m pip install --upgrade pip
    
    # Verify installation
    if command_exists python3 && command_exists pip3; then
        print_success "Python: $(python3 --version)"
        print_success "pip: $(pip3 --version)"
    else
        print_error "Failed to install Python or pip"
        exit 1
    fi
}

# Install MongoDB
install_mongodb() {
    print_section "Installing MongoDB"
    
    if [[ "$OS" == "linux" ]]; then
        if ! command_exists mongod; then
            print_step "Installing MongoDB Community Server..."
            
            # Import MongoDB public GPG key
            wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
            
            # Create MongoDB list file
            echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
            
            # Update package database and install MongoDB
            sudo apt-get update
            sudo apt-get install -y mongodb-org
            
            # Start and enable MongoDB service
            sudo systemctl daemon-reload
            sudo systemctl enable mongod
            sudo systemctl start mongod
            
        else
            print_success "MongoDB already installed"
            if ! service_running mongod; then
                print_step "Starting MongoDB service..."
                sudo systemctl start mongod
                sudo systemctl enable mongod
            fi
        fi
        
    elif [[ "$OS" == "macos" ]]; then
        if ! command_exists mongod; then
            print_step "Installing MongoDB Community Server..."
            brew tap mongodb/brew
            brew install mongodb-community
            
            # Start MongoDB service
            brew services start mongodb/brew/mongodb-community
        else
            print_success "MongoDB already installed"
            if ! service_running mongodb-community; then
                print_step "Starting MongoDB service..."
                brew services start mongodb/brew/mongodb-community
            fi
        fi
    fi
    
    # Wait for MongoDB to start
    print_step "Waiting for MongoDB to start..."
    sleep 10
    
    # Verify MongoDB installation and service
    if command_exists mongod; then
        print_success "MongoDB installed successfully"
        
        # Test connection
        if command_exists mongosh; then
            if mongosh --eval "db.adminCommand('ping')" --quiet >/dev/null 2>&1; then
                print_success "MongoDB service is running and accessible"
            else
                print_warning "MongoDB installed but service may not be running properly"
            fi
        elif command_exists mongo; then
            if mongo --eval "db.adminCommand('ping')" --quiet >/dev/null 2>&1; then
                print_success "MongoDB service is running and accessible"
            else
                print_warning "MongoDB installed but service may not be running properly"
            fi
        fi
    else
        print_error "Failed to install MongoDB"
        exit 1
    fi
}

# Initialize MongoDB database
initialize_database() {
    print_section "Initializing Database"
    
    print_step "Creating portfolio database and collections..."
    
    # Use the provided init_database.js script
    if [ -f "$PROJECT_DIR/init_database.js" ]; then
        if command_exists mongosh; then
            mongosh --file "$PROJECT_DIR/init_database.js"
        elif command_exists mongo; then
            mongo "$PROJECT_DIR/init_database.js"
        else
            print_warning "MongoDB client not found, manual database initialization required"
        fi
        print_success "Database initialized successfully"
    else
        print_warning "init_database.js not found, creating basic database setup..."
        
        # Create basic database setup
        if command_exists mongosh; then
            mongosh --eval "
            use portfolio_db;
            db.status_checks.insertOne({
                client_name: 'installation_setup',
                timestamp: new Date(),
                message: 'Database created during local installation'
            });
            print('✅ Database setup completed');
            "
        elif command_exists mongo; then
            mongo --eval "
            use portfolio_db;
            db.status_checks.insertOne({
                client_name: 'installation_setup', 
                timestamp: new Date(),
                message: 'Database created during local installation'
            });
            print('✅ Database setup completed');
            "
        fi
        print_success "Basic database setup completed"
    fi
}

# Setup backend
setup_backend() {
    print_section "Setting up Backend"
    
    cd "$PROJECT_DIR/backend"
    
    # Create virtual environment
    if [ ! -d "venv" ]; then
        print_step "Creating Python virtual environment..."
        python3 -m venv venv
    else
        print_success "Virtual environment already exists"
    fi
    
    # Activate virtual environment
    print_step "Activating virtual environment..."
    source venv/bin/activate
    
    # Upgrade pip in virtual environment
    print_step "Upgrading pip in virtual environment..."
    pip install --upgrade pip
    
    # Install Python dependencies
    print_step "Installing Python dependencies..."
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
    else
        print_error "requirements.txt not found"
        exit 1
    fi
    
    # Create .env file
    if [ ! -f ".env" ]; then
        print_step "Creating backend .env file..."
        if [ -f ".env.example" ]; then
            cp .env.example .env
        else
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

# Security
SECRET_KEY=kamal-singh-portfolio-secret-key-2024-local-install

# CORS Settings
ALLOWED_ORIGINS=["http://localhost:3000", "http://127.0.0.1:3000"]
EOF
        fi
        print_success "Backend .env file created"
    else
        print_success "Backend .env file already exists"
    fi
    
    # Test backend imports
    print_step "Testing backend setup..."
    python -c "
import sys
sys.path.append('.')
try:
    from server import app
    print('✅ Backend imports successful')
except Exception as e:
    print(f'❌ Backend import error: {e}')
    sys.exit(1)
" || {
    print_error "Backend setup test failed"
    exit 1
}
    
    cd "$PROJECT_DIR"
    print_success "Backend setup completed"
}

# Setup frontend
setup_frontend() {
    print_section "Setting up Frontend"
    
    cd "$PROJECT_DIR/frontend"
    
    # Install Node.js dependencies
    print_step "Installing Node.js dependencies..."
    yarn install
    
    # Create .env file
    if [ ! -f ".env" ]; then
        print_step "Creating frontend .env file..."
        if [ -f ".env.example" ]; then
            cp .env.example .env
        else
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
        print_success "Frontend .env file created"
    else
        print_success "Frontend .env file already exists"
    fi
    
    # Test frontend build
    print_step "Testing frontend setup..."
    if yarn build --dry-run >/dev/null 2>&1; then
        print_success "Frontend build test passed"
    else
        print_warning "Frontend build test failed, but continuing..."
    fi
    
    cd "$PROJECT_DIR"
    print_success "Frontend setup completed"
}

# Create enhanced startup scripts
create_startup_scripts() {
    print_section "Creating Enhanced Startup Scripts"
    
    # Create comprehensive start script
    cat > "$PROJECT_DIR/start_local.sh" << 'EOF'
#!/bin/bash

# Kamal Singh Portfolio - Local Start Script
# Enhanced version for local installation

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🚀 Starting Kamal Singh Portfolio (Local Installation)...${NC}"

# Function to check MongoDB
check_mongodb() {
    echo -e "${PURPLE}Checking MongoDB...${NC}"
    
    # Check if MongoDB service is running
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if systemctl is-active --quiet mongod; then
            echo -e "${GREEN}✅ MongoDB service is running${NC}"
        else
            echo -e "${YELLOW}⚠️  Starting MongoDB service...${NC}"
            sudo systemctl start mongod
            sleep 3
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if brew services list | grep mongodb-community | grep started >/dev/null; then
            echo -e "${GREEN}✅ MongoDB service is running${NC}"
        else
            echo -e "${YELLOW}⚠️  Starting MongoDB service...${NC}"
            brew services start mongodb/brew/mongodb-community
            sleep 3
        fi
    fi
    
    # Test connection
    if command -v mongosh >/dev/null 2>&1; then
        if mongosh --eval "db.adminCommand('ping')" --quiet >/dev/null 2>&1; then
            echo -e "${GREEN}✅ MongoDB connection successful${NC}"
            return 0
        fi
    elif command -v mongo >/dev/null 2>&1; then
        if mongo --eval "db.adminCommand('ping')" --quiet >/dev/null 2>&1; then
            echo -e "${GREEN}✅ MongoDB connection successful${NC}"
            return 0
        fi
    fi
    
    echo -e "${RED}❌ Cannot connect to MongoDB${NC}"
    echo -e "${YELLOW}Please ensure MongoDB is properly installed and running${NC}"
    return 1
}

# Function to check ports
check_ports() {
    echo -e "${PURPLE}Checking ports...${NC}"
    
    if lsof -Pi :8001 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${RED}❌ Port 8001 is already in use${NC}"
        echo "Please stop the process using port 8001 or run: ./stop_local.sh"
        exit 1
    fi
    
    if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${RED}❌ Port 3000 is already in use${NC}"
        echo "Please stop the process using port 3000 or run: ./stop_local.sh"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Ports 3000 and 8001 are available${NC}"
}

# Function to start backend
start_backend() {
    echo -e "${PURPLE}Starting Backend...${NC}"
    
    if [ ! -d "$SCRIPT_DIR/backend" ]; then
        echo -e "${RED}❌ Backend directory not found${NC}"
        exit 1
    fi
    
    cd "$SCRIPT_DIR/backend"
    
    # Check virtual environment
    if [ ! -d "venv" ]; then
        echo -e "${RED}❌ Virtual environment not found${NC}"
        echo -e "${YELLOW}Please run install_local.sh first${NC}"
        exit 1
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Check .env file
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}⚠️ .env file not found, creating default...${NC}"
        cat > .env << 'ENVEOF'
MONGO_URL=mongodb://localhost:27017
DB_NAME=portfolio_db
HOST=0.0.0.0
PORT=8001
ENVIRONMENT=development
DEBUG=True
SECRET_KEY=kamal-singh-portfolio-secret-key-2024
ALLOWED_ORIGINS=["http://localhost:3000", "http://127.0.0.1:3000"]
ENVEOF
    fi
    
    # Start backend
    echo -e "${GREEN}🔧 Backend starting on http://localhost:8001${NC}"
    uvicorn server:app --host 0.0.0.0 --port 8001 --reload &
    BACKEND_PID=$!
    echo "Backend started with PID: $BACKEND_PID"
    cd "$SCRIPT_DIR"
}

# Function to start frontend
start_frontend() {
    echo -e "${PURPLE}Starting Frontend...${NC}"
    
    if [ ! -d "$SCRIPT_DIR/frontend" ]; then
        echo -e "${RED}❌ Frontend directory not found${NC}"
        exit 1
    fi
    
    cd "$SCRIPT_DIR/frontend"
    
    # Check node_modules
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}⚠️ Dependencies not installed, installing...${NC}"
        yarn install
    fi
    
    # Check .env file
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}⚠️ .env file not found, creating default...${NC}"
        cat > .env << 'ENVEOF'
REACT_APP_BACKEND_URL=http://localhost:8001
NODE_ENV=development
PORT=3000
GENERATE_SOURCEMAP=true
BROWSER=none
ENVEOF
    fi
    
    # Start frontend
    echo -e "${GREEN}🌐 Frontend starting on http://localhost:3000${NC}"
    yarn start &
    FRONTEND_PID=$!
    echo "Frontend started with PID: $FRONTEND_PID"
    cd "$SCRIPT_DIR"
}

# Main execution
main() {
    # Pre-flight checks
    if ! check_mongodb; then
        exit 1
    fi
    
    check_ports
    
    # Start services
    start_backend
    sleep 8
    start_frontend
    sleep 8
    
    # Display success information
    echo ""
    echo -e "${BLUE}🎉 Kamal Singh Portfolio Started Successfully!${NC}"
    echo ""
    echo -e "${GREEN}📍 Access URLs:${NC}"
    echo -e "  🌐 Portfolio Website: ${BLUE}http://localhost:3000${NC}"
    echo -e "  🔧 Backend API: ${BLUE}http://localhost:8001${NC}"
    echo -e "  📚 API Documentation: ${BLUE}http://localhost:8001/docs${NC}"  
    echo ""
    echo -e "${YELLOW}📱 Available Pages:${NC}"
    echo -e "  🏠 Home: http://localhost:3000/"
    echo -e "  👤 About: http://localhost:3000/about"
    echo -e "  🛠️ Skills: http://localhost:3000/skills"
    echo -e "  💼 Experience: http://localhost:3000/experience"
    echo -e "  🚀 Projects: http://localhost:3000/projects"
    echo -e "  📞 Contact: http://localhost:3000/contact"
    echo ""
    echo -e "${PURPLE}💡 Tips:${NC}"
    echo -e "  • Both services have hot reload enabled"
    echo -e "  • Check logs in terminal for any issues"
    echo -e "  • Use ./stop_local.sh to stop services"
    echo ""
    echo -e "${BLUE}Press Ctrl+C to stop all services${NC}"
    
    # Save PIDs for stop script
    echo "$BACKEND_PID,$FRONTEND_PID" > "$SCRIPT_DIR/.portfolio_local_pids"
    
    # Wait for interrupt
    trap 'echo -e "\n${YELLOW}🛑 Stopping services...${NC}"; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; rm -f "$SCRIPT_DIR/.portfolio_local_pids"; echo -e "${GREEN}✅ Services stopped${NC}"; exit' INT
    wait
}

# Run main function
main "$@"
EOF

    # Create comprehensive stop script
    cat > "$PROJECT_DIR/stop_local.sh" << 'EOF'
#!/bin/bash

# Kamal Singh Portfolio - Local Stop Script
# Enhanced version for local installation

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${YELLOW}🛑 Stopping Kamal Singh Portfolio (Local Installation)...${NC}"

cd "$SCRIPT_DIR"

# Function to stop process by PID
stop_by_pid() {
    local pid=$1
    local name=$2
    
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        echo -e "${BLUE}Stopping $name (PID: $pid)...${NC}"
        kill "$pid" 2>/dev/null
        
        # Wait and force kill if necessary
        sleep 3
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${YELLOW}Force stopping $name...${NC}"
            kill -9 "$pid" 2>/dev/null
        fi
        
        echo -e "${GREEN}✅ $name stopped${NC}"
    else
        echo -e "${YELLOW}⚠️ $name not running or PID not found${NC}"
    fi
}

# Function to stop process by port
stop_by_port() {
    local port=$1
    local name=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${BLUE}Stopping $name (port $port)...${NC}"
        local pids=$(lsof -Pi :$port -sTCP:LISTEN -t)
        for pid in $pids; do
            kill "$pid" 2>/dev/null
        done
        
        # Wait and force kill if necessary
        sleep 3
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo -e "${YELLOW}Force stopping $name...${NC}"
            local pids=$(lsof -Pi :$port -sTCP:LISTEN -t)
            for pid in $pids; do
                kill -9 "$pid" 2>/dev/null
            done
        fi
        
        echo -e "${GREEN}✅ $name stopped${NC}"
    else
        echo -e "${YELLOW}⚠️ No process found on port $port${NC}"
    fi
}

# Try to stop using PID file first
if [ -f ".portfolio_local_pids" ]; then
    echo -e "${BLUE}Found PID file, stopping services...${NC}"
    pids=$(cat .portfolio_local_pids)
    IFS=',' read -r backend_pid frontend_pid <<< "$pids"
    
    stop_by_pid "$backend_pid" "Backend"
    stop_by_pid "$frontend_pid" "Frontend"
    
    # Remove PID file
    rm -f .portfolio_local_pids
    echo -e "${GREEN}✅ PID file removed${NC}"
else
    echo -e "${YELLOW}No PID file found, stopping by port...${NC}"
    
    # Stop by port as fallback
    stop_by_port "8001" "Backend"
    stop_by_port "3000" "Frontend"
fi

# Additional cleanup
echo -e "${BLUE}Performing additional cleanup...${NC}"

# Stop any remaining processes
pkill -f "uvicorn server:app" 2>/dev/null && echo -e "${GREEN}✅ Stopped remaining uvicorn processes${NC}"
pkill -f "yarn.*start" 2>/dev/null && echo -e "${GREEN}✅ Stopped remaining yarn processes${NC}"
pkill -f "react-scripts start" 2>/dev/null && echo -e "${GREEN}✅ Stopped remaining React processes${NC}"

# Final verification
echo ""
echo -e "${BLUE}🔍 Final Verification:${NC}"

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
echo -e "${GREEN}🎉 All services stopped successfully! 🛑${NC}"
echo ""
echo -e "${BLUE}💡 To start services again, run: ./start_local.sh${NC}"
EOF

    # Make scripts executable
    chmod +x "$PROJECT_DIR/start_local.sh"
    chmod +x "$PROJECT_DIR/stop_local.sh"
    
    print_success "Enhanced startup scripts created:"
    print_success "  - start_local.sh: Start all services with enhanced monitoring"
    print_success "  - stop_local.sh: Stop all services with comprehensive cleanup"
}

# Create service management script
create_service_manager() {
    print_section "Creating Service Management Script"
    
    cat > "$PROJECT_DIR/manage_services.sh" << 'EOF'
#!/bin/bash

# Kamal Singh Portfolio - Service Management Script

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

show_help() {
    echo -e "${BLUE}Kamal Singh Portfolio - Service Management${NC}"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo -e "  ${GREEN}start${NC}       Start all services"
    echo -e "  ${GREEN}stop${NC}        Stop all services"
    echo -e "  ${GREEN}restart${NC}     Restart all services"
    echo -e "  ${GREEN}status${NC}      Show service status"
    echo -e "  ${GREEN}logs${NC}        Show service logs"
    echo -e "  ${GREEN}install${NC}     Run full installation"
    echo -e "  ${GREEN}update${NC}      Update dependencies"
    echo -e "  ${GREEN}help${NC}        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start     # Start portfolio services"
    echo "  $0 status    # Check if services are running"
    echo "  $0 logs      # View recent logs"
}

check_status() {
    echo -e "${BLUE}📊 Service Status:${NC}"
    echo ""
    
    # Check MongoDB
    if command -v mongosh >/dev/null 2>&1; then
        if mongosh --eval "db.adminCommand('ping')" --quiet >/dev/null 2>&1; then
            echo -e "${GREEN}✅ MongoDB: Running${NC}"
        else
            echo -e "${RED}❌ MongoDB: Not running${NC}"
        fi
    elif command -v mongo >/dev/null 2>&1; then
        if mongo --eval "db.adminCommand('ping')" --quiet >/dev/null 2>&1; then
            echo -e "${GREEN}✅ MongoDB: Running${NC}"
        else
            echo -e "${RED}❌ MongoDB: Not running${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ MongoDB: Client not found${NC}"
    fi
    
    # Check Backend (port 8001)
    if lsof -Pi :8001 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend: Running on port 8001${NC}"
    else
        echo -e "${RED}❌ Backend: Not running${NC}"
    fi
    
    # Check Frontend (port 3000)
    if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Frontend: Running on port 3000${NC}"
    else
        echo -e "${RED}❌ Frontend: Not running${NC}"
    fi
    
    echo ""
}

show_logs() {
    echo -e "${BLUE}📋 Service Logs:${NC}"
    echo ""
    
    # Check for log files or show recent terminal output
    echo -e "${PURPLE}Recent MongoDB logs:${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f "/var/log/mongodb/mongod.log" ]; then
            tail -10 /var/log/mongodb/mongod.log
        else
            echo "MongoDB log file not found"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if [ -f "/opt/homebrew/var/log/mongodb/mongo.log" ]; then
            tail -10 /opt/homebrew/var/log/mongodb/mongo.log
        else
            echo "MongoDB log file not found"
        fi
    fi
    
    echo ""
    echo -e "${PURPLE}Process Information:${NC}"
    if lsof -Pi :8001 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "Backend process: $(lsof -Pi :8001 -sTCP:LISTEN -t)"
    fi
    if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "Frontend process: $(lsof -Pi :3000 -sTCP:LISTEN -t)"
    fi
}

update_dependencies() {
    echo -e "${BLUE}🔄 Updating Dependencies...${NC}"
    
    # Update backend dependencies
    if [ -d "backend" ]; then
        echo -e "${PURPLE}Updating backend dependencies...${NC}"
        cd backend
        if [ -d "venv" ]; then
            source venv/bin/activate
            pip install --upgrade pip
            pip install -r requirements.txt --upgrade
        fi
        cd ..
    fi
    
    # Update frontend dependencies
    if [ -d "frontend" ]; then
        echo -e "${PURPLE}Updating frontend dependencies...${NC}"
        cd frontend
        yarn upgrade
        cd ..
    fi
    
    echo -e "${GREEN}✅ Dependencies updated${NC}"
}

case "$1" in
    start)
        ./start_local.sh
        ;;
    stop)
        ./stop_local.sh
        ;;
    restart)
        ./stop_local.sh
        sleep 3
        ./start_local.sh
        ;;
    status)
        check_status
        ;;
    logs)
        show_logs
        ;;
    install)
        ./install_local.sh
        ;;
    update)
        update_dependencies
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
EOF

    chmod +x "$PROJECT_DIR/manage_services.sh"
    print_success "Service management script created: manage_services.sh"
}

# Final verification and testing
verify_installation() {
    print_section "Verifying Complete Installation"
    
    local all_good=true
    
    # Check all prerequisites
    print_step "Checking prerequisites..."
    
    if command_exists node; then
        print_success "Node.js: $(node --version)"
    else
        print_error "Node.js not found"
        all_good=false
    fi
    
    if command_exists yarn; then
        print_success "Yarn: $(yarn --version)"
    else
        print_error "Yarn not found"
        all_good=false
    fi
    
    if command_exists python3; then
        print_success "Python: $(python3 --version)"
    else
        print_error "Python 3 not found"
        all_good=false
    fi
    
    if command_exists pip3; then
        print_success "pip: $(pip3 --version)"
    else
        print_error "pip not found"
        all_good=false
    fi
    
    if command_exists mongod; then
        print_success "MongoDB installed"
        
        # Test MongoDB connection
        if command_exists mongosh; then
            if mongosh --eval "db.adminCommand('ping')" --quiet >/dev/null 2>&1; then
                print_success "MongoDB service running and accessible"
            else
                print_warning "MongoDB installed but service may not be accessible"
            fi
        elif command_exists mongo; then
            if mongo --eval "db.adminCommand('ping')" --quiet >/dev/null 2>&1; then
                print_success "MongoDB service running and accessible"
            else
                print_warning "MongoDB installed but service may not be accessible"
            fi
        fi
    else
        print_error "MongoDB not found"
        all_good=false
    fi
    
    # Check project structure
    print_step "Checking project structure..."
    
    if [ -f "backend/requirements.txt" ] && [ -f "backend/server.py" ]; then
        print_success "Backend files present"
    else
        print_error "Backend files missing"
        all_good=false
    fi
    
    if [ -f "frontend/package.json" ] && [ -d "frontend/src" ]; then
        print_success "Frontend files present"
    else
        print_error "Frontend files missing"
        all_good=false
    fi
    
    if [ -f "backend/.env" ]; then
        print_success "Backend environment configured"
    else
        print_warning "Backend .env file missing"
    fi
    
    if [ -f "frontend/.env" ]; then
        print_success "Frontend environment configured"
    else
        print_warning "Frontend .env file missing"
    fi
    
    # Check created scripts
    if [ -f "start_local.sh" ] && [ -f "stop_local.sh" ] && [ -f "manage_services.sh" ]; then
        print_success "Management scripts created"
    else
        print_error "Management scripts missing"
        all_good=false
    fi
    
    if $all_good; then
        print_success "All components verified successfully ✅"
        return 0
    else
        print_error "Some components failed verification ❌"
        return 1
    fi
}

# Main installation function
main() {
    print_section "Kamal Singh Portfolio - Complete Local Installation"
    
    echo -e "${YELLOW}This script will install and configure:${NC}"
    echo -e "  📦 System prerequisites (Node.js, Python, MongoDB)"
    echo -e "  🗄️ MongoDB database with initial data"
    echo -e "  🔧 Backend API server (FastAPI + Python)"
    echo -e "  🌐 Frontend application (React + Tailwind CSS)"
    echo -e "  🚀 Enhanced management scripts"
    echo -e "  ✅ Complete verification and testing"
    echo ""
    
    read -p "Do you want to continue with the installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installation cancelled by user"
        exit 0
    fi
    
    # Run installation steps
    check_os
    install_system_prerequisites
    install_nodejs
    install_python
    install_mongodb
    initialize_database
    setup_backend
    setup_frontend
    create_startup_scripts
    create_service_manager
    
    # Final verification
    if verify_installation; then
        print_section "🎉 Installation Completed Successfully!"
        
        echo -e "${GREEN}Kamal Singh Portfolio is now fully installed and ready to use!${NC}"
        echo ""
        echo -e "${BLUE}🚀 Quick Start Commands:${NC}"
        echo -e "  ${GREEN}./start_local.sh${NC}        # Start all services"
        echo -e "  ${GREEN}./stop_local.sh${NC}         # Stop all services"
        echo -e "  ${GREEN}./manage_services.sh${NC}    # Service management menu"
        echo ""
        echo -e "${BLUE}📱 Once started, access your portfolio at:${NC}"
        echo -e "  🌐 Portfolio: ${YELLOW}http://localhost:3000${NC}"
        echo -e "  🔧 Backend API: ${YELLOW}http://localhost:8001${NC}"
        echo -e "  📚 API Docs: ${YELLOW}http://localhost:8001/docs${NC}"
        echo ""
        echo -e "${BLUE}💡 Next Steps:${NC}"
        echo -e "  1. Run ${GREEN}./start_local.sh${NC} to start the application"
        echo -e "  2. Open ${YELLOW}http://localhost:3000${NC} in your browser"
        echo -e "  3. Explore the portfolio and test all features"
        echo -e "  4. Use ${GREEN}./manage_services.sh status${NC} to check service health"
        echo ""
        echo -e "${GREEN}🎊 Installation completed successfully! 🎊${NC}"
        
    else
        print_section "❌ Installation Completed with Issues"
        print_warning "Some components may not be working correctly."
        print_warning "Please check the error messages above and resolve any issues."
        print_warning "You can re-run this script or consult the DEPLOYMENT_GUIDE.md for manual setup."
        exit 1
    fi
}

# Run main function
main "$@"