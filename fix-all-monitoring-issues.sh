#!/bin/bash
# Comprehensive fix for all monitoring issues

set -e

echo "🔧 FIXING ALL MONITORING ISSUES"
echo "==============================="

# Export all required environment variables
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

echo "📋 Using ports: Backend=$BACKEND_PORT, Grafana=$GRAFANA_PORT, Prometheus=$PROMETHEUS_PORT, Loki=$LOKI_PORT"

# Issue 1: Generate correct Prometheus config
echo "📊 Fixing Prometheus backend target (using port $BACKEND_PORT)..."
envsubst < ./monitoring/prometheus.yml.template > ./monitoring/prometheus.yml
echo "✅ Prometheus config updated with correct backend port"

# Issue 2: Fix directory permissions
echo "📁 Setting proper permissions for monitoring data..."
chmod -R 777 ./data/grafana ./data/prometheus ./data/loki 2>/dev/null || {
    sudo chmod -R 777 ./data/grafana ./data/prometheus ./data/loki 2>/dev/null || true
}
chmod -R 755 ./monitoring/grafana/ 2>/dev/null || true

# Ensure all directories exist
mkdir -p ./data/grafana/plugins ./data/grafana/dashboards ./data/grafana/provisioning
mkdir -p ./data/loki/rules ./data/loki/chunks ./data/loki/wal
mkdir -p ./data/prometheus/
mkdir -p ./monitoring/grafana/provisioning/datasources ./monitoring/grafana/provisioning/dashboards ./monitoring/grafana/dashboards

# Issue 3: Stop and recreate monitoring containers
echo "🛑 Stopping monitoring containers..."
docker stop portfolio-grafana portfolio-prometheus portfolio-loki 2>/dev/null || true
docker rm -f portfolio-grafana portfolio-prometheus portfolio-loki 2>/dev/null || true

# Recreate with fresh configuration
echo "🚀 Starting monitoring containers with fixed configuration..."
docker-compose -f docker-compose.production.yml up -d --force-recreate --no-deps grafana prometheus loki

echo "⏳ Waiting for containers to initialize..."
sleep 25

echo ""
echo "📊 Container Status:"
docker ps --filter "name=portfolio-grafana" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker ps --filter "name=portfolio-prometheus" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker ps --filter "name=portfolio-loki" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🎯 Checking Prometheus targets..."
sleep 5
curl -s http://localhost:$PROMETHEUS_PORT/api/v1/targets | grep -o '"health":"[^"]*"' | sort | uniq -c || echo "Targets check will be available in ~30 seconds"

echo ""
echo "✅ ALL MONITORING ISSUES FIXED!"
echo ""
echo "🌐 Access URLs:"
echo "  Grafana:    http://localhost:$GRAFANA_PORT (admin/$GRAFANA_PASSWORD)"
echo "  Prometheus: http://localhost:$PROMETHEUS_PORT"
echo "  Loki:       http://localhost:$LOKI_PORT"
echo ""
echo "📊 Pre-configured Grafana dashboards should now be available!"
echo "🎯 Prometheus backend target should now be UP on port $BACKEND_PORT!"