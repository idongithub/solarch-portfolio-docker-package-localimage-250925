#!/bin/bash
# Debug MongoDB and Mongo Express connection issues

echo "🔍 DEBUGGING MONGODB CONNECTION ISSUES"
echo "======================================"

echo ""
echo "📋 ENVIRONMENT VARIABLES:"
echo "MONGO_PORT: ${MONGO_PORT:-'NOT SET'}"
echo "MONGO_USERNAME: ${MONGO_USERNAME:-'NOT SET'}"
echo "MONGO_EXPRESS_PORT: ${MONGO_EXPRESS_PORT:-'NOT SET'}"

echo ""
echo "🐋 CONTAINER STATUS:"
docker ps --filter "name=portfolio-mongodb" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker ps --filter "name=portfolio-mongo-express" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🔌 PORT MAPPING VERIFICATION:"
echo "Expected: Host port ${MONGO_PORT:-37037} → Container port 27017"
docker port portfolio-mongodb 2>/dev/null || echo "❌ MongoDB container not running or no port mapping"

echo ""
echo "🏥 CONTAINER HEALTH:"
docker inspect portfolio-mongodb --format='{{.State.Health.Status}}' 2>/dev/null || echo "❌ MongoDB container not found"
docker inspect portfolio-mongo-express --format='{{.State.Health.Status}}' 2>/dev/null || echo "❌ Mongo Express container not found"

echo ""
echo "📜 MONGODB RECENT LOGS:"
docker logs --tail 20 portfolio-mongodb 2>/dev/null || echo "❌ Cannot get MongoDB logs"

echo ""
echo "📜 MONGO EXPRESS RECENT LOGS:"
docker logs --tail 10 portfolio-mongo-express 2>/dev/null || echo "❌ Cannot get Mongo Express logs"

echo ""
echo "🌐 NETWORK CONNECTIVITY TEST:"
docker exec portfolio-mongo-express ping -c 2 mongodb 2>/dev/null || echo "❌ Cannot ping MongoDB from Mongo Express"

echo ""
echo "🔍 DOCKER COMPOSE CONFIG CHECK:"
echo "Checking if MONGO_PORT is properly substituted in docker-compose..."
if [ -n "$MONGO_PORT" ]; then
    echo "MONGO_PORT is set to: $MONGO_PORT"
    echo "Expected port mapping: $MONGO_PORT:27017"
else
    echo "❌ MONGO_PORT environment variable is not set!"
fi