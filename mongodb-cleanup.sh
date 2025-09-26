#!/bin/bash
# MongoDB and Mongo Express Cleanup Script
# Targets only MongoDB and Mongo Express containers/images/volumes

set -e

echo "🔧 MONGODB & MONGO EXPRESS CLEANUP"
echo "=================================="

# Stop MongoDB and Mongo Express containers only
echo "🛑 Stopping MongoDB and Mongo Express containers..."
docker stop portfolio-mongodb 2>/dev/null || echo "MongoDB container not running"
docker stop portfolio-mongo-express 2>/dev/null || echo "Mongo Express container not running"

# Remove containers
echo "🗑️  Removing MongoDB and Mongo Express containers..."
docker rm -f portfolio-mongodb 2>/dev/null || echo "MongoDB container not found"
docker rm -f portfolio-mongo-express 2>/dev/null || echo "Mongo Express container not found"

# Remove MongoDB images to force fresh pull
echo "🔄 Removing MongoDB images to force fresh download..."
docker rmi -f $(docker images -q mongo:4.2 mongo:5.0 mongo:latest 2>/dev/null) 2>/dev/null || echo "No MongoDB images to remove"
docker rmi -f $(docker images -q mongo-express:latest 2>/dev/null) 2>/dev/null || echo "No Mongo Express images to remove"

# CRITICAL: Remove MongoDB data volume (this fixes the WiredTiger version conflict)
echo "⚠️  CRITICAL: MongoDB Volume Cleanup"
echo "The existing MongoDB volume contains incompatible data from MongoDB 5.x"
echo "This needs to be removed to fix the WiredTiger version conflict"
read -p "Remove MongoDB volume (THIS WILL DELETE ALL DATABASE DATA)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker volume rm app_mongodb-data 2>/dev/null || echo "MongoDB data volume not found"
    docker volume rm app_mongodb-config 2>/dev/null || echo "MongoDB config volume not found"
    echo "✅ MongoDB volumes removed - WiredTiger conflict resolved"
else
    echo "❌ Volume removal cancelled - MongoDB will continue to fail with version conflict"
    exit 1
fi

echo ""
echo "✅ MongoDB and Mongo Express cleanup completed!"
echo "You can now deploy fresh MongoDB and Mongo Express containers."