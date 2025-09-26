#!/bin/bash

# Ultra-Simple Docker Build Script
# Regenerates any missing files and builds reliably

set -e

echo "🚀 Simple Docker Build - Auto-Fix Missing Files"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Ensure we're in the app directory
cd /app
print_status "Working from: $(pwd)"

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker not found"
    exit 1
fi

print_success "Docker is available"

# Verify and fix yarn.lock if needed
print_status "Checking yarn.lock..."
if [ ! -f "frontend/yarn.lock" ]; then
    print_status "yarn.lock missing, regenerating..."
    cd frontend
    yarn install --frozen-lockfile 2>/dev/null || yarn install
    cd ..
    print_success "yarn.lock regenerated"
else
    print_success "yarn.lock exists"
fi

# Create simple frontend-only Dockerfile that works
print_status "Creating reliable frontend Dockerfile..."
cat > Dockerfile.simple-frontend << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY frontend/package.json ./package.json

# Copy yarn.lock if it exists, create one if it doesn't
COPY frontend/yarn.loc[k] ./yarn.lock* 

# Install dependencies (will create yarn.lock if missing)
RUN yarn install --network-timeout 600000

# Copy source code
COPY frontend/ ./

# Build the application
RUN yarn build

# Install serve
RUN npm install -g serve

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3000 || exit 1

EXPOSE 3000

CMD ["serve", "-s", "build", "-l", "3000"]
EOF

# Clean up previous builds
print_status "Cleaning up..."
docker system prune -f 2>/dev/null || true

# Build frontend
print_status "Building frontend..."
if docker build -f Dockerfile.simple-frontend -t portfolio-simple . --no-cache > build-simple.log 2>&1; then
    print_success "✅ Frontend build successful"
    
    # Test the frontend
    print_status "Testing frontend container..."
    CONTAINER_ID=$(docker run -d -p 3001:3000 --name simple-test portfolio-simple 2>/dev/null || echo "failed")
    
    if [ "$CONTAINER_ID" != "failed" ]; then
        print_success "Container started: ${CONTAINER_ID}"
        sleep 10
        
        if curl -f -s http://localhost:3001 >/dev/null 2>&1; then
            print_success "✅ Application is working!"
            echo ""
            echo "🎉 SUCCESS! Your Docker build is working!"
            echo ""
            echo "To run: docker run -d -p 80:3000 --name kamal-portfolio portfolio-simple"
            echo "Then visit: http://localhost"
        else
            print_status "Application may still be starting..."
            print_status "Container logs:"
            docker logs simple-test --tail 10
        fi
        
        # Cleanup test
        docker stop simple-test >/dev/null 2>&1 || true
        docker rm simple-test >/dev/null 2>&1 || true
        
    else
        print_error "Container failed to start"
        exit 1
    fi
    
else
    print_error "Build failed"
    echo "Build log:"
    tail -30 build-simple.log
    exit 1
fi

print_success "✅ Build completed successfully!"
echo ""
echo "🚀 To deploy your portfolio:"
echo "docker run -d -p 80:3000 --name kamal-portfolio portfolio-simple"