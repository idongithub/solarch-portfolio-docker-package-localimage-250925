#!/bin/bash

# Simple Docker Build - Only requires Docker on Ubuntu
# Everything else happens inside the container

set -e

echo "🐳 Simple Docker Build for IT Portfolio"
echo "======================================"

# Verify we have the package.json
if [ ! -f "frontend/package.json" ]; then
    echo "❌ frontend/package.json not found"
    exit 1
fi

echo "✅ frontend/package.json found"

# Create ultra-simple Dockerfile using only npm (no yarn)
echo "📄 Creating simple Dockerfile..."
cat > Dockerfile << 'EOF'
FROM node:18-alpine

# Install curl for health check
RUN apk add --no-cache curl

WORKDIR /app

# Copy package.json
COPY frontend/package.json ./

# Install dependencies using npm (already included in node image)
RUN npm install

# Copy source code
COPY frontend/src ./src
COPY frontend/public ./public

# Build the app using npm
RUN npm run build

# Install serve globally
RUN npm install -g serve

EXPOSE 3000

CMD ["serve", "-s", "build", "-l", "3000"]
EOF

echo "✅ Simple Dockerfile created"

# Build the Docker image
echo "🔨 Building Docker image..."
sudo docker build -t kamal-portfolio . --no-cache

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SUCCESS!"
    echo ""
    echo "🚀 Your IT Portfolio is ready!"
    echo ""
    echo "To run:"
    echo "  sudo docker run -d -p 80:3000 --name my-portfolio kamal-portfolio"
    echo ""
    echo "Then visit: http://localhost"
    echo ""
else
    echo "❌ Build failed"
    exit 1
fi