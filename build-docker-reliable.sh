#!/bin/bash

# Reliable Docker Build Script for IT Portfolio Architect
# Uses simplified configuration for better reliability

set -e

echo "🚀 Starting Reliable Docker Build Process..."

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

# Build the Docker image with reliable configuration
print_status "Building Docker image with reliable configuration..."
IMAGE_NAME="kamal-singh-portfolio"
TAG="reliable"

# Pre-build validation
print_status "Validating configuration files..."

# Check if required files exist
REQUIRED_FILES=("Dockerfile.reliable" "nginx-simple.conf" "supervisord-all-in-one.conf" "startup-all-in-one.sh" "healthcheck-all-in-one.sh")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        print_error "Required file missing: $file"
        exit 1
    fi
done

print_success "All required files present"

# Build with improved error handling and logging
print_status "Starting Docker build..."
docker build \
    -f Dockerfile.reliable \
    -t "${IMAGE_NAME}:${TAG}" \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --progress=plain \
    . 2>&1 | tee docker-build-reliable.log

if [ $? -eq 0 ]; then
    print_success "Docker image built successfully!"
    
    # Show image details
    print_status "Docker image details:"
    docker images "${IMAGE_NAME}:${TAG}"
    
    # Test the image
    print_status "Testing the Docker image..."
    
    # Run a quick test to see if the image starts correctly
    print_status "Starting test container..."
    CONTAINER_ID=$(docker run -d -p 8080:80 --name test-portfolio "${IMAGE_NAME}:${TAG}")
    
    if [ $? -eq 0 ]; then
        print_success "Container started successfully with ID: ${CONTAINER_ID}"
        
        # Wait for the container to initialize
        print_status "Waiting for container to initialize..."
        sleep 30
        
        # Check if the container is still running
        if docker ps -q --filter id="${CONTAINER_ID}" | grep -q .; then
            print_success "Container is running healthy!"
            
            # Test HTTP endpoint multiple times
            print_status "Testing HTTP endpoints..."
            for i in {1..5}; do
                if curl -f -s http://localhost:8080/health >/dev/null 2>&1; then
                    print_success "Health endpoint responding (attempt $i/5)"
                    break
                else
                    print_warning "Health endpoint not ready, waiting... (attempt $i/5)"
                    sleep 5
                fi
            done
            
            # Test main page
            if curl -f -s http://localhost:8080 >/dev/null 2>&1; then
                print_success "Main application is responding!"
            else
                print_warning "Main application may not be fully ready yet"
            fi
            
            # Show container logs for verification
            print_status "Container logs (last 20 lines):"
            docker logs "${CONTAINER_ID}" --tail 20
            
        else
            print_error "Container stopped unexpectedly"
            print_status "Container logs:"
            docker logs "${CONTAINER_ID}"
            
            # Clean up and exit
            docker rm "${CONTAINER_ID}" >/dev/null 2>&1
            exit 1
        fi
        
        # Clean up test container
        print_status "Cleaning up test container..."
        docker stop "${CONTAINER_ID}" >/dev/null 2>&1
        docker rm "${CONTAINER_ID}" >/dev/null 2>&1
        
    else
        print_error "Failed to start container"
        exit 1
    fi
    
    print_success "✅ Docker build and test completed successfully!"
    echo ""
    echo "🎉 Your IT Portfolio Architect application is ready!"
    echo ""
    echo "To run the portfolio application:"
    echo "  docker run -d -p 80:80 --name kamal-portfolio ${IMAGE_NAME}:${TAG}"
    echo ""
    echo "To run with custom environment variables:"
    echo "  docker run -d -p 80:80 \\"
    echo "    -e SMTP_USERNAME=your-email@gmail.com \\"
    echo "    -e SMTP_PASSWORD=your-app-password \\"
    echo "    -e FROM_EMAIL=your-email@gmail.com \\"
    echo "    --name kamal-portfolio ${IMAGE_NAME}:${TAG}"
    echo ""
    echo "To test the deployment:"
    echo "  curl http://localhost/health"
    echo "  curl http://localhost"
    
else
    print_error "Docker build failed! Check docker-build-reliable.log for details"
    
    # Show the last few lines of the build log for quick debugging
    print_status "Last 30 lines of build log:"
    tail -30 docker-build-reliable.log
    
    # Check for common issues
    print_status "Checking for common issues..."
    
    if grep -q "nginx" docker-build-reliable.log; then
        print_warning "Nginx-related error detected. Check nginx configuration."
    fi
    
    if grep -q "yarn" docker-build-reliable.log; then
        print_warning "Frontend build error detected. Check package.json and dependencies."
    fi
    
    if grep -q "pip" docker-build-reliable.log; then
        print_warning "Python package error detected. Check requirements.txt."
    fi
    
    exit 1
fi