#!/bin/bash

# Final Working Docker Solution - Uses Ubuntu base for better compatibility

set -e

echo "🐳 Final Working Docker Build"
echo "============================"

# Create Dockerfile using Ubuntu base (more compatible than Alpine)
cat > Dockerfile << 'EOF'
# Use Ubuntu base image for better compatibility
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=18

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install Yarn globally
RUN npm install -g yarn

# Set working directory
WORKDIR /app

# Copy package.json and yarn.lock (if exists)
COPY frontend/package.json ./
COPY frontend/yarn.loc[k] ./yarn.lock* 

# Install dependencies using yarn (as the project was designed for)
RUN yarn install --frozen-lockfile || yarn install

# Copy configuration files
COPY frontend/craco.config.js ./
COPY frontend/tailwind.config.js ./
COPY frontend/postcss.config.js ./

# Copy source code
COPY frontend/src ./src
COPY frontend/public ./public

# Copy any environment files
COPY frontend/.env* ./ 2>/dev/null || true

# Build the application
RUN yarn build

# Install serve globally
RUN npm install -g serve

# Create a simple start script
RUN echo '#!/bin/bash\necho "🚀 Starting IT Portfolio..."\nserve -s build -l 3000' > /start.sh && \
    chmod +x /start.sh

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3000 || exit 1

# Start the application
CMD ["/start.sh"]
EOF

echo "✅ Ubuntu-based Dockerfile created"

# Build the image
echo "🔨 Building Docker image (this will take 10-15 minutes)..."
sudo docker build -t kamal-portfolio . --no-cache

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 BUILD SUCCESSFUL!"
    echo ""
    
    # Test the image
    echo "🧪 Testing the Docker image..."
    sudo docker run -d -p 3002:3000 --name portfolio-test kamal-portfolio
    
    if [ $? -eq 0 ]; then
        echo "✅ Container started successfully"
        
        # Wait for startup
        echo "⏳ Waiting for application startup (20 seconds)..."
        sleep 20
        
        # Test if responding
        if curl -f -s http://localhost:3002 >/dev/null 2>&1; then
            echo "✅ APPLICATION IS WORKING!"
            echo ""
            echo "🎉 SUCCESS! Your IT Portfolio is ready!"
            echo ""
            echo "🚀 To deploy your portfolio:"
            echo "   sudo docker run -d -p 80:3000 --name my-portfolio kamal-portfolio"
            echo ""
            echo "🌐 Then visit: http://localhost"
            echo ""
            echo "📊 Your portfolio includes:"
            echo "   ✅ ARCHSOL IT Solutions branding"
            echo "   ✅ IT Portfolio Architect positioning"  
            echo "   ✅ Gen AI and Agentic AI skills"
            echo "   ✅ Professional IT imagery"
            echo "   ✅ Complete navigation"
            echo ""
        else
            echo "⚠️  Container running but may still be starting up"
            echo "   Try: curl http://localhost:3002"
        fi
        
        # Show logs
        echo "📋 Container logs:"
        sudo docker logs portfolio-test --tail 5
        
        # Cleanup test
        sudo docker stop portfolio-test
        sudo docker rm portfolio-test
        
        echo ""
        echo "✅ DOCKER BUILD AND TEST COMPLETED!"
        
    else
        echo "❌ Container failed to start"
        exit 1
    fi
    
else
    echo ""
    echo "❌ Docker build failed"
    echo ""
    echo "Try running with verbose output:"
    echo "sudo docker build -t kamal-portfolio . --progress=plain"
    exit 1
fi