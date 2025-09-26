#!/bin/bash

# HTTPS-enabled Docker Build Script for Kamal Singh Portfolio
# Builds and runs the portfolio with SSL/TLS support

set -e  # Exit on any error

echo "=================================================="
echo "Building Kamal Singh IT Portfolio with HTTPS"
echo "SSL/TLS enabled for production deployment"
echo "=================================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "frontend/package.json" ]; then
    echo "ERROR: Please run this script from the project root directory"
    echo "Expected to find frontend/package.json"
    exit 1
fi

# Cleanup any existing container
echo "Cleaning up existing containers..."
docker stop kamal-portfolio-https 2>/dev/null || true
docker rm kamal-portfolio-https 2>/dev/null || true

# Remove old image to ensure fresh build
docker rmi kamal-portfolio:https 2>/dev/null || true

# Build the Docker image with HTTPS support
echo "Building Docker image with HTTPS support..."
echo "This may take a few minutes..."
docker build --no-cache -f Dockerfile.https -t kamal-portfolio:https .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully!"
else
    echo "❌ Docker build failed!"
    echo "Check the build output above for errors."
    exit 1
fi

# Check if custom certificates should be mounted
if [ -f "./ssl/portfolio.crt" ] && [ -f "./ssl/portfolio.key" ]; then
    echo "Found custom SSL certificates in ./ssl/"
    echo "Using custom certificates instead of self-signed..."
    CERT_MOUNT="-v $(pwd)/ssl:/etc/nginx/ssl:ro"
else
    echo "No custom certificates found. Using self-signed certificates."
    echo "For production, place your certificates in ./ssl/portfolio.crt and ./ssl/portfolio.key"
    CERT_MOUNT=""
fi

# Run the container with HTTPS support
echo "Starting the HTTPS portfolio container..."
docker run -d \
    --name kamal-portfolio-https \
    -p 8080:80 \
    -p 8443:443 \
    $CERT_MOUNT \
    kamal-portfolio:https

if [ $? -eq 0 ]; then
    echo "✅ Container started successfully!"
    echo ""
    echo "=================================================="
    echo "🎉 SUCCESS! HTTPS Portfolio is now running"
    echo "=================================================="
    echo "🔓 HTTP (redirects to HTTPS): http://localhost:8080"
    echo "🔒 HTTPS: https://localhost:8443"
    echo "🏥 Health Check: https://localhost:8443/health"
    echo ""
    echo "📋 Container Management:"
    echo "🔍 View logs: docker logs kamal-portfolio-https"
    echo "🛑 Stop: docker stop kamal-portfolio-https"
    echo "🗑️  Remove: docker rm kamal-portfolio-https"
    echo ""
    echo "⚠️  Note: Self-signed certificate will show browser warning."
    echo "   For production, use real SSL certificates."
    echo ""
    echo "Waiting 15 seconds for container to initialize..."
    sleep 15
    
    # Test HTTPS response
    echo "Testing HTTPS container response..."
    if curl -k -s -f https://localhost:8443 > /dev/null; then
        echo "✅ HTTPS Portfolio is responding successfully!"
        echo "🌐 Open https://localhost:8443 in your browser"
        echo "   (Accept the self-signed certificate warning)"
    else
        echo "⚠️  Container started but may still be initializing"
        echo "🌐 Try opening https://localhost:8443 in your browser"
        echo ""
        echo "If you see errors, check container logs:"
        echo "  docker logs kamal-portfolio-https"
    fi
else
    echo "❌ Failed to start container!"
    exit 1
fi