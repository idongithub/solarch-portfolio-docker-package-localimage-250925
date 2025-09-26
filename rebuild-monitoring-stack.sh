#!/bin/bash
# Rebuild monitoring stack containers with fresh images

set -e

echo "🔄 REBUILDING MONITORING STACK WITH FRESH IMAGES"
echo "================================================"

# Set environment variables (same as your deployment)
export GRAFANA_PASSWORD=adminpass123
export GRAFANA_PORT=3030
export LOKI_PORT=3300
export PROMETHEUS_PORT=3091

# Stop and remove monitoring containers
echo "🛑 Stopping and removing monitoring containers..."
docker stop portfolio-grafana portfolio-prometheus portfolio-loki 2>/dev/null || true
docker rm -f portfolio-grafana portfolio-prometheus portfolio-loki 2>/dev/null || true

# Remove monitoring images to force fresh pull
echo "🗑️  Removing monitoring images for fresh rebuild..."
docker rmi -f $(docker images -q grafana/grafana prom/prometheus grafana/loki 2>/dev/null) 2>/dev/null || true

# Fix directory permissions
echo "📁 Setting proper permissions for data directories..."
sudo chown -R 472:472 ./data/grafana/ 2>/dev/null || chmod -R 777 ./data/grafana/
sudo chown -R 65534:65534 ./data/prometheus/ 2>/dev/null || chmod -R 777 ./data/prometheus/
sudo chown -R 10001:10001 ./data/loki/ 2>/dev/null || chmod -R 777 ./data/loki/

# Create required subdirectories
mkdir -p ./data/grafana/plugins ./data/grafana/dashboards ./data/grafana/provisioning
mkdir -p ./data/loki/rules ./data/loki/chunks ./data/loki/wal
mkdir -p ./data/prometheus/

# Rebuild and start monitoring containers with fresh images
echo "🚀 Rebuilding monitoring containers..."
docker-compose -f docker-compose.production.yml up -d --force-recreate --no-deps grafana prometheus loki

echo "⏳ Waiting for containers to initialize..."
sleep 20

echo "📊 Container status:"
docker ps --filter "name=portfolio-grafana" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker ps --filter "name=portfolio-prometheus" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker ps --filter "name=portfolio-loki" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "✅ Monitoring stack rebuilt with fresh images!"
echo ""
echo "Access URLs:"
echo "  Grafana:    http://localhost:3030 (admin/adminpass123)"
echo "  Prometheus: http://localhost:3091"
echo "  Loki:       http://localhost:3300"
echo ""
echo "🎯 Pre-configured dashboards available in Grafana!"