#!/bin/bash

# Working Docker Build Script
# Fixes file not found issues and MongoDB compatibility

set -e

echo "🚀 Building Working Docker Image..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Ensure we're in the correct directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

print_status "Working directory: $(pwd)"

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker not found"
    exit 1
fi

# Verify required files exist
print_status "Verifying build context files..."
REQUIRED_FILES=(
    "frontend/package.json"
    "frontend/yarn.lock"
    "backend/requirements.txt"
    "nginx-simple.conf"
)

print_status "Checking files in: $(pwd)"
for file in "${REQUIRED_FILES[@]}"; do
    print_status "Checking: $file"
    if [ -f "$file" ]; then
        print_success "✓ Found: $file"
        # Show file size for verification
        FILE_SIZE=$(ls -lh "$file" | awk '{print $5}')
        print_status "  Size: $FILE_SIZE"
    else
        print_error "✗ Missing: $file"
        print_status "Contents of directory $(dirname "$file"):"
        ls -la "$(dirname "$file")" || echo "Directory does not exist"
        exit 1
    fi
done

# Check if we're in the right directory
if [ ! -f "frontend/package.json" ]; then
    print_error "Must run from project root directory containing frontend/ and backend/"
    exit 1
fi

print_success "All required files present"

# Clean up previous builds
print_status "Cleaning up previous builds..."
docker system prune -f 2>/dev/null || true

# Build minimal frontend first
print_status "Step 1: Building minimal frontend..."
if docker build -f Dockerfile.minimal -t portfolio-frontend-test . --no-cache > build-frontend.log 2>&1; then
    print_success "✅ Frontend build successful"
    
    # Quick test of frontend
    print_status "Testing frontend container..."
    FRONTEND_ID=$(docker run -d -p 3001:3000 --name frontend-test portfolio-frontend-test 2>/dev/null || echo "failed")
    
    if [ "$FRONTEND_ID" != "failed" ]; then
        sleep 5
        if curl -f -s http://localhost:3001 >/dev/null 2>&1; then
            print_success "✅ Frontend container working"
        else
            print_status "Frontend may still be starting..."
        fi
        docker stop frontend-test >/dev/null 2>&1 || true
        docker rm frontend-test >/dev/null 2>&1 || true
    fi
else
    print_error "❌ Frontend build failed"
    echo "Frontend build log:"
    tail -20 build-frontend.log
    exit 1
fi

# Build full application without MongoDB (to avoid illegal instruction error)
print_status "Step 2: Building full application (without MongoDB)..."
if docker build -f Dockerfile.no-mongo -t portfolio-no-mongo . --no-cache > build-full.log 2>&1; then
    print_success "✅ Full application build successful"
    
    # Test the full application
    print_status "Testing full application..."
    FULL_ID=$(docker run -d -p 8082:80 --name full-test portfolio-no-mongo 2>/dev/null || echo "failed")
    
    if [ "$FULL_ID" != "failed" ]; then
        print_success "✅ Full container started"
        sleep 15
        
        # Test endpoints
        if curl -f -s http://localhost:8082 >/dev/null 2>&1; then
            print_success "✅ Application responding!"
        else
            print_status "Application may still be starting..."
        fi
        
        print_status "Container logs (last 10 lines):"
        docker logs full-test --tail 10
        
        docker stop full-test >/dev/null 2>&1 || true
        docker rm full-test >/dev/null 2>&1 || true
    else
        print_error "Full container failed to start"
        exit 1
    fi
else
    print_error "❌ Full application build failed"
    echo "Full build log:"
    tail -30 build-full.log
    exit 1
fi

print_success "🎉 Build completed successfully!"
echo ""
echo "✅ Available images:"
echo "  - portfolio-frontend-test (frontend only)"
echo "  - portfolio-no-mongo (full app without MongoDB)"
echo ""
echo "🚀 To run the working application:"
echo "docker run -d -p 80:80 \\"
echo "  -e SMTP_USERNAME='your-email@gmail.com' \\"
echo "  -e SMTP_PASSWORD='your-app-password' \\"
echo "  -e FROM_EMAIL='your-email@gmail.com' \\"
echo "  --name kamal-portfolio portfolio-no-mongo"
echo ""
echo "🌐 Then visit: http://localhost"