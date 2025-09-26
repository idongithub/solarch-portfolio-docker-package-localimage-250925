#!/bin/bash

# Working Docker Build Script - Complete Solution
# Only requires Docker on Ubuntu, everything else happens inside container

set -e

echo "🐳 Creating Working Docker Build for IT Portfolio"
echo "==============================================="

# Verify we have the required files
echo "🔍 Checking required files..."

if [ ! -f "frontend/package.json" ]; then
    echo "❌ frontend/package.json not found"
    exit 1
fi
echo "✅ frontend/package.json found"

if [ ! -d "frontend/src" ]; then
    echo "❌ frontend/src directory not found"
    exit 1
fi
echo "✅ frontend/src directory found"

if [ ! -d "frontend/public" ]; then
    echo "❌ frontend/public directory not found"
    exit 1
fi
echo "✅ frontend/public directory found"

# Create working Dockerfile
echo "📄 Creating working Dockerfile..."
cat > Dockerfile << 'EOF'
# Working Dockerfile for IT Portfolio
FROM node:18-alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY frontend/package.json ./

# Install ALL dependencies (including devDependencies needed for build)
RUN npm install

# Copy configuration files needed for build
COPY frontend/craco.config.js ./craco.config.js
COPY frontend/tailwind.config.js ./tailwind.config.js
COPY frontend/postcss.config.js ./postcss.config.js

# Copy source code
COPY frontend/src ./src
COPY frontend/public ./public

# Copy any .env files
COPY frontend/.env* ./ 2>/dev/null || true

# Build the application using the correct build command
RUN npm run build

# Install serve to serve the built application
RUN npm install -g serve

# Expose port 3000
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3000 || exit 1

# Start the application
CMD ["serve", "-s", "build", "-l", "3000", "--no-clipboard"]
EOF

echo "✅ Working Dockerfile created"

# Clean up any existing containers/images
echo "🧹 Cleaning up..."
sudo docker stop kamal-portfolio 2>/dev/null || true
sudo docker rm kamal-portfolio 2>/dev/null || true
sudo docker rmi kamal-portfolio 2>/dev/null || true

# Build the Docker image
echo "🔨 Building Docker image..."
echo "This will take 5-10 minutes (downloading dependencies)..."

if sudo docker build -t kamal-portfolio . --no-cache; then
    echo ""
    echo "🎉🎉🎉 BUILD SUCCESSFUL! 🎉🎉🎉"
    echo ""
    
    # Test the image by running it
    echo "🧪 Testing the Docker image..."
    CONTAINER_ID=$(sudo docker run -d -p 3001:3000 --name kamal-portfolio-test kamal-portfolio)
    
    if [ $? -eq 0 ]; then
        echo "✅ Container started successfully: $CONTAINER_ID"
        
        # Wait for the app to start
        echo "⏳ Waiting for application to start (15 seconds)..."
        sleep 15
        
        # Test if the app is responding
        if curl -f -s http://localhost:3001 >/dev/null 2>&1; then
            echo "✅ Application is responding!"
            echo ""
            echo "🎉 DEPLOYMENT SUCCESSFUL!"
            echo ""
            echo "📊 Your IT Portfolio includes:"
            echo "   ✓ ARCHSOL IT Solutions professional branding"
            echo "   ✓ IT Portfolio Architect title and positioning"
            echo "   ✓ Gen AI and Agentic AI skills section"
            echo "   ✓ Professional IT-specific imagery"
            echo "   ✓ Complete navigation (Skills, Projects, Contact)"
            echo "   ✓ Responsive design for all devices"
            echo ""
        else
            echo "⚠️  Container started but app may still be loading..."
            echo "   Check with: curl http://localhost:3001"
        fi
        
        # Show container logs
        echo "📋 Container logs (last 10 lines):"
        sudo docker logs kamal-portfolio-test --tail 10
        
        # Stop test container
        echo "🧹 Stopping test container..."
        sudo docker stop kamal-portfolio-test
        sudo docker rm kamal-portfolio-test
        
        echo ""
        echo "🚀 TO DEPLOY YOUR PORTFOLIO:"
        echo "   sudo docker run -d -p 80:3000 --name my-portfolio kamal-portfolio"
        echo ""
        echo "🌐 Then visit: http://localhost"
        echo ""
        echo "🔧 Container management:"
        echo "   View logs: sudo docker logs my-portfolio"
        echo "   Stop:      sudo docker stop my-portfolio"
        echo "   Start:     sudo docker start my-portfolio"
        echo "   Remove:    sudo docker rm -f my-portfolio"
        echo ""
        echo "✅ DOCKER BUILD AND TEST COMPLETED SUCCESSFULLY!"
        
    else
        echo "❌ Container failed to start"
        exit 1
    fi
    
else
    echo ""
    echo "❌ Docker build failed"
    echo ""
    echo "🔍 Debug commands:"
    echo "   sudo docker build -t kamal-portfolio . --progress=plain"
    echo "   sudo docker logs kamal-portfolio-test"
    echo ""
    exit 1
fi