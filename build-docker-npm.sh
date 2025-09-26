#!/bin/bash

# Professional IT Portfolio Docker Build Script (NPM Version)
# This script builds and runs the Kamal Singh portfolio using Docker with npm

set -e  # Exit on any error

echo "======================================"
echo "Building Kamal Singh IT Portfolio"
echo "Using npm package manager"
echo "======================================"

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
docker stop kamal-portfolio-npm 2>/dev/null || true
docker rm kamal-portfolio-npm 2>/dev/null || true

# Remove old image to ensure fresh build
docker rmi kamal-portfolio:npm 2>/dev/null || true

# Build the Docker image
echo "Building Docker image..."
echo "This may take a few minutes..."
docker build --no-cache -f Dockerfile.npm -t kamal-portfolio:npm .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully!"
else
    echo "❌ Docker build failed!"
    echo "Check the build output above for errors."
    exit 1
fi

# Run the container
echo "Starting the portfolio container..."
docker run -d \
    --name kamal-portfolio-npm \
    -p 8080:80 \
    kamal-portfolio:npm

if [ $? -eq 0 ]; then
    echo "✅ Container started successfully!"
    echo ""
    echo "======================================"
    echo "🎉 SUCCESS! Portfolio is now running"
    echo "======================================"
    echo "📱 Access your portfolio at: http://localhost:8080"
    echo "🔍 To view logs: docker logs kamal-portfolio-npm"
    echo "🛑 To stop: docker stop kamal-portfolio-npm"
    echo "🗑️  To remove: docker rm kamal-portfolio-npm"
    echo ""
    echo "Waiting 10 seconds for container to initialize..."
    sleep 10
    
    echo "Testing container response..."
    for i in {1..3}; do
        echo "Attempt $i/3..."
        if curl -s -f http://localhost:8080 > /dev/null; then
            echo "✅ Portfolio is responding successfully!"
            echo "🌐 Open http://localhost:8080 in your browser"
            echo ""
            echo "Note: This is the frontend-only version."
            echo "For full functionality with contact form, use docker-compose:"
            echo "  cp .env.docker.template .env.docker"
            echo "  # Edit .env.docker with your SMTP settings"
            echo "  docker-compose --env-file .env.docker up -d"
            exit 0
        else
            echo "⚠️  Attempt $i failed, waiting 5 seconds..."
            sleep 5
        fi
    done
    
    echo "❌ Container not responding after 3 attempts"
    echo "🔍 Checking container logs for issues:"
    echo "----------------------------------------"
    docker logs kamal-portfolio-npm
    echo "----------------------------------------"
    echo ""
    echo "🛠️  Troubleshooting tips:"
    echo "1. Check if container is running: docker ps"
    echo "2. View full logs: docker logs kamal-portfolio-npm"
    echo "3. Check nginx config: docker exec kamal-portfolio-npm nginx -t"
    echo "4. If infinite redirect error, rebuild with latest fixes"
else
    echo "❌ Failed to start container!"
    exit 1
fi