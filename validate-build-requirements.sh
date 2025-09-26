#!/bin/bash

# Validation Script for Docker Build Requirements
# Checks all dependencies and requirements before attempting to build

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

VALIDATION_PASSED=true

echo "🔍 Validating Docker Build Requirements..."
echo "============================================"

# Check Docker installation
print_status "Checking Docker installation..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | sed 's/,//')
    print_success "Docker found: $DOCKER_VERSION"
    
    # Check Docker daemon
    if docker info >/dev/null 2>&1; then
        print_success "Docker daemon is running"
    else
        print_error "Docker daemon is not running"
        VALIDATION_PASSED=false
    fi
else
    print_error "Docker is not installed"
    VALIDATION_PASSED=false
fi

# Check system resources
print_status "Checking system resources..."

# Check available disk space (need at least 5GB)
AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')
REQUIRED_SPACE=5242880  # 5GB in KB

if [ "$AVAILABLE_SPACE" -gt "$REQUIRED_SPACE" ]; then
    print_success "Sufficient disk space available: $(($AVAILABLE_SPACE/1048576))GB"
else
    print_warning "Low disk space: $(($AVAILABLE_SPACE/1048576))GB (recommended: 5GB+)"
fi

# Check available memory
if command -v free &> /dev/null; then
    AVAILABLE_MEM=$(free -m | awk 'NR==2{print $7}')
    if [ "$AVAILABLE_MEM" -gt 2048 ]; then
        print_success "Sufficient memory available: ${AVAILABLE_MEM}MB"
    else
        print_warning "Low memory: ${AVAILABLE_MEM}MB (recommended: 4GB+)"
    fi
fi

# Check required files exist
print_status "Checking required files..."

REQUIRED_FILES=(
    "Dockerfile.all-in-one"
    "frontend/package.json"
    "frontend/yarn.lock"
    "backend/requirements.txt"
    "nginx-all-in-one.conf"
    "supervisord-all-in-one.conf"
    "startup-all-in-one.sh"
    "healthcheck-all-in-one.sh"
    "frontend/env.template.js"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_success "Found: $file"
    else
        print_error "Missing: $file"
        VALIDATION_PASSED=false
    fi
done

# Check package.json for known problematic versions
print_status "Checking package.json for compatibility issues..."

if [ -f "frontend/package.json" ]; then
    # Check React version
    REACT_VERSION=$(grep '"react":' frontend/package.json | sed 's/.*"react": *"\([^"]*\)".*/\1/')
    if [[ "$REACT_VERSION" == ^19* ]]; then
        print_warning "React 19 detected ($REACT_VERSION) - may cause compatibility issues"
    else
        print_success "React version looks good: $REACT_VERSION"
    fi
    
    # Check React Router version
    ROUTER_VERSION=$(grep '"react-router-dom":' frontend/package.json | sed 's/.*"react-router-dom": *"\([^"]*\)".*/\1/')
    if [[ "$ROUTER_VERSION" == ^7* ]]; then
        print_warning "React Router 7+ detected ($ROUTER_VERSION) - may cause compatibility issues"
    else
        print_success "React Router version looks good: $ROUTER_VERSION"
    fi
fi

# Check requirements.txt for known issues
print_status "Checking requirements.txt for compatibility issues..."

if [ -f "backend/requirements.txt" ]; then
    # Check for version ranges that might cause conflicts
    if grep -q ">=" backend/requirements.txt; then
        print_warning "Found version ranges (>=) in requirements.txt - may cause conflicts"
        print_status "Consider pinning to specific versions for reproducible builds"
    else
        print_success "All Python packages have pinned versions"
    fi
    
    # Check for known problematic packages
    if grep -q "jq" backend/requirements.txt; then
        print_warning "Package 'jq' found - this is a command-line tool, not a Python package"
    fi
fi

# Check .dockerignore
print_status "Checking .dockerignore configuration..."

if [ -f ".dockerignore" ]; then
    print_success "Found .dockerignore"
    
    # Check if node_modules is ignored
    if grep -q "node_modules" .dockerignore; then
        print_success ".dockerignore includes node_modules"
    else
        print_warning ".dockerignore should include node_modules"
    fi
else
    print_warning ".dockerignore not found - build context may be larger than necessary"
fi

# Check network connectivity
print_status "Checking network connectivity..."

if curl -s --max-time 5 https://registry.hub.docker.com >/dev/null; then
    print_success "Docker Hub connectivity OK"
else
    print_warning "Cannot reach Docker Hub - may affect base image downloads"
fi

if curl -s --max-time 5 https://deb.nodesource.com >/dev/null; then
    print_success "NodeSource connectivity OK"
else
    print_warning "Cannot reach NodeSource - may affect Node.js installation"
fi

# Check for common build context issues
print_status "Checking build context..."

BUILD_CONTEXT_SIZE=$(du -s . 2>/dev/null | cut -f1)
if [ "$BUILD_CONTEXT_SIZE" -gt 1048576 ]; then  # 1GB
    print_warning "Large build context: $(($BUILD_CONTEXT_SIZE/1024))MB - consider optimizing .dockerignore"
else
    print_success "Build context size looks reasonable: $(($BUILD_CONTEXT_SIZE/1024))MB"
fi

# Final validation result
echo ""
echo "============================================"
if [ "$VALIDATION_PASSED" = true ]; then
    print_success "✅ All validations passed! Ready to build Docker image."
    echo ""
    echo "Recommended build command:"
    echo "  ./build-docker-fixed.sh"
    echo ""
    echo "Or manual build:"
    echo "  docker build -f Dockerfile.all-in-one -t kamal-singh-portfolio:latest ."
    exit 0
else
    print_error "❌ Validation failed! Please fix the issues above before building."
    echo ""
    echo "Common fixes:"
    echo "  - Install Docker and start the daemon"
    echo "  - Ensure all required files are present"
    echo "  - Fix package version conflicts"
    echo "  - Free up disk space"
    exit 1
fi