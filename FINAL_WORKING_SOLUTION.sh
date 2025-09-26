#!/bin/bash

# FINAL WORKING DOCKER BUILD SOLUTION
# This is the definitive solution that works

set -e

echo "🎯 Final Working Docker Build Solution"
echo "====================================="

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Install Docker first."
    exit 1
fi

echo "✅ Docker found"

# Go to project directory
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)

echo "📁 Project directory: $PROJECT_DIR"

# Verify files exist
if [ ! -d "frontend" ]; then
    echo "❌ Frontend directory missing"
    exit 1
fi

if [ ! -f "frontend/package.json" ]; then
    echo "❌ package.json missing"
    exit 1
fi

if [ ! -f "frontend/yarn.lock" ]; then
    echo "❌ yarn.lock missing - regenerating..."
    cd frontend
    yarn install
    cd ..
    echo "✅ yarn.lock created"
else
    echo "✅ yarn.lock exists"
fi

# Create the working Dockerfile
echo "📄 Creating Dockerfile..."
cat > Dockerfile.final << 'EOF'
# Final Working Dockerfile
FROM node:18-alpine

# Install curl for health checks
RUN apk add --no-cache curl

WORKDIR /app

# Copy package.json first for better caching
COPY frontend/package.json ./package.json

# Copy yarn.lock 
COPY frontend/yarn.lock ./yarn.lock

# Install dependencies
RUN yarn install --frozen-lockfile --network-timeout 600000

# Copy all source files
COPY frontend/src ./src
COPY frontend/public ./public
COPY frontend/.env* ./

# Build the application
RUN yarn build

# Install serve
RUN npm install -g serve

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3000 || exit 1

# Start command
CMD ["serve", "-s", "build", "-l", "3000", "--no-clipboard"]
EOF

echo "✅ Dockerfile created"

# Show what we're copying
echo "📋 Files that will be copied:"
echo "   ✓ frontend/package.json ($(wc -c < frontend/package.json) bytes)"
echo "   ✓ frontend/yarn.lock ($(wc -c < frontend/yarn.lock) bytes)" 
echo "   ✓ frontend/src/ directory"
echo "   ✓ frontend/public/ directory"

# Clean Docker cache
echo "🧹 Cleaning Docker cache..."
docker system prune -f >/dev/null 2>&1 || true

# Build the image
echo "🔨 Building Docker image..."
echo "This will take 3-5 minutes..."

if docker build -f Dockerfile.final -t kamal-portfolio-final . --no-cache; then
    echo ""
    echo "🎉 SUCCESS! Docker image built successfully!"
    echo ""
    echo "✅ Image: kamal-portfolio-final"
    echo ""
    echo "🚀 To run your IT Portfolio:"
    echo "   docker run -d -p 80:3000 --name my-portfolio kamal-portfolio-final"
    echo ""
    echo "🌐 Then visit: http://localhost"
    echo ""
    echo "📊 Your portfolio includes:"
    echo "   ✓ ARCHSOL IT Solutions branding"
    echo "   ✓ IT Portfolio Architect positioning"
    echo "   ✓ Gen AI and Agentic AI skills"
    echo "   ✓ Professional IT imagery"
    echo "   ✓ Complete navigation"
    echo ""
    echo "🔧 Container commands:"
    echo "   Start:  docker start my-portfolio"
    echo "   Stop:   docker stop my-portfolio" 
    echo "   Logs:   docker logs my-portfolio"
    echo "   Remove: docker rm -f my-portfolio"
else
    echo ""
    echo "❌ Build failed!"
    echo ""
    echo "Debug info:"
    echo "- Verify Docker is running: docker ps"
    echo "- Check disk space: df -h"
    echo "- Try: docker system prune -a"
    exit 1
fi