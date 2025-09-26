#!/bin/bash

# Docker Build Debug Script
# Helps identify what's causing build failures

set -e

echo "🔍 Docker Build Debug Analysis"
echo "=============================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check Docker
print_status "Checking Docker installation..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    print_success "Docker found: $DOCKER_VERSION"
else
    print_error "Docker not installed"
    exit 1
fi

# Check Docker daemon
print_status "Checking Docker daemon..."
if docker info >/dev/null 2>&1; then
    print_success "Docker daemon is running"
else
    print_error "Docker daemon is not running"
    exit 1
fi

# Check system resources
print_status "Checking system resources..."
AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')
SPACE_GB=$(($AVAILABLE_SPACE/1048576))
print_status "Available disk space: ${SPACE_GB}GB"

if [ "$SPACE_GB" -lt 5 ]; then
    print_warning "Low disk space (less than 5GB)"
fi

# Check required files
print_status "Checking required files..."
DOCKERFILES=("Dockerfile.reliable" "Dockerfile.simple-reliable" "Dockerfile.all-in-one")
for dockerfile in "${DOCKERFILES[@]}"; do
    if [ -f "$dockerfile" ]; then
        print_success "Found: $dockerfile"
    else
        print_warning "Missing: $dockerfile"
    fi
done

CONFIG_FILES=("nginx-simple.conf" "supervisord-all-in-one.conf" "startup-all-in-one.sh" "healthcheck-all-in-one.sh")
for config in "${CONFIG_FILES[@]}"; do
    if [ -f "$config" ]; then
        print_success "Found: $config"
    else
        print_error "Missing: $config"
    fi
done

# Check package files
print_status "Checking package configuration..."
if [ -f "frontend/package.json" ]; then
    print_success "Found: frontend/package.json"
    REACT_VERSION=$(grep '"react":' frontend/package.json | sed 's/.*"react": *"\([^"]*\)".*/\1/')
    print_status "React version: $REACT_VERSION"
    
    if [[ "$REACT_VERSION" == ^19* ]]; then
        print_warning "React 19 detected - may cause compatibility issues"
    else
        print_success "React version looks good"
    fi
else
    print_error "Missing: frontend/package.json"
fi

if [ -f "backend/requirements.txt" ]; then
    print_success "Found: backend/requirements.txt"
    
    # Check for version ranges
    if grep -q ">=" backend/requirements.txt; then
        print_warning "Version ranges found in requirements.txt"
    else
        print_success "All packages have pinned versions"
    fi
else
    print_error "Missing: backend/requirements.txt"
fi

# Check build context size
print_status "Checking build context..."
BUILD_SIZE=$(du -s . 2>/dev/null | cut -f1)
BUILD_SIZE_MB=$(($BUILD_SIZE/1024))
print_status "Build context size: ${BUILD_SIZE_MB}MB"

if [ "$BUILD_SIZE_MB" -gt 1024 ]; then
    print_warning "Large build context (>1GB) - consider optimizing .dockerignore"
fi

# Check .dockerignore
if [ -f ".dockerignore" ]; then
    print_success "Found: .dockerignore"
    
    if grep -q "node_modules" .dockerignore; then
        print_success ".dockerignore includes node_modules"
    else
        print_warning ".dockerignore should include node_modules"
    fi
else
    print_warning ".dockerignore not found"
fi

# Test individual build steps
print_status "Testing individual components..."

# Test nginx config syntax (basic)
if [ -f "nginx-simple.conf" ]; then
    # Basic syntax check
    if grep -q "server {" nginx-simple.conf && grep -q "}" nginx-simple.conf; then
        print_success "nginx-simple.conf has basic server block"
    else
        print_error "nginx-simple.conf missing server block"
    fi
fi

# Check for common issues in previous builds
print_status "Checking for previous build logs..."
for log in docker-build*.log; do
    if [ -f "$log" ]; then
        print_status "Found build log: $log"
        
        if grep -q "ERROR" "$log"; then
            print_error "Errors found in $log:"
            grep -A2 -B2 "ERROR" "$log" | tail -10
        fi
        
        if grep -q "nginx" "$log"; then
            print_status "Nginx-related messages in $log:"
            grep -i nginx "$log" | tail -5
        fi
    fi
done

# Network connectivity test
print_status "Testing network connectivity..."
if curl -s --max-time 5 https://deb.nodesource.com >/dev/null; then
    print_success "NodeSource reachable"
else
    print_warning "Cannot reach NodeSource"
fi

if curl -s --max-time 5 https://registry.hub.docker.com >/dev/null; then
    print_success "Docker Hub reachable"
else
    print_warning "Cannot reach Docker Hub"
fi

# Suggest next steps
echo ""
print_status "Recommendations:"
echo "1. Try the simple build: ./build-docker-simple.sh"
echo "2. For detailed output: docker build -f Dockerfile.simple-reliable -t test . --progress=plain"
echo "3. Check logs in: docker-build-simple.log"
echo ""
print_status "Debug analysis complete!"