#!/bin/bash

# Full Stack Docker Build Script for Kamal Singh Portfolio
# Includes Frontend, Backend, MongoDB, and SMTP functionality

set -e  # Exit on any error

echo "=========================================="
echo "Building Kamal Singh IT Portfolio"
echo "Full Stack with SMTP Support"
echo "=========================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "ERROR: Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "frontend/package.json" ] || [ ! -f "backend/server.py" ]; then
    echo "ERROR: Please run this script from the project root directory"
    echo "Expected to find frontend/package.json and backend/server.py"
    exit 1
fi

# Check if environment file exists
if [ ! -f ".env.docker" ]; then
    echo "⚠️  Environment file .env.docker not found!"
    echo "Creating template from .env.docker.template..."
    
    if [ -f ".env.docker.template" ]; then
        cp .env.docker.template .env.docker
        echo ""
        echo "📝 IMPORTANT: Edit .env.docker file with your SMTP settings before continuing!"
        echo ""
        echo "Required SMTP settings:"
        echo "  SMTP_USERNAME=your-email@gmail.com"
        echo "  SMTP_PASSWORD=your-app-password"
        echo "  FROM_EMAIL=your-email@gmail.com"
        echo ""
        echo "Press Enter when you've configured the .env.docker file..."
        read -r
    else
        echo "ERROR: .env.docker.template not found!"
        exit 1
    fi
fi

# Cleanup existing containers
echo "Cleaning up existing containers..."
docker-compose --env-file .env.docker down 2>/dev/null || true

# Build all services
echo "Building all Docker images..."
echo "This may take several minutes..."
docker-compose --env-file .env.docker build --no-cache

if [ $? -eq 0 ]; then
    echo "✅ All Docker images built successfully!"
else
    echo "❌ Docker build failed!"
    echo "Check the build output above for errors."
    exit 1
fi

# Start all services
echo "Starting all services..."
docker-compose --env-file .env.docker up -d

if [ $? -eq 0 ]; then
    echo "✅ All services started successfully!"
    echo ""
    echo "=========================================="
    echo "🎉 SUCCESS! Full Stack Portfolio Running"
    echo "=========================================="
    echo "📱 Frontend: http://localhost:8080"
    echo "🔧 Backend API: http://localhost:8001/api"
    echo "🗄️  MongoDB: localhost:27017"
    echo ""
    echo "📧 Contact form functionality: ENABLED"
    echo "🔍 View logs: docker-compose --env-file .env.docker logs -f"
    echo "🛑 Stop all: docker-compose --env-file .env.docker down"
    echo ""
    echo "Waiting 15 seconds for all services to initialize..."
    sleep 15
    
    # Test services
    echo "Testing services..."
    
    # Test backend
    if curl -s -f http://localhost:8001/api/ > /dev/null; then
        echo "✅ Backend API is responding"
    else
        echo "⚠️  Backend API may still be starting"
    fi
    
    # Test frontend
    if curl -s -f http://localhost:8080 > /dev/null; then
        echo "✅ Frontend is responding"
        echo ""
        echo "🌐 Open http://localhost:8080 in your browser"
        echo "📧 Contact form will use your SMTP settings from .env.docker"
    else
        echo "⚠️  Frontend may still be starting"
        echo "🌐 Try opening http://localhost:8080 in your browser"
    fi
    
    echo ""
    echo "Service Status:"
    docker-compose --env-file .env.docker ps
    
else
    echo "❌ Failed to start services!"
    echo "Check logs with: docker-compose --env-file .env.docker logs"
    exit 1
fi