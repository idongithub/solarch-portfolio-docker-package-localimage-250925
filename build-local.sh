#!/bin/bash

# Local Docker Build Script - For environments with Docker installed
# This is the simple, working solution

set -e

echo "🐳 Building Kamal Singh IT Portfolio Docker Image"

# Verify Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    echo "Please install Docker first:"
    echo "  - macOS: Docker Desktop"
    echo "  - Ubuntu: apt install docker.io"
    echo "  - Windows: Docker Desktop"
    exit 1
fi

echo "✅ Docker is available"

# Go to project directory
cd "$(dirname "$0")"
echo "📁 Working from: $(pwd)"

# Verify project structure
if [ ! -d "frontend" ] || [ ! -f "frontend/package.json" ]; then
    echo "❌ Frontend directory or package.json not found"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo "✅ Project structure verified"

# Create simple, working Dockerfile
cat > Dockerfile.working << 'EOF'
FROM node:18-alpine

# Install curl for health checks
RUN apk add --no-cache curl

WORKDIR /app

# Copy package files
COPY frontend/package.json ./
COPY frontend/yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy source code
COPY frontend/ ./

# Build the application
RUN yarn build

# Install serve
RUN npm install -g serve

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3000 || exit 1

# Start the application
CMD ["serve", "-s", "build", "-l", "3000", "--no-clipboard"]
EOF

echo "✅ Dockerfile created"

# Clean Docker cache
echo "🧹 Cleaning Docker cache..."
docker system prune -f >/dev/null 2>&1

# Build the image
echo "🔨 Building Docker image (this will take 3-5 minutes)..."
if docker build -f Dockerfile.working -t kamal-portfolio . --no-cache; then
    echo ""
    echo "🎉 BUILD SUCCESSFUL!"
    echo ""
    echo "✅ Docker image 'kamal-portfolio' is ready"
    echo ""
    echo "🚀 To run your portfolio:"
    echo "   docker run -d -p 80:3000 --name my-portfolio kamal-portfolio"
    echo ""
    echo "🌐 Then visit: http://localhost"
    echo ""
    echo "📊 Your portfolio includes:"
    echo "   ✓ ARCHSOL IT Solutions professional branding"
    echo "   ✓ IT Portfolio Architect title and positioning"
    echo "   ✓ Gen AI and Agentic AI skills section"
    echo "   ✓ Professional IT-specific imagery"
    echo "   ✓ Complete navigation (Skills, Projects, Contact)"
    echo "   ✓ Responsive design for all devices"
    echo ""
    echo "🔧 Container management:"
    echo "   Start:   docker start my-portfolio"
    echo "   Stop:    docker stop my-portfolio"
    echo "   Logs:    docker logs my-portfolio"
    echo "   Remove:  docker rm my-portfolio"
else
    echo ""
    echo "❌ BUILD FAILED"
    echo ""
    echo "Common solutions:"
    echo "1. Ensure you have enough disk space (5GB+)"
    echo "2. Check internet connection for package downloads"
    echo "3. Try: docker system prune -a"
    echo "4. Verify you're in the project root directory"
    exit 1
fi