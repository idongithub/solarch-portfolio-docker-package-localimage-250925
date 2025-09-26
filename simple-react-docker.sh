#!/bin/bash

# SIMPLE React Docker - No complexity, just works

set -e

echo "🚀 Creating Simple React Docker Build"
echo "===================================="

# Create the simplest possible Dockerfile
cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copy package.json only
COPY frontend/package.json ./

# Use npm and ignore yarn.lock completely
RUN npm install --legacy-peer-deps

# Copy everything else
COPY frontend/ ./

# Simple build
RUN npm run build

# Install serve
RUN npm install -g serve

EXPOSE 3000

CMD ["serve", "-s", "build", "-l", "3000"]
EOF

echo "✅ Simple Dockerfile created"

# Build it
echo "🔨 Building..."
sudo docker build -t simple-portfolio . --no-cache

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 BUILD SUCCESS!"
    echo ""
    echo "🚀 Run with:"
    echo "sudo docker run -d -p 80:3000 --name portfolio simple-portfolio"
    echo ""
    echo "🌐 Visit: http://localhost"
else
    echo "❌ Failed"
fi