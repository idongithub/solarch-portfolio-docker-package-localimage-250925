#!/bin/bash
# Test Grafana Connectivity for Traefik

echo "🔍 Grafana Connectivity Test for External Traefik"
echo "=================================================="

# Get current host IP
HOST_IP=$(hostname -I | awk '{print $1}')
GRAFANA_PORT=${GRAFANA_PORT:-3030}

echo "🌐 Network Configuration:"
echo "   Ubuntu Host IP: $HOST_IP"
echo "   Traefik IP: 192.168.86.56" 
echo "   Grafana Host Port: $GRAFANA_PORT"
echo "   Expected Traefik URL: http://$HOST_IP:$GRAFANA_PORT"

echo ""
echo "🔍 Checking Grafana container status..."
if docker ps | grep -q grafana; then
    echo "✅ Grafana container is running"
    GRAFANA_CONTAINER=$(docker ps --format "{{.Names}}" | grep grafana)
    echo "   Container name: $GRAFANA_CONTAINER"
else
    echo "❌ Grafana container is NOT running"
    echo "   Available containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}" | head -5
fi

echo ""
echo "🔍 Checking port binding..."
if docker ps | grep grafana | grep -q ":$GRAFANA_PORT->"; then
    echo "✅ Grafana port $GRAFANA_PORT is properly mapped"
else
    echo "⚠️  Grafana port mapping check:"
    docker ps | grep grafana | awk '{print $NF "\t" $(NF-1)}'
fi

echo ""
echo "🧪 Testing Grafana connectivity..."

# Test local connectivity
echo "📍 Testing from Ubuntu host ($HOST_IP):"
if curl -s -I "http://localhost:$GRAFANA_PORT" | head -1 | grep -q "200\|302\|401"; then
    echo "✅ Grafana responds on localhost:$GRAFANA_PORT"
else
    echo "❌ Grafana not responding on localhost:$GRAFANA_PORT"
fi

# Test external IP connectivity (simulating Traefik)
echo "📍 Testing from external IP ($HOST_IP:$GRAFANA_PORT):"
if curl -s -I "http://$HOST_IP:$GRAFANA_PORT" --connect-timeout 5 | head -1 | grep -q "200\|302\|401"; then
    echo "✅ Grafana responds on $HOST_IP:$GRAFANA_PORT (accessible to Traefik)"
else
    echo "❌ Grafana not accessible on $HOST_IP:$GRAFANA_PORT (Traefik cannot reach)"
    echo "🔧 Checking if port is listening..."
    netstat -tlnp | grep ":$GRAFANA_PORT " || echo "Port $GRAFANA_PORT not listening"
fi

echo ""
echo "🔍 Grafana container logs (last 10 lines):"
if docker ps | grep -q grafana; then
    GRAFANA_CONTAINER=$(docker ps --format "{{.Names}}" | grep grafana)
    docker logs --tail 10 "$GRAFANA_CONTAINER" 2>/dev/null || echo "Could not retrieve logs"
else
    echo "❌ No Grafana container to check logs"
fi

echo ""
echo "📋 Diagnosis Summary:"
echo "   For Traefik (192.168.86.56) to reach Grafana:"
echo "   1. Grafana container must be running ✓/✗"
echo "   2. Port $GRAFANA_PORT must be accessible externally ✓/✗"  
echo "   3. No firewall blocking 192.168.86.56 → 192.168.86.75:$GRAFANA_PORT"
echo "   4. Grafana must be healthy and responding ✓/✗"