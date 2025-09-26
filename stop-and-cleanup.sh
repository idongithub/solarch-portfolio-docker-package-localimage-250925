#!/bin/bash
# Enhanced Stop Script - Removes containers, images, and optionally volumes
# Usage: ./stop-and-cleanup.sh [--remove-volumes] [--remove-all-images]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Parse arguments
REMOVE_VOLUMES=false
REMOVE_ALL_IMAGES=false
SAFE_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --remove-volumes)
            REMOVE_VOLUMES=true
            shift
            ;;
        --remove-all-images)
            REMOVE_ALL_IMAGES=true
            shift
            ;;
        --safe-mode)
            SAFE_MODE=true
            shift
            ;;
        -h|--help)
            echo "Enhanced Docker Compose Stop Script"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --remove-volumes     Remove all volumes (⚠️  DELETES DATABASE DATA)"
            echo "  --remove-all-images  Remove ALL Docker images (not just project images)"
            echo "  --safe-mode         Show what would be removed without actually removing"
            echo "  -h, --help          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                          # Stop containers and remove project images"
            echo "  $0 --remove-volumes         # Stop containers, remove images and volumes"
            echo "  $0 --remove-all-images      # Stop containers and remove ALL images"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
done

log "🛑 Stopping ARCHSOL Portfolio deployment..."

# Check if docker-compose.production.yml exists
if [ ! -f "docker-compose.production.yml" ]; then
    error "docker-compose.production.yml not found!"
    exit 1
fi

# Use Docker commands directly to avoid Docker Compose parsing issues
log "Stopping containers and removing networks..."

# Stop all portfolio containers directly
log "Stopping all portfolio containers..."
docker stop $(docker ps -q --filter "name=portfolio-") 2>/dev/null || true
success "Containers stopped"

# Remove containers
log "Removing containers..."
if [ "$REMOVE_VOLUMES" = true ]; then
    warning "⚠️  REMOVING VOLUMES - DATABASE DATA WILL BE DELETED!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker rm -f $(docker ps -aq --filter "name=portfolio-") 2>/dev/null || true
        # Remove volumes
        docker volume rm $(docker volume ls -q --filter "name=app_") 2>/dev/null || true
        success "Containers and volumes removed"
    else
        log "Volume removal cancelled. Removing containers only..."
        docker rm -f $(docker ps -aq --filter "name=portfolio-") 2>/dev/null || true
        success "Containers removed"
    fi
else
    docker rm -f $(docker ps -aq --filter "name=portfolio-") 2>/dev/null || true
    success "Containers removed"
fi

# Remove networks
log "Removing networks..."
docker network rm app_portfolio-network 2>/dev/null || true
docker network rm portfolio-network 2>/dev/null || true

# Remove project-specific images (SAFE - only portfolio related)
log "Removing project images..."

# Show what images exist for transparency
log "Current images before cleanup:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | head -10

# SAFE PATTERNS - Only remove images specifically created by this portfolio project
REMOVED_COUNT=0
IMAGES_TO_REMOVE=""

log "Scanning for portfolio images with various naming patterns..."

# Pattern 1: Your specific image pattern (solarchportfoliodockerpackage...)
SOLARCH_IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "solarchportfolio" || true)
if [ -n "$SOLARCH_IMAGES" ]; then
    log "Found solarch portfolio images:"
    echo "$SOLARCH_IMAGES"
    IMAGES_TO_REMOVE="$IMAGES_TO_REMOVE$SOLARCH_IMAGES"$'\n'
fi

# Pattern 2: Docker-compose project images (app_backend, app_frontend-http, etc.)
APP_PROJECT_IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "^app_" | grep -E "(backend|frontend|portfolio)" || true)
if [ -n "$APP_PROJECT_IMAGES" ]; then
    log "Found app_ project images:"
    echo "$APP_PROJECT_IMAGES"
    IMAGES_TO_REMOVE="$IMAGES_TO_REMOVE$APP_PROJECT_IMAGES"$'\n'
fi

# Pattern 3: Standard portfolio images
PORTFOLIO_SPECIFIC=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "portfolio.*(backend|frontend|https)" || true)
if [ -n "$PORTFOLIO_SPECIFIC" ]; then
    log "Found standard portfolio images:"
    echo "$PORTFOLIO_SPECIFIC"
    IMAGES_TO_REMOVE="$IMAGES_TO_REMOVE$PORTFOLIO_SPECIFIC"$'\n'
fi

# Pattern 4: Any image containing "portfolio" in the name
GENERAL_PORTFOLIO=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -i "portfolio" || true)
if [ -n "$GENERAL_PORTFOLIO" ]; then
    log "Found general portfolio-named images:"
    echo "$GENERAL_PORTFOLIO"
    IMAGES_TO_REMOVE="$IMAGES_TO_REMOVE$GENERAL_PORTFOLIO"$'\n'
fi

# Remove empty lines and duplicates
IMAGES_TO_REMOVE=$(echo "$IMAGES_TO_REMOVE" | sort -u | grep -v "^$" || true)

if [ -n "$IMAGES_TO_REMOVE" ]; then
    log "🎯 FOUND PORTFOLIO IMAGES TO REMOVE:"
    echo "$IMAGES_TO_REMOVE"
    echo ""
    
    if [ "$SAFE_MODE" = true ]; then
        warning "🛡️  SAFE MODE: Would remove the above images (not actually removing)"
        REMOVED_COUNT=$(echo "$IMAGES_TO_REMOVE" | wc -l)
        success "Safe mode: Would remove $REMOVED_COUNT portfolio images"
    else
        warning "⚠️  About to remove the above images. These appear to be portfolio-specific."
        read -p "Continue with image removal? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "$IMAGES_TO_REMOVE" | xargs docker rmi -f 2>/dev/null || true
            REMOVED_COUNT=$(echo "$IMAGES_TO_REMOVE" | wc -l)
            success "Removed $REMOVED_COUNT portfolio images"
        else
            log "Image removal cancelled"
        fi
    fi
else
    warning "No portfolio-specific images found to remove"
    log "This might mean:"
    log "  1. Images have different naming patterns"
    log "  2. Images were already removed"
    log "  3. No images were built yet"
    log ""
    log "All current images:"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
fi

# CRITICAL: Handle MongoDB volume cleanup for WiredTiger version conflicts
if [ "$REMOVE_VOLUMES" = false ]; then
    warning "🔧 MONGODB WIREDTIGER VERSION CHECK"
    log "Checking for MongoDB WiredTiger version conflicts..."
    
    # Check if MongoDB container exists and has WiredTiger errors
    MONGODB_ERRORS=$(docker logs portfolio-mongodb 2>/dev/null | grep -c "unsupported WiredTiger file version" || echo "0")
    
    if [ "$MONGODB_ERRORS" -gt 0 ]; then
        warning "⚠️  DETECTED: MongoDB WiredTiger version conflict!"
        warning "Your MongoDB volume contains data from a newer version that's incompatible"
        warning "with the current MongoDB image. This requires volume cleanup."
        echo ""
        read -p "Remove MongoDB volumes to fix WiredTiger conflict? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log "🗑️  Removing MongoDB volumes to fix WiredTiger conflict..."
            docker volume rm app_mongodb-data 2>/dev/null && success "Removed app_mongodb-data" || log "app_mongodb-data not found"
            docker volume rm app_mongodb-config 2>/dev/null && success "Removed app_mongodb-config" || log "app_mongodb-config not found"
            
            # Remove any additional MongoDB volumes
            MONGO_VOLUMES=$(docker volume ls -q | grep -i mongo 2>/dev/null || true)
            if [ -n "$MONGO_VOLUMES" ]; then
                echo "$MONGO_VOLUMES" | xargs docker volume rm -f 2>/dev/null || true
                success "Additional MongoDB volumes removed"
            fi
            
            success "🎉 WiredTiger conflict resolved - MongoDB will use fresh data on next deployment"
        else
            warning "MongoDB volume cleanup cancelled - WiredTiger errors may persist"
        fi
    else
        log "✅ No MongoDB WiredTiger conflicts detected"
    fi
fi

# Remove ALL images if requested
if [ "$REMOVE_ALL_IMAGES" = true ]; then
    warning "⚠️  REMOVING ALL DOCKER IMAGES!"
    read -p "This will delete ALL Docker images. Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker image prune -a -f
        success "All Docker images removed"
    else
        log "All images removal cancelled"
    fi
fi

# Clean up dangling images and build cache
log "Cleaning up dangling images and build cache..."
docker image prune -f
docker builder prune -f

# Show current Docker status
log "Current Docker status:"
echo "Images:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | head -10
echo ""
echo "Containers:"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

success "🎉 Cleanup completed successfully!"