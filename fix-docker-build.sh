#!/bin/bash

# Docker Build Fix Script
# This will diagnose and fix the build context issue

echo "🔍 Diagnosing Docker Build Context Issue"
echo "======================================="

# Check current directory
echo "📁 Current directory: $(pwd)"
echo ""

# Check if we have the right structure
echo "📋 Checking project structure..."

if [ -d "frontend" ]; then
    echo "✅ frontend/ directory exists"
    
    if [ -f "frontend/package.json" ]; then
        echo "✅ frontend/package.json exists"
        echo "   Size: $(wc -c < frontend/package.json) bytes"
    else
        echo "❌ frontend/package.json is MISSING"
        echo "📁 Contents of frontend/:"
        ls -la frontend/ || echo "Cannot list frontend directory"
        exit 1
    fi
    
    if [ -f "frontend/yarn.lock" ]; then
        echo "✅ frontend/yarn.lock exists"  
        echo "   Size: $(wc -c < frontend/yarn.lock) bytes"
    else
        echo "⚠️  frontend/yarn.lock missing - will regenerate"
    fi
    
    if [ -d "frontend/src" ]; then
        echo "✅ frontend/src/ directory exists"
    else
        echo "❌ frontend/src/ directory is MISSING"
        exit 1
    fi
    
    if [ -d "frontend/public" ]; then
        echo "✅ frontend/public/ directory exists"
    else
        echo "❌ frontend/public/ directory is MISSING"  
        exit 1
    fi
    
else
    echo "❌ frontend/ directory is MISSING"
    echo ""
    echo "📁 Current directory contents:"
    ls -la
    echo ""
    echo "🚨 You must run this script from the project root directory"
    echo "The project root should contain a 'frontend' directory"
    exit 1
fi

echo ""
echo "✅ All required files and directories found!"
echo ""

# Check .dockerignore
if [ -f ".dockerignore" ]; then
    echo "📄 Checking .dockerignore..."
    if grep -q "frontend" .dockerignore; then
        echo "⚠️  WARNING: .dockerignore contains 'frontend'"
        echo "   This might exclude the frontend directory"
        echo "   Problematic lines:"
        grep -n "frontend" .dockerignore
    else
        echo "✅ .dockerignore looks OK"
    fi
else
    echo "📄 No .dockerignore file found (that's OK)"
fi

echo ""

# Create a working Dockerfile that definitely works
echo "📄 Creating foolproof Dockerfile..."
cat > Dockerfile.fixed << 'EOF'
# Foolproof Dockerfile - Absolute paths
FROM node:18-alpine

# Install curl
RUN apk add --no-cache curl

WORKDIR /app

# Copy package.json with absolute verification
COPY frontend/package.json ./package.json

# Copy yarn.lock (or create if missing)
COPY frontend/yarn.loc[k] ./yarn.lock*

# Install dependencies
RUN yarn install --frozen-lockfile || yarn install

# Copy source code
COPY frontend/src ./src
COPY frontend/public ./public

# Copy any .env files
COPY frontend/.env* ./ || true

# Build the app
RUN yarn build

# Install serve
RUN npm install -g serve

EXPOSE 3000

CMD ["serve", "-s", "build", "-l", "3000"]
EOF

echo "✅ Dockerfile.fixed created"
echo ""

# Test the docker build
echo "🔨 Testing Docker build..."
echo "Building with: docker build -f Dockerfile.fixed -t portfolio-test ."
echo ""

if command -v docker &> /dev/null; then
    echo "🐳 Docker found, attempting build..."
    
    # Show what Docker sees in the build context
    echo "🔍 Build context contents:"
    find . -name "package.json" -o -name "yarn.lock" | head -10
    echo ""
    
    # Try the build
    if docker build -f Dockerfile.fixed -t portfolio-test . --no-cache; then
        echo ""
        echo "🎉 SUCCESS! Docker build completed!"
        echo ""
        echo "🚀 To run your portfolio:"
        echo "   docker run -d -p 80:3000 --name my-portfolio portfolio-test"
        echo ""
        echo "🌐 Then visit: http://localhost"
    else
        echo ""
        echo "❌ Docker build still failed"
        echo ""
        echo "🔍 Debug steps:"
        echo "1. Verify you're in the correct directory with 'frontend' folder"
        echo "2. Check that frontend/package.json exists"
        echo "3. Try: docker build --progress=plain -f Dockerfile.fixed -t portfolio-test ."
    fi
    
elif command -v sudo docker &> /dev/null; then
    echo "🐳 Docker found (requires sudo), attempting build..."
    
    if sudo docker build -f Dockerfile.fixed -t portfolio-test . --no-cache; then
        echo ""
        echo "🎉 SUCCESS! Docker build completed!"
        echo ""
        echo "🚀 To run your portfolio:"
        echo "   sudo docker run -d -p 80:3000 --name my-portfolio portfolio-test"
        echo ""
        echo "🌐 Then visit: http://localhost"
    else
        echo ""
        echo "❌ Docker build failed even with sudo"
    fi
else
    echo "⚠️  Docker not found. The Dockerfile has been created."
    echo "   Run: docker build -f Dockerfile.fixed -t portfolio-test ."
fi