#!/bin/bash
# Complete MongoDB ecosystem status check

echo "📊 MONGODB ECOSYSTEM STATUS"
echo "==========================="

echo ""
echo "🐋 CONTAINER STATUS:"
docker ps --filter "name=portfolio-mongo" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker ps --filter "name=portfolio-backup" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "portfolio-backup        Not deployed"

echo ""
echo "🏥 HEALTH STATUS:"
MONGODB_HEALTH=$(docker inspect portfolio-mongodb --format='{{.State.Health.Status}}' 2>/dev/null || echo 'no-health-check')
MONGOEXPRESS_HEALTH=$(docker inspect portfolio-mongo-express --format='{{.State.Health.Status}}' 2>/dev/null || echo 'container-not-found')
BACKUP_STATUS=$(docker inspect portfolio-backup --format='{{.State.Status}}' 2>/dev/null || echo 'not-deployed')

echo "  MongoDB:       $MONGODB_HEALTH"
echo "  Mongo Express: $MONGOEXPRESS_HEALTH"
echo "  Backup:        $BACKUP_STATUS"

echo ""
echo "🔌 PORT CONNECTIVITY TEST:"
# Test MongoDB port
if nc -z localhost 37037 2>/dev/null; then
    echo "  ✅ MongoDB port 37037: Accessible"
else
    echo "  ❌ MongoDB port 37037: Not accessible"
fi

# Test Mongo Express port
if nc -z localhost 3081 2>/dev/null; then
    echo "  ✅ Mongo Express port 3081: Accessible"
else
    echo "  ❌ Mongo Express port 3081: Not accessible"
fi

echo ""
echo "🌐 INTERNAL CONNECTIVITY:"
# Test if Mongo Express can reach MongoDB
MONGO_CONNECT=$(docker exec portfolio-mongo-express ping -c 1 mongodb 2>/dev/null && echo "✅ Connected" || echo "❌ Cannot reach")
echo "  Mongo Express → MongoDB: $MONGO_CONNECT"

# Test if backup can reach MongoDB (if backup exists)
if docker ps --filter "name=portfolio-backup" --format "{{.Names}}" | grep -q portfolio-backup; then
    BACKUP_CONNECT=$(docker exec portfolio-backup ping -c 1 mongodb 2>/dev/null && echo "✅ Connected" || echo "❌ Cannot reach")
    echo "  Backup → MongoDB: $BACKUP_CONNECT"
fi

echo ""
echo "📜 RECENT LOGS (last 5 lines each):"
echo "MongoDB:"
docker logs --tail 5 portfolio-mongodb 2>/dev/null | grep -E "(ready|listening|started)" || echo "  (No startup messages in recent logs)"

echo "Mongo Express:"
docker logs --tail 5 portfolio-mongo-express 2>/dev/null | grep -E "(connected|ready|listening)" || echo "  (No connection messages in recent logs)"

if docker ps --filter "name=portfolio-backup" -q | grep -q .; then
    echo "Backup:"
    docker logs --tail 5 portfolio-backup 2>/dev/null || echo "  (No recent backup logs)"
fi

echo ""
echo "📂 BACKUP STATUS:"
if [ -d "./backups" ]; then
    BACKUP_COUNT=$(ls -la ./backups/ 2>/dev/null | grep -v "^total" | wc -l)
    echo "  Backup directory exists: $BACKUP_COUNT items"
    if [ "$BACKUP_COUNT" -gt 2 ]; then
        echo "  Recent backups:"
        ls -lt ./backups/ | head -3 | tail -2
    fi
else
    echo "  ❌ Backup directory not found"
fi

echo ""
echo "🎯 SUMMARY:"
if [ "$MONGODB_HEALTH" = "healthy" ] && [ "$MONGOEXPRESS_HEALTH" = "healthy" ]; then
    echo "  ✅ MongoDB ecosystem is HEALTHY and ready to use!"
elif [ "$MONGOEXPRESS_HEALTH" = "unhealthy" ]; then
    echo "  ⚠️  Mongo Express health check failing (but may still work)"
    echo "  💡 Try accessing http://localhost:3081 in browser"
else
    echo "  ❌ Issues detected - check logs above"
fi