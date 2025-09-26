#!/bin/bash
# EMERGENCY MongoDB Volume Fix - Forces removal of stubborn MongoDB volumes

set -e

echo "🚨 EMERGENCY MONGODB VOLUME FIX"
echo "==============================="

# Force stop and remove containers
echo "🛑 Force stopping and removing MongoDB containers..."
docker stop portfolio-mongodb 2>/dev/null || true
docker stop portfolio-mongo-express 2>/dev/null || true
docker rm -f portfolio-mongodb 2>/dev/null || true
docker rm -f portfolio-mongo-express 2>/dev/null || true

# Wait for containers to be fully removed
sleep 5

# Check what volumes exist
echo "🔍 Checking existing volumes..."
echo "Current MongoDB-related volumes:"
docker volume ls | grep -i mongo || echo "No MongoDB volumes found"

# Force remove MongoDB volumes with all possible names
echo "🗑️  Force removing MongoDB volumes..."
docker volume rm app_mongodb-data 2>/dev/null && echo "✅ Removed app_mongodb-data" || echo "❌ app_mongodb-data not found"
docker volume rm app_mongodb-config 2>/dev/null && echo "✅ Removed app_mongodb-config" || echo "❌ app_mongodb-config not found"
docker volume rm mongodb-data 2>/dev/null && echo "✅ Removed mongodb-data" || echo "❌ mongodb-data not found"
docker volume rm mongodb-config 2>/dev/null && echo "✅ Removed mongodb-config" || echo "❌ mongodb-config not found"

# Remove any volume with 'mongo' in the name
MONGO_VOLUMES=$(docker volume ls -q | grep -i mongo 2>/dev/null || true)
if [ -n "$MONGO_VOLUMES" ]; then
    echo "🔄 Found additional MongoDB volumes to remove:"
    echo "$MONGO_VOLUMES"
    echo "$MONGO_VOLUMES" | xargs docker volume rm -f
    echo "✅ All MongoDB volumes removed"
else
    echo "✅ No additional MongoDB volumes found"
fi

# Remove MongoDB images to force fresh pull
echo "🔄 Removing MongoDB images..."
docker rmi -f $(docker images -q mongo:4.2 mongo:5.0 mongo:latest 2>/dev/null) 2>/dev/null || echo "No MongoDB images to remove"

# Verify volumes are gone
echo ""
echo "✅ VERIFICATION - Remaining volumes:"
docker volume ls | grep -i mongo || echo "✅ No MongoDB volumes remain - SUCCESS!"

echo ""
echo "🎉 Emergency cleanup completed!"
echo "The WiredTiger version conflict should now be resolved."
echo ""
echo "Next step: Run ./mongodb-deploy.sh"