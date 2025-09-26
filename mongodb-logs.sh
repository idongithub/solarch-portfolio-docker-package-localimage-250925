#!/bin/bash
# MongoDB and Mongo Express Log Viewer

echo "📜 MONGODB & MONGO EXPRESS LOGS"
echo "==============================="

echo ""
echo "🗄️  MONGODB CONTAINER STATUS:"
docker ps --filter "name=portfolio-mongodb" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "📜 MONGODB LOGS (last 20 lines):"
docker logs --tail 20 portfolio-mongodb 2>/dev/null || echo "❌ MongoDB container not found"

echo ""
echo "🌐 MONGO EXPRESS CONTAINER STATUS:"
docker ps --filter "name=portfolio-mongo-express" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "📜 MONGO EXPRESS LOGS (last 15 lines):"
docker logs --tail 15 portfolio-mongo-express 2>/dev/null || echo "❌ Mongo Express container not found"

echo ""
echo "🔌 PORT MAPPING:"
echo "MongoDB port mapping:"
docker port portfolio-mongodb 2>/dev/null || echo "❌ No port mapping found"
echo "Mongo Express port mapping:"
docker port portfolio-mongo-express 2>/dev/null || echo "❌ No port mapping found"

echo ""
echo "🌐 NETWORK CONNECTIVITY TEST:"
docker exec portfolio-mongo-express ping -c 1 mongodb 2>/dev/null && echo "✅ Mongo Express can reach MongoDB" || echo "❌ Network connectivity issue"