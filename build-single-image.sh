#!/bin/bash

# Build script for Kamal Singh Portfolio All-in-One Docker Image
# Creates a single deployable container image

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

IMAGE_NAME="kamal-singh-portfolio"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="$IMAGE_NAME:$IMAGE_TAG"

echo -e "${BLUE}=============================================="
echo -e "Building Kamal Singh Portfolio Single Image"
echo -e "==============================================${NC}"

# Function to log with timestamp
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Please install Docker first.${NC}"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "Dockerfile.all-in-one" ]; then
    echo -e "${RED}❌ Dockerfile.all-in-one not found. Please run this script from the portfolio root directory.${NC}"
    exit 1
fi

log "${PURPLE}🏗️ Starting build process...${NC}"

# Clean up any previous builds
log "🧹 Cleaning up previous builds..."
docker image rm "$FULL_IMAGE_NAME" 2>/dev/null || true

# Build the image
log "🔨 Building Docker image: $FULL_IMAGE_NAME"
log "📦 This may take several minutes as we install all dependencies..."

docker build \
    -f Dockerfile.all-in-one \
    -t "$FULL_IMAGE_NAME" \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    . || {
    echo -e "${RED}❌ Docker build failed${NC}"
    exit 1
}

# Get image size
IMAGE_SIZE=$(docker images --format "table {{.Size}}" "$FULL_IMAGE_NAME" | tail -n 1)

log "${GREEN}✅ Build completed successfully!${NC}"
echo ""
echo -e "${BLUE}📊 Image Information:${NC}"
echo -e "  📦 Image Name: $FULL_IMAGE_NAME"
echo -e "  📏 Image Size: $IMAGE_SIZE"
echo -e "  🏷️ Image ID: $(docker images --format '{{.ID}}' "$FULL_IMAGE_NAME")"
echo ""

# Show usage instructions
echo -e "${BLUE}🚀 Usage Instructions:${NC}"
echo ""
echo -e "${YELLOW}1. Quick Start (HTTP only):${NC}"
echo -e "   docker run -d -p 80:80 \\"
echo -e "     -e SMTP_USERNAME=your-email@gmail.com \\"
echo -e "     -e SMTP_PASSWORD=your-app-password \\"
echo -e "     --name portfolio \\"
echo -e "     $FULL_IMAGE_NAME"
echo ""

echo -e "${YELLOW}2. Full Configuration (HTTP + HTTPS):${NC}"
echo -e "   docker run -d \\"
echo -e "     -p 80:80 \\"
echo -e "     -p 443:443 \\"
echo -e "     -e SMTP_SERVER=smtp.gmail.com \\"
echo -e "     -e SMTP_USERNAME=your-email@gmail.com \\"
echo -e "     -e SMTP_PASSWORD=your-app-password \\"
echo -e "     -e TO_EMAIL=kamal.singh@architecturesolutions.co.uk \\"
echo -e "     -e WEBSITE_URL=https://yourdomain.com \\"
echo -e "     --name portfolio \\"
echo -e "     $FULL_IMAGE_NAME"
echo ""

echo -e "${YELLOW}3. Custom Ports:${NC}"
echo -e "   docker run -d \\"
echo -e "     -p 8080:80 \\"
echo -e "     -p 8443:443 \\"
echo -e "     -e HTTP_PORT=80 \\"
echo -e "     -e HTTPS_PORT=443 \\"
echo -e "     -e SMTP_USERNAME=your-email@gmail.com \\"
echo -e "     -e SMTP_PASSWORD=your-app-password \\"
echo -e "     --name portfolio \\"
echo -e "     $FULL_IMAGE_NAME"
echo ""

echo -e "${BLUE}📍 Access URLs (after starting):${NC}"
echo -e "  🌐 Portfolio: http://localhost"
echo -e "  🔧 Backend API: http://localhost/api"
echo -e "  📚 API Docs: http://localhost/api/docs"
echo -e "  🔒 HTTPS: https://localhost (with self-signed cert)"
echo ""

echo -e "${BLUE}🛠️ Management Commands:${NC}"
echo -e "  docker logs portfolio          # View container logs"
echo -e "  docker exec -it portfolio bash # Access container shell"
echo -e "  docker stop portfolio          # Stop container"
echo -e "  docker start portfolio         # Start container"
echo -e "  docker rm portfolio            # Remove container"
echo ""

echo -e "${BLUE}💾 Save/Load Image:${NC}"
echo -e "  docker save $FULL_IMAGE_NAME | gzip > kamal-singh-portfolio.tar.gz"
echo -e "  docker load < kamal-singh-portfolio.tar.gz"
echo ""

echo -e "${GREEN}🎉 Single Docker image build completed successfully!${NC}"
echo -e "${BLUE}📦 You can now deploy this image anywhere Docker runs.${NC}"