#!/bin/bash

# Enhanced Docker Build Script for IT Portfolio Architect
# Fixes common Docker build issues and provides comprehensive error handling

set -e

echo "🚀 Starting Enhanced Docker Build Process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check Docker availability
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not available in PATH"
    exit 1
fi

print_success "Docker is available"

# Clean up any previous builds
print_status "Cleaning up previous builds..."
docker system prune -f --volumes 2>/dev/null || true

# Build the Docker image
print_status "Building Docker image..."
IMAGE_NAME="kamal-singh-portfolio"
TAG="latest"

# Build with improved error handling and logging
docker build \
    -f Dockerfile.all-in-one \
    -t "${IMAGE_NAME}:${TAG}" \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --progress=plain \
    . 2>&1 | tee docker-build.log

if [ $? -eq 0 ]; then
    print_success "Docker image built successfully!"
    
    # Show image details
    print_status "Docker image details:"
    docker images "${IMAGE_NAME}:${TAG}"
    
    # Test the image
    print_status "Testing the Docker image..."
    
    # Run a quick test to see if the image starts correctly
    CONTAINER_ID=$(docker run -d -p 8080:80 "${IMAGE_NAME}:${TAG}")
    
    if [ $? -eq 0 ]; then
        print_success "Container started successfully with ID: ${CONTAINER_ID}"
        
        # Wait a moment for the container to initialize
        sleep 10
        
        # Check if the container is still running
        if docker ps -q --filter id="${CONTAINER_ID}" | grep -q .; then
            print_success "Container is running healthy!"
            
            # Test HTTP endpoint
            if curl -f http://localhost:8080 >/dev/null 2>&1; then
                print_success "Application is responding to HTTP requests!"
            else
                print_warning "Application may not be fully ready yet"
            fi
        else
            print_error "Container stopped unexpectedly"
            docker logs "${CONTAINER_ID}"
        fi
        
        # Clean up test container
        docker stop "${CONTAINER_ID}" >/dev/null 2>&1
        docker rm "${CONTAINER_ID}" >/dev/null 2>&1
        
    else
        print_error "Failed to start container"
        exit 1
    fi
    
    print_success "✅ Docker build completed successfully!"
    echo ""
    echo "To run the portfolio application:"
    echo "  docker run -d -p 80:80 -p 443:443 --name kamal-portfolio ${IMAGE_NAME}:${TAG}"
    echo ""
    echo "To run with custom environment variables:"
    echo "  docker run -d -p 80:80 \\"
    echo "    -e SMTP_USERNAME=your-email@gmail.com \\"
    echo "    -e SMTP_PASSWORD=your-app-password \\"
    echo "    -e FROM_EMAIL=your-email@gmail.com \\"
    echo "    --name kamal-portfolio ${IMAGE_NAME}:${TAG}"
    
else
    print_error "Docker build failed! Check docker-build.log for details"
    
    # Show the last few lines of the build log for quick debugging
    print_status "Last 20 lines of build log:"
    tail -20 docker-build.log
    
    exit 1
fi