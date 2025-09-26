#!/bin/bash
# Fix Prometheus targets by removing invalid backend target

set -e

echo "🔧 FIXING PROMETHEUS TARGETS"
echo "============================"

export PROMETHEUS_PORT=3091

echo "🎯 Issue: Backend API returns JSON/HTML, not Prometheus metrics format"
echo "🔧 Solution: Temporarily remove backend target until metrics endpoint is implemented"

echo "📊 Current working targets will be:"
echo "   ✅ prometheus (self-monitoring)"
echo "   ✅ node-exporter (system metrics)"
echo "   ❌ portfolio-backend (removed - no metrics endpoint)"

# Restart Prometheus to reload configuration
echo "🔄 Restarting Prometheus with updated configuration..."
docker restart portfolio-prometheus

echo "⏳ Waiting for Prometheus to restart..."
sleep 15

# Check targets
echo "🎯 Checking Prometheus targets..."
if curl -s http://localhost:$PROMETHEUS_PORT/api/v1/targets >/dev/null; then
    echo "✅ Prometheus is responding"
    
    # Get target count
    UP_TARGETS=$(curl -s http://localhost:$PROMETHEUS_PORT/api/v1/targets | grep -o '"health":"up"' | wc -l || echo "0")
    DOWN_TARGETS=$(curl -s http://localhost:$PROMETHEUS_PORT/api/v1/targets | grep -o '"health":"down"' | wc -l || echo "0")
    
    echo "📊 Target Status Summary:"
    echo "   UP targets: $UP_TARGETS"
    echo "   DOWN targets: $DOWN_TARGETS"
    
    if [ "$DOWN_TARGETS" -eq 0 ]; then
        echo "🎉 SUCCESS: All remaining targets are UP!"
    else
        echo "⚠️  Some targets still down - check the targets page"
    fi
else
    echo "❌ Prometheus not responding"
fi

echo ""
echo "🌐 Access Prometheus: http://localhost:$PROMETHEUS_PORT"
echo "🎯 Check targets: http://localhost:$PROMETHEUS_PORT/targets"
echo ""
echo "📝 Note: Backend monitoring can be added later by:"
echo "   1. Implementing /metrics endpoint in FastAPI backend"
echo "   2. Using prometheus_client library"
echo "   3. Uncommenting the backend target in prometheus.yml"
echo ""
echo "✅ Prometheus should now show all targets as UP!"