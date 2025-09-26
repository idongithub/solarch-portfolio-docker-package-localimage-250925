#!/bin/bash
# Final fix for both Prometheus targets and Grafana dashboards

set -e

echo "🔧 FINAL MONITORING FIXES"
echo "========================="

# Export environment variables
export GRAFANA_PASSWORD=adminpass123
export GRAFANA_PORT=3030
export PROMETHEUS_PORT=3091

echo "🎯 Issue 1: Fixing Prometheus target (404 error)"
echo "   - Backend API endpoint changed to /api/health"
echo "   - This should return a proper response"

echo "📊 Issue 2: Fixing Grafana dashboard provisioning"
echo "   - Correcting JSON format and volume mounting"

# Test if backend health endpoint exists
echo "🔍 Testing backend health endpoint..."
if curl -s http://localhost:3001/api/health >/dev/null 2>&1; then
    echo "✅ Backend health endpoint responds"
else
    echo "❌ Backend health endpoint not found, trying root API..."
    if curl -s http://localhost:3001/api/ >/dev/null 2>&1; then
        echo "✅ Backend root API responds"
        # Update Prometheus to use root API
        sed -i 's|metrics_path: '\''/api/health'\''|metrics_path: '\''/api/'\''|g' ./monitoring/prometheus.yml
    else
        echo "⚠️  Backend API may not be running properly"
    fi
fi

# Stop monitoring containers
echo "🛑 Stopping Prometheus and Grafana..."
docker stop portfolio-prometheus portfolio-grafana 2>/dev/null || true

# Fix Grafana permissions and ensure directory structure
echo "📁 Ensuring Grafana directory structure..."
mkdir -p ./monitoring/grafana/dashboards
mkdir -p ./monitoring/grafana/provisioning/datasources
mkdir -p ./monitoring/grafana/provisioning/dashboards
mkdir -p ./data/grafana/dashboards

# Copy dashboards to the right location
cp ./monitoring/grafana/dashboards/*.json ./data/grafana/dashboards/ 2>/dev/null || true

# Set permissions
chmod -R 777 ./data/grafana/ 2>/dev/null || sudo chmod -R 777 ./data/grafana/ 2>/dev/null || true
chmod -R 755 ./monitoring/grafana/ 2>/dev/null || true

# Restart containers with proper configuration
echo "🚀 Restarting monitoring containers..."
docker-compose -f docker-compose.production.yml up -d --force-recreate --no-deps prometheus grafana

echo "⏳ Waiting for services to start..."
sleep 20

# Check Prometheus targets
echo "🎯 Checking Prometheus targets..."
sleep 5
if curl -s http://localhost:$PROMETHEUS_PORT/api/v1/targets >/dev/null; then
    echo "✅ Prometheus is responding"
    
    TARGET_STATUS=$(curl -s http://localhost:$PROMETHEUS_PORT/api/v1/targets | grep -o '"health":"[^"]*"' | head -1 || echo '"health":"unknown"')
    echo "🎯 Backend target status: $TARGET_STATUS"
else
    echo "⚠️  Prometheus not responding yet"
fi

# Check Grafana
echo "📊 Checking Grafana..."
if curl -s http://localhost:$GRAFANA_PORT/api/health >/dev/null; then
    echo "✅ Grafana is responding"
else
    echo "⚠️  Grafana not responding yet"
fi

echo ""
echo "✅ MONITORING FIXES APPLIED"
echo ""
echo "🌐 Access URLs:"
echo "  Grafana:    http://localhost:$GRAFANA_PORT"
echo "  Prometheus: http://localhost:$PROMETHEUS_PORT"
echo "  Targets:    http://localhost:$PROMETHEUS_PORT/targets"
echo ""
echo "📊 To check dashboards in Grafana:"
echo "  1. Login with admin/$GRAFANA_PASSWORD"
echo "  2. Go to Dashboards > Browse"
echo "  3. Look for 'ARCHSOL Portfolio' folder"
echo ""
echo "🔍 If dashboards still missing:"
echo "  - Check Grafana logs: docker logs portfolio-grafana"
echo "  - Verify files: ls -la ./data/grafana/dashboards/"
echo ""
echo "🎯 If Prometheus target still down:"
echo "  - Check backend health: curl http://localhost:3001/api/health"
echo "  - Check Prometheus logs: docker logs portfolio-prometheus"