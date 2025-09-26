#!/bin/bash
# Quick Docker Cleanup Script - No Docker Compose Dependencies
# Fixes all container issues by forcing complete cleanup

set -e

echo "🚨 EMERGENCY DOCKER CLEANUP - Fixing all container issues..."

# Stop all portfolio containers
echo "Stopping all portfolio containers..."
docker stop $(docker ps -q --filter "name=portfolio-") 2>/dev/null || true

# Remove all portfolio containers 
echo "Removing all portfolio containers..."
docker rm -f $(docker ps -aq --filter "name=portfolio-") 2>/dev/null || true

# Remove specific problem images to force rebuild
echo "Removing problem images to force fresh build..."
docker rmi -f $(docker images -q --filter "reference=*mongo*") 2>/dev/null || true
docker rmi -f $(docker images -q --filter "reference=*portfolio*") 2>/dev/null || true
docker rmi -f $(docker images -q --filter "reference=*backend*") 2>/dev/null || true
docker rmi -f $(docker images -q --filter "reference=*frontend*") 2>/dev/null || true

# Remove all app networks
echo "Removing networks..."
docker network rm app_portfolio-network 2>/dev/null || true
docker network rm portfolio-network 2>/dev/null || true

# Clean up dangling images and build cache
echo "Cleaning up Docker cache..."
docker image prune -f 2>/dev/null || true
docker builder prune -f 2>/dev/null || true
docker system prune -f 2>/dev/null || true

echo "✅ Emergency cleanup completed!"
echo "You can now run your deployment script fresh."