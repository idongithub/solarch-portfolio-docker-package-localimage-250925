#!/bin/bash

# Simple Docker Build - Absolute Paths
# This script uses absolute paths and cannot fail

set -e

echo "🚀 Simple Docker Build (Absolute Paths)"
echo "======================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Always use absolute path to /app
PROJECT_DIR="/app"
cd "$PROJECT_DIR"

print_status "Working directory: $(pwd)"

# Verify Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker not found. Please install Docker."
    exit 1
fi

print_success "Docker is available"

# Verify project structure
if [ ! -d "$PROJECT_DIR/frontend" ]; then
    print_error "Frontend directory not found at $PROJECT_DIR/frontend"
    print_status "Directory contents:"
    ls -la "$PROJECT_DIR"
    exit 1
fi

print_success "Frontend directory found"

if [ ! -f "$PROJECT_DIR/frontend/package.json" ]; then
    print_error "package.json not found"
    exit 1
fi

print_success "package.json found"

# Check yarn.lock
if [ ! -f "$PROJECT_DIR/frontend/yarn.lock" ]; then
    print_status "Regenerating yarn.lock..."
    cd "$PROJECT_DIR/frontend"
    rm -f yarn.lock
    yarn install
    cd "$PROJECT_DIR"
    print_success "yarn.lock created"
else
    print_success "yarn.lock exists"
fi

# Create simple Dockerfile with explicit paths
print_status "Creating Dockerfile..."
cat > "$PROJECT_DIR/Dockerfile.simple" << 'EOF'
FROM node:18-alpine

RUN apk add --no-cache curl

WORKDIR /app

# Copy package.json
COPY frontend/package.json ./package.json

# Install yarn
RUN npm install -g yarn

# Copy yarn.lock
COPY frontend/yarn.lock ./yarn.lock

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy all frontend files
COPY frontend/ ./

# Build
RUN yarn build

# Install serve
RUN npm install -g serve

EXPOSE 3000

CMD ["serve", "-s", "build", "-l", "3000"]
EOF

print_success "Dockerfile created"

# Clean Docker
print_status "Cleaning Docker cache..."
docker system prune -f >/dev/null 2>&1 || true

# Build
print_status "Building Docker image (this may take 3-5 minutes)..."
if docker build -f "$PROJECT_DIR/Dockerfile.simple" -t portfolio-simple "$PROJECT_DIR" > "$PROJECT_DIR/build-simple.log" 2>&1; then
    print_success "✅ BUILD SUCCESSFUL!"
    
    # Test
    print_status "Testing container..."
    docker stop portfolio-test 2>/dev/null || true
    docker rm portfolio-test 2>/dev/null || true
    
    CONTAINER_ID=$(docker run -d -p 3004:3000 --name portfolio-test portfolio-simple)
    if [ $? -eq 0 ]; then
        print_success "Container started: $CONTAINER_ID"
        sleep 10
        
        if curl -f -s http://localhost:3004 >/dev/null 2>&1; then
            print_success "🎉 APPLICATION WORKING!"
            echo ""
            echo "✅ Your IT Portfolio is ready!"
            echo ""
            echo "🚀 To deploy:"
            echo "   docker run -d -p 80:3000 --name kamal-portfolio portfolio-simple"
            echo ""
            echo "🌐 Visit: http://localhost"
        else
            print_status "Application may still be loading..."
        fi
        
        docker stop portfolio-test >/dev/null 2>&1 || true
        docker rm portfolio-test >/dev/null 2>&1 || true
    else
        print_error "Container failed to start"
        exit 1
    fi
else
    print_error "Build failed"
    echo "Last 20 lines of build log:"
    tail -20 "$PROJECT_DIR/build-simple.log"
    exit 1
fi

print_success "🎯 BUILD COMPLETED!"
echo ""
echo "Image: portfolio-simple"
echo "Deploy: docker run -d -p 80:3000 --name kamal-portfolio portfolio-simple"