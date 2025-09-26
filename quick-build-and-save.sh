#!/bin/bash

# Quick build and save script for Kamal Singh Portfolio
# Builds the Docker image and saves it to a file for sharing

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

IMAGE_NAME="kamal-singh-portfolio:latest"
OUTPUT_FILE="kamal-singh-portfolio-$(date +%Y%m%d).tar.gz"

echo -e "${BLUE}🏗️ Kamal Singh Portfolio - Build and Save${NC}"
echo "=============================================="

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Install Docker first:${NC}"
    echo "📖 https://docs.docker.com/get-docker/"
    exit 1
fi

# Check files
if [ ! -f "Dockerfile.all-in-one" ]; then
    echo -e "${RED}❌ Dockerfile.all-in-one not found${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Building Docker image (10-15 minutes)...${NC}"
echo "This creates a complete portfolio with all services"
echo ""

# Build with progress
docker build -f Dockerfile.all-in-one -t "$IMAGE_NAME" . || {
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
}

echo -e "${GREEN}✅ Build completed!${NC}"

# Get image size
IMAGE_SIZE=$(docker images --format "table {{.Size}}" "$IMAGE_NAME" | tail -n 1)
echo -e "${BLUE}📊 Image size: $IMAGE_SIZE${NC}"

# Save to compressed file
echo -e "${YELLOW}💾 Saving image to $OUTPUT_FILE...${NC}"
docker save "$IMAGE_NAME" | gzip > "$OUTPUT_FILE"

# Get file size
FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
echo -e "${GREEN}✅ Image saved: $OUTPUT_FILE ($FILE_SIZE)${NC}"

echo ""
echo -e "${BLUE}📦 To use on another machine:${NC}"
echo "1. Copy $OUTPUT_FILE to target machine"
echo "2. Load image: docker load < $OUTPUT_FILE"
echo "3. Run: docker run -d -p 80:80 --name portfolio $IMAGE_NAME"
echo ""

echo -e "${BLUE}🚀 To run locally now:${NC}"
echo "docker run -d -p 80:80 -p 443:443 \\"
echo "  -e SMTP_USERNAME=your-email@gmail.com \\"
echo "  -e SMTP_PASSWORD=your-app-password \\"
echo "  --name portfolio \\"
echo "  $IMAGE_NAME"
echo ""
echo -e "${GREEN}🎉 Build complete! Access at: http://localhost${NC}"