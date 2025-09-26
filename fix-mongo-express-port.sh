#!/bin/bash
# Quick fix for Mongo Express port - use your custom port 3081

echo "🔧 FIXING MONGO EXPRESS PORT TO 3081"
echo "===================================="

# Export ALL required environment variables (same as your deploy-with-params.sh)
export HTTP_PORT=3400
export HTTPS_PORT=3443
export BACKEND_PORT=3001
export SMTP_SERVER=smtp.ionos.co.uk
export SMTP_PORT=465
export SMTP_USERNAME=kamal.singh@architecturesolutions.co.uk
export SMTP_PASSWORD=NewPass6
export FROM_EMAIL=kamal.singh@architecturesolutions.co.uk
export TO_EMAIL=kamal.singh@architecturesolutions.co.uk
export SMTP_USE_TLS=true
export REACT_APP_GA_MEASUREMENT_ID=G-B2W705K4SN
export MONGO_EXPRESS_PORT=3081
export MONGO_EXPRESS_USERNAME=admin
export MONGO_EXPRESS_PASSWORD=admin123
export MONGO_PORT=37037
export MONGO_USERNAME=admin
export MONGO_PASSWORD=securepass123
export GRAFANA_PASSWORD=adminpass123
export REDIS_PASSWORD=redispass123
export GRAFANA_PORT=3030
export LOKI_PORT=3300
export PROMETHEUS_PORT=3091
export SECRET_KEY=kamal-singh-portfolio-production-2024

echo "Setting Mongo Express port to: $MONGO_EXPRESS_PORT"
echo "MongoDB will remain on port: $MONGO_PORT"

# Stop only Mongo Express (don't touch MongoDB)
echo "🛑 Stopping Mongo Express container..."
docker stop portfolio-mongo-express 2>/dev/null || echo "Mongo Express not running"
docker rm -f portfolio-mongo-express 2>/dev/null || echo "Mongo Express container removed"

# Recreate ONLY Mongo Express with correct environment variables
echo "🚀 Starting Mongo Express with correct port..."
docker-compose -f docker-compose.production.yml up -d mongo-express

echo "⏳ Waiting for Mongo Express to restart..."
sleep 15

echo ""
echo "📊 Updated Status:"
docker ps --filter "name=portfolio-mongo-express" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🔌 Port Verification:"
MONGO_EXPRESS_PORT_CHECK=$(docker port portfolio-mongo-express 2>/dev/null | grep 8081 || echo "No port mapping found")
echo "Mongo Express port mapping: $MONGO_EXPRESS_PORT_CHECK"

if echo "$MONGO_EXPRESS_PORT_CHECK" | grep -q "3081"; then
    echo "✅ SUCCESS: Mongo Express is now on port 3081!"
else
    echo "❌ Issue: Port might not be correctly mapped"
    echo "Current port mapping: $MONGO_EXPRESS_PORT_CHECK"
fi

echo ""
echo "🌐 Access URLs:"
echo "  Mongo Express: http://localhost:3081"
echo "  Login: admin / admin123"
echo ""
echo "📜 Check logs if issues:"
echo "  docker logs portfolio-mongo-express"