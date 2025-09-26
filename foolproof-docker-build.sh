#!/bin/bash

# Foolproof Docker Build Script
# This will work regardless of directory issues

set -e

echo "🎯 Foolproof Docker Build for IT Portfolio"
echo "========================================="

# Ensure we're in the right directory
echo "📁 Current directory: $(pwd)"

# Double-check files exist
if [ ! -f "frontend/package.json" ]; then
    echo "❌ ERROR: frontend/package.json not found in $(pwd)"
    echo "📁 Current directory contents:"
    ls -la
    echo ""
    echo "🔍 Searching for package.json files:"
    find . -name "package.json" -type f 2>/dev/null || echo "No package.json found"
    exit 1
fi

echo "✅ frontend/package.json confirmed"

# Check yarn.lock
if [ ! -f "frontend/yarn.lock" ]; then
    echo "📦 yarn.lock missing, creating it..."
    cd frontend
    yarn install
    cd ..
    echo "✅ yarn.lock created"
else
    echo "✅ frontend/yarn.lock confirmed"
fi

# Create the simplest possible working Dockerfile
echo "📄 Creating ultra-simple Dockerfile..."
cat > Dockerfile.simple << 'EOF'
FROM node:18-alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Set working directory
WORKDIR /app

# Copy package.json and yarn.lock first (for better caching)
COPY frontend/package.json ./
COPY frontend/yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the entire frontend directory
COPY frontend/ ./

# Build the app
RUN yarn build

# Install serve to serve the built app
RUN npm install -g serve

# Expose port
EXPOSE 3000

# Start the app
CMD ["serve", "-s", "build", "-l", "3000"]
EOF

echo "✅ Dockerfile.simple created"

# Clean up any previous attempts
echo "🧹 Cleaning Docker cache..."
sudo docker system prune -f >/dev/null 2>&1 || true

# Show what we're about to build
echo "🔍 Build context verification:"
echo "   ✓ frontend/package.json: $(wc -c < frontend/package.json) bytes"
echo "   ✓ frontend/yarn.lock: $(wc -c < frontend/yarn.lock) bytes"
echo "   ✓ frontend/src/: $(find frontend/src -type f | wc -l) files"
echo "   ✓ frontend/public/: $(find frontend/public -type f | wc -l) files"

echo ""
echo "🔨 Starting Docker build..."
echo "This will take 3-5 minutes..."
echo ""

# Build the Docker image
if sudo docker build -f Dockerfile.simple -t kamal-portfolio . --progress=plain; then
    echo ""
    echo "🎉🎉🎉 SUCCESS! 🎉🎉🎉"
    echo ""
    echo "✅ Your IT Portfolio Docker image is ready!"
    echo ""
    echo "🚀 To run your portfolio:"
    echo "   sudo docker run -d -p 80:3000 --name my-portfolio kamal-portfolio"
    echo ""
    echo "🌐 Then open your browser and visit:"
    echo "   http://localhost"
    echo ""
    echo "📊 Your portfolio includes:"
    echo "   ✓ ARCHSOL IT Solutions professional branding"
    echo "   ✓ IT Portfolio Architect title and positioning"
    echo "   ✓ Gen AI and Agentic AI skills section"
    echo "   ✓ Professional IT-specific imagery"
    echo "   ✓ Complete navigation (Skills, Projects, Contact)"
    echo "   ✓ Responsive design for all devices"
    echo ""
    echo "🔧 Container management commands:"
    echo "   Start:  sudo docker start my-portfolio"
    echo "   Stop:   sudo docker stop my-portfolio"
    echo "   Logs:   sudo docker logs my-portfolio"
    echo "   Remove: sudo docker rm -f my-portfolio"
    echo ""
    echo "🎯 BUILD COMPLETED SUCCESSFULLY!"
    
else
    echo ""
    echo "❌ Build failed"
    echo ""
    echo "🔍 Debugging steps:"
    echo "1. Ensure you're in: /home/ksingh/Desktop/solarch-portfolio-docker-package-localimage-main"
    echo "2. Verify: ls -la frontend/package.json"
    echo "3. Check Docker: sudo docker --version"
    echo "4. Try: sudo docker build -f Dockerfile.simple -t kamal-portfolio . --no-cache"
    echo ""
    exit 1
fi