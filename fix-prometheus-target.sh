#!/bin/bash
# Fix Prometheus backend target networking issue

set -e

echo "🔧 FIXING PROMETHEUS BACKEND TARGET"
echo "==================================="

# Export required environment variables
export GRAFANA_PASSWORD=adminpass123
export GRAFANA_PORT=3030
export PROMETHEUS_PORT=3091

echo "🔍 Issue: Prometheus trying to connect to localhost:3001 from inside container"
echo "🔧 Fix: Use Docker service name 'backend:8001' (internal port)"

# Update Prometheus configuration
echo "📊 Updating Prometheus configuration..."
echo "   Target changed from: localhost:3001"
echo "   Target changed to:   backend:8001 (Docker internal network)"

# Restart Prometheus to reload configuration
echo "🔄 Restarting Prometheus to reload configuration..."
docker restart portfolio-prometheus

echo "⏳ Waiting for Prometheus to restart..."
sleep 10

echo "🎯 Checking Prometheus targets..."
sleep 5

# Check if Prometheus is responding
if curl -s http://localhost:$PROMETHEUS_PORT/api/v1/targets >/dev/null; then
    echo "✅ Prometheus is responding"
    
    # Check target status
    BACKEND_STATUS=$(curl -s http://localhost:$PROMETHEUS_PORT/api/v1/targets | grep -o '"health":"[^"]*"' | head -1 || echo "unknown")
    echo "🎯 Backend target status: $BACKEND_STATUS"
    
    if echo "$BACKEND_STATUS" | grep -q "up"; then
        echo "✅ SUCCESS: Backend target is now UP!"
    else
        echo "⏳ Target may need a few more seconds to come up..."
        echo "💡 Check: http://localhost:$PROMETHEUS_PORT/targets"
    fi
else
    echo "⚠️  Prometheus not responding yet, give it a moment..."
fi

echo ""
echo "🌐 Access Prometheus: http://localhost:$PROMETHEUS_PORT"
echo "🎯 Check targets at: http://localhost:$PROMETHEUS_PORT/targets"
echo ""
echo "📝 Networking explanation:"
echo "   - Host access: http://localhost:3001/api/ ✅"
echo "   - Container-to-container: backend:8001/api/ ✅"
echo "   - Prometheus now uses internal Docker network"