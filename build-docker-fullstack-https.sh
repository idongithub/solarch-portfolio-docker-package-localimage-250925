#!/bin/bash

# Full Stack HTTPS Docker Build Script for Kamal Singh Portfolio
# Includes Frontend with HTTPS, Backend, MongoDB, and SMTP functionality

set -e  # Exit on any error

echo "=========================================================="
echo "Building Kamal Singh IT Portfolio - Full Stack with HTTPS"
echo "Complete functionality with SSL/TLS encryption"
echo "=========================================================="

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

# Check SSL certificates
if [ ! -f "./ssl/portfolio.crt" ] || [ ! -f "./ssl/portfolio.key" ]; then
    echo "⚠️  SSL certificates not found in ./ssl/ directory"
    echo ""
    echo "Options:"
    echo "1) Generate self-signed certificates (for development/testing)"
    echo "2) I have my own certificates to place in ./ssl/"
    echo "3) Skip HTTPS and use HTTP-only deployment"
    echo ""
    read -p "Choose option (1-3): " ssl_choice
    
    case $ssl_choice in
        1)
            echo "Generating self-signed certificates..."
            ./generate-ssl-certificates.sh
            ;;
        2)
            echo "Please place your SSL certificates in ./ssl/ directory:"
            echo "  ./ssl/portfolio.crt (certificate file)"
            echo "  ./ssl/portfolio.key (private key file)"
            echo ""
            read -p "Press Enter when certificates are in place..."
            
            if [ ! -f "./ssl/portfolio.crt" ] || [ ! -f "./ssl/portfolio.key" ]; then
                echo "ERROR: SSL certificates still not found!"
                exit 1
            fi
            ;;
        3)
            echo "Using HTTP-only deployment..."
            echo "Running build-docker-fullstack.sh instead..."
            ./build-docker-fullstack.sh
            exit 0
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
fi

# Cleanup existing containers
echo "Cleaning up existing containers..."
docker-compose -f docker-compose.https.yml --env-file .env.docker down 2>/dev/null || true

# Build all services
echo "Building all Docker images with HTTPS support..."
echo "This may take several minutes..."
docker-compose -f docker-compose.https.yml --env-file .env.docker build --no-cache

if [ $? -eq 0 ]; then
    echo "✅ All Docker images built successfully!"
else
    echo "❌ Docker build failed!"
    echo "Check the build output above for errors."
    exit 1
fi

# Start all services
echo "Starting all services with HTTPS..."
docker-compose -f docker-compose.https.yml --env-file .env.docker up -d

if [ $? -eq 0 ]; then
    echo "✅ All services started successfully!"
    echo ""
    echo "=========================================================="
    echo "🎉 SUCCESS! Full Stack HTTPS Portfolio Running"
    echo "=========================================================="
    echo "🔓 HTTP (redirects to HTTPS): http://localhost:8080"
    echo "🔒 HTTPS Frontend: https://localhost:8443"
    echo "🔧 Backend API: http://localhost:8001/api"
    echo "🗄️  MongoDB: localhost:27017"
    echo "🏥 Health Check: https://localhost:8443/health"
    echo ""
    echo "📧 Contact form functionality: ENABLED with SMTP"
    echo "🔍 View logs: docker-compose -f docker-compose.https.yml --env-file .env.docker logs -f"
    echo "🛑 Stop all: docker-compose -f docker-compose.https.yml --env-file .env.docker down"
    echo ""
    echo "⚠️  Note: Self-signed certificates will show browser warning"
    echo "   For production, use certificates from trusted CA"
    echo ""
    echo "Waiting 20 seconds for all services to initialize..."
    sleep 20
    
    # Test services
    echo "Testing services..."
    
    # Test backend
    if curl -s -f http://localhost:8001/api/ > /dev/null; then
        echo "✅ Backend API is responding"
    else
        echo "⚠️  Backend API may still be starting"
    fi
    
    # Test HTTPS frontend
    if curl -k -s -f https://localhost:8443 > /dev/null; then
        echo "✅ HTTPS Frontend is responding"
        echo ""
        echo "🌐 Open https://localhost:8443 in your browser"
        echo "   (Accept certificate warning for self-signed certificates)"
        echo "📧 Contact form will use your SMTP settings from .env.docker"
    else
        echo "⚠️  HTTPS Frontend may still be starting"
        echo "🌐 Try opening https://localhost:8443 in your browser"
    fi
    
    echo ""
    echo "Service Status:"
    docker-compose -f docker-compose.https.yml --env-file .env.docker ps
    
else
    echo "❌ Failed to start services!"
    echo "Check logs with: docker-compose -f docker-compose.https.yml --env-file .env.docker logs"
    exit 1
fi