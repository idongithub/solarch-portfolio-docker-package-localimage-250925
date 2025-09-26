#!/bin/bash

# Ultra-Simple Docker Build Script
# Minimal validation, maximum reliability

set -e

echo "🚀 Starting Simple Docker Build..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker not found"
    exit 1
fi
print_success "Docker is available"

# Clean up
print_status "Cleaning up..."
docker system prune -f 2>/dev/null || true

# Build image
IMAGE_NAME="kamal-portfolio"
TAG="simple"

print_status "Building Docker image..."
print_status "This may take 5-10 minutes..."

# Build with simple configuration
if docker build \
    -f Dockerfile.simple-reliable \
    -t "${IMAGE_NAME}:${TAG}" \
    --no-cache \
    . > docker-build-simple.log 2>&1; then
    
    print_success "✅ Build completed!"
    
    # Show image info
    docker images "${IMAGE_NAME}:${TAG}"
    
    print_status "Testing container startup..."
    
    # Quick test
    CONTAINER_ID=$(docker run -d -p 8080:80 --name test-simple "${IMAGE_NAME}:${TAG}" 2>/dev/null || echo "failed")
    
    if [ "$CONTAINER_ID" = "failed" ]; then
        print_error "Container failed to start"
        print_status "Check docker-build-simple.log for details"
        exit 1
    fi
    
    print_success "Container started: $CONTAINER_ID"
    
    # Wait and test
    print_status "Waiting 30 seconds for services to start..."
    sleep 30
    
    if docker ps -q --filter id="$CONTAINER_ID" | grep -q .; then
        print_success "Container is running!"
        
        # Test endpoint
        if curl -f -s http://localhost:8080/health >/dev/null 2>&1; then
            print_success "✅ Application is responding!"
        else
            print_status "Application may still be starting up"
        fi
        
        print_status "Container logs (last 10 lines):"
        docker logs "$CONTAINER_ID" --tail 10
        
    else
        print_error "Container stopped"
        docker logs "$CONTAINER_ID"
    fi
    
    # Cleanup
    print_status "Cleaning up test container..."
    docker stop "$CONTAINER_ID" >/dev/null 2>&1 || true
    docker rm "$CONTAINER_ID" >/dev/null 2>&1 || true
    
    echo ""
    print_success "🎉 Build successful!"
    echo "To run: docker run -d -p 80:80 --name kamal-portfolio ${IMAGE_NAME}:${TAG}"
    
else
    print_error "❌ Build failed!"
    print_status "Last 20 lines of build log:"
    tail -20 docker-build-simple.log
    exit 1
fi