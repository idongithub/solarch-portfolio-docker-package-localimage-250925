#!/bin/bash

# Quick build script to create the Kamal Singh Portfolio Docker image

echo "🏗️ Building Kamal Singh Portfolio Docker Image..."
echo "=================================================="

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    echo "📖 Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "Dockerfile.all-in-one" ]; then
    echo "❌ Dockerfile.all-in-one not found."
    echo "💡 Please run this script from the portfolio root directory."
    exit 1
fi

echo "📦 Starting Docker build (this may take 10-15 minutes)..."
echo "⏳ Installing: Ubuntu + Node.js + Python + MongoDB + Nginx + Application..."
echo ""

# Build the image
docker build -f Dockerfile.all-in-one -t kamal-singh-portfolio:latest . || {
    echo "❌ Build failed"
    exit 1
}

echo ""
echo "✅ Build completed successfully!"
echo ""

# Show image info
echo "📊 Image Information:"
docker images kamal-singh-portfolio:latest

echo ""
echo "🚀 Quick Start Commands:"
echo ""
echo "# Run without email (demo mode)"
echo "docker run -d -p 80:80 --name portfolio kamal-singh-portfolio:latest"
echo ""
echo "# Run with email functionality"
echo "docker run -d -p 80:80 -p 443:443 \\"
echo "  -e SMTP_USERNAME=your-email@gmail.com \\"
echo "  -e SMTP_PASSWORD=your-app-password \\"
echo "  --name portfolio \\"
echo "  kamal-singh-portfolio:latest"
echo ""
echo "📍 Access at: http://localhost"
echo ""
echo "🎉 Your portfolio Docker image is ready!"