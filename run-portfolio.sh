#!/bin/bash

# Simple script to run the Kamal Singh Portfolio single Docker container
# Usage: ./run-portfolio.sh [email-username] [email-password]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

IMAGE_NAME="kamal-singh-portfolio:latest"
CONTAINER_NAME="portfolio"

echo -e "${BLUE}🚀 Kamal Singh Portfolio - Quick Run Script${NC}"
echo "================================================"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Please install Docker first.${NC}"
    exit 1
fi

# Check if image exists
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 Image not found. Building image first...${NC}"
    if [ -f "./build-single-image.sh" ]; then
        ./build-single-image.sh
    else
        echo -e "${RED}❌ build-single-image.sh not found. Please build the image first.${NC}"
        exit 1
    fi
fi

# Stop and remove existing container if it exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}🛑 Stopping existing container...${NC}"
    docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
    docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
fi

# Get email credentials
SMTP_USERNAME="$1"
SMTP_PASSWORD="$2"

if [ -z "$SMTP_USERNAME" ] || [ -z "$SMTP_PASSWORD" ]; then
    echo -e "${YELLOW}📧 Email Configuration${NC}"
    echo "To enable contact form email functionality, please provide:"
    echo ""
    echo "Usage: $0 <email-username> <email-password>"
    echo ""
    echo "Example:"
    echo "  $0 your-email@gmail.com your-app-password"
    echo ""
    echo -e "${YELLOW}⚠️ Running without email configuration - contact form will not send emails${NC}"
    echo ""
    
    # Run without email configuration
    echo -e "${BLUE}🌐 Starting portfolio container (HTTP only)...${NC}"
    docker run -d \
        -p 80:80 \
        --name "$CONTAINER_NAME" \
        "$IMAGE_NAME"
else
    # Run with email configuration
    echo -e "${BLUE}🌐 Starting portfolio container with email functionality...${NC}"
    docker run -d \
        -p 80:80 \
        -p 443:443 \
        -e SMTP_USERNAME="$SMTP_USERNAME" \
        -e SMTP_PASSWORD="$SMTP_PASSWORD" \
        -e TO_EMAIL="kamal.singh@architecturesolutions.co.uk" \
        -e WEBSITE_URL="http://localhost" \
        --name "$CONTAINER_NAME" \
        "$IMAGE_NAME"
fi

# Wait for container to start
echo -e "${YELLOW}⏳ Waiting for services to start...${NC}"
sleep 10

# Check container status
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${GREEN}✅ Container started successfully!${NC}"
    
    # Show access information
    echo ""
    echo -e "${BLUE}📍 Access Your Portfolio:${NC}"
    echo -e "  🌐 Website: ${GREEN}http://localhost${NC}"
    echo -e "  🔧 Backend API: ${GREEN}http://localhost/api${NC}"
    echo -e "  📚 API Docs: ${GREEN}http://localhost/api/docs${NC}"
    
    if [ ! -z "$SMTP_USERNAME" ]; then
        echo -e "  🔒 HTTPS: ${GREEN}https://localhost${NC} (self-signed cert)"
        echo -e "  📧 Email: ${GREEN}Configured${NC} (${SMTP_USERNAME} → kamal.singh@architecturesolutions.co.uk)"
    else
        echo -e "  📧 Email: ${YELLOW}Not configured${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}🛠️ Management Commands:${NC}"
    echo -e "  View logs: ${YELLOW}docker logs $CONTAINER_NAME${NC}"
    echo -e "  Stop container: ${YELLOW}docker stop $CONTAINER_NAME${NC}"
    echo -e "  Restart container: ${YELLOW}docker restart $CONTAINER_NAME${NC}"
    echo -e "  Remove container: ${YELLOW}docker rm $CONTAINER_NAME${NC}"
    
    echo ""
    echo -e "${GREEN}🎉 Your professional portfolio is now live!${NC}"
    
else
    echo -e "${RED}❌ Container failed to start${NC}"
    echo -e "${BLUE}📋 Check logs with: docker logs $CONTAINER_NAME${NC}"
    exit 1
fi