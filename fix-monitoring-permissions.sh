#!/bin/bash
# Fix permissions for monitoring stack containers

set -e

echo "🔧 FIXING MONITORING STACK PERMISSIONS"
echo "======================================"

# Export all required environment variables (same as your deployment script)
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

echo "📋 Using custom ports: Grafana=$GRAFANA_PORT, Prometheus=$PROMETHEUS_PORT, Loki=$LOKI_PORT"

# Stop problematic containers
echo "🛑 Stopping monitoring containers..."
docker stop portfolio-grafana portfolio-prometheus portfolio-loki 2>/dev/null || true

# Fix directory permissions for each service
echo "📁 Setting proper permissions for data directories..."

# Grafana (runs as user 472)
echo "Setting Grafana permissions..."
sudo chown -R 472:472 ./data/grafana/ 2>/dev/null || chmod -R 777 ./data/grafana/
mkdir -p ./data/grafana/plugins ./data/grafana/dashboards ./data/grafana/provisioning

# Prometheus (runs as user 65534:65534 or nobody)
echo "Setting Prometheus permissions..."
sudo chown -R 65534:65534 ./data/prometheus/ 2>/dev/null || chmod -R 777 ./data/prometheus/
mkdir -p ./data/prometheus/

# Loki (runs as user 10001)
echo "Setting Loki permissions..."
sudo chown -R 10001:10001 ./data/loki/ 2>/dev/null || chmod -R 777 ./data/loki/
mkdir -p ./data/loki/rules ./data/loki/chunks ./data/loki/wal

echo "✅ Permissions fixed!"

# Restart containers with new volume mounts (force recreate to apply dashboard configuration)
echo "🚀 Restarting monitoring containers with dashboard configuration..."
docker-compose -f docker-compose.production.yml up -d --force-recreate --no-deps grafana prometheus loki

echo "⏳ Waiting for containers to start..."
sleep 15

echo "📊 Container status:"
docker ps --filter "name=portfolio-grafana" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker ps --filter "name=portfolio-prometheus" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker ps --filter "name=portfolio-loki" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "✅ Monitoring stack permissions fixed and containers restarted!"
echo ""
echo "Access URLs:"
echo "  Grafana:    http://localhost:3030 (admin/adminpass123)"
echo "  Prometheus: http://localhost:3091"
echo "  Loki:       http://localhost:3300"