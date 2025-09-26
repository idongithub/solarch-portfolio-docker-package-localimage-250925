#!/bin/bash
# Docker Deployment Verification Script

echo "🔍 Verifying Full Docker Deployment..."
echo ""

# Check if Docker is running
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    echo "Please install Docker first using the setup guide"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running"
    echo "Please start Docker: sudo systemctl start docker"
    exit 1
fi

echo "✅ Docker is available and running"
echo ""

# Check container status
echo "📊 Container Status:"
echo "==================="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep portfolio || echo "No portfolio containers found"
echo ""

# Check for unhealthy containers
echo "🏥 Health Check Status:"
echo "======================"
unhealthy=$(docker ps --filter "health=unhealthy" --format "{{.Names}}" | grep portfolio)
if [ -z "$unhealthy" ]; then
    echo "✅ All containers are healthy"
else
    echo "❌ Unhealthy containers:"
    echo "$unhealthy"
fi
echo ""

# Test service connectivity
echo "🌐 Service Connectivity Tests:"
echo "=============================="

services=(
    "3400|Frontend HTTP|http://localhost:3400/"
    "3443|Frontend HTTPS|https://localhost:3443/"
    "3001|Backend API|http://localhost:3001/api/health"
    "3081|Mongo Express|http://localhost:3081/"
    "3030|Grafana|http://localhost:3030/"
    "3091|Prometheus|http://localhost:3091/"
    "3300|Loki|http://localhost:3300/ready"
)

for service in "${services[@]}"; do
    IFS='|' read -r port name url <<< "$service"
    
    # Check if port is listening
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo "✅ $name (port $port) - Port is open"
        
        # Test HTTP connectivity (only for HTTP services)
        if [[ $url == http* ]]; then
            if curl -f -s --connect-timeout 5 "$url" > /dev/null 2>&1; then
                echo "   ✅ HTTP response OK"
            else
                echo "   ❌ HTTP response failed"
            fi
        fi
    else
        echo "❌ $name (port $port) - Port not listening"
    fi
done

echo ""

# MongoDB specific checks
echo "🗄️  MongoDB Connection Test:"
echo "============================"
if docker ps --format "{{.Names}}" | grep -q portfolio-mongodb; then
    if docker exec portfolio-mongodb mongosh --username admin --password securepass123 --authenticationDatabase admin --eval "db.adminCommand('ping')" &>/dev/null; then
        echo "✅ MongoDB authentication successful"
    else
        echo "❌ MongoDB authentication failed"
        echo "   Check logs: docker logs portfolio-mongodb"
    fi
else
    echo "❌ MongoDB container not found"
fi

echo ""

# Show access URLs
echo "🔗 Access URLs:"
echo "==============="
echo "Portfolio HTTP:   http://localhost:3400"
echo "Portfolio HTTPS:  https://localhost:3443"
echo "Backend API:      http://localhost:3001/docs"
echo "Mongo Express:    http://localhost:3081"
echo "Grafana:          http://localhost:3030"
echo "Prometheus:       http://localhost:3091"
echo "Loki:             http://localhost:3300"
echo ""

# Docker compose status
echo "🐳 Docker Compose Status:"
echo "========================="
if [ -f "docker-compose.production.yml" ]; then
    echo "✅ docker-compose.production.yml found"
    
    # Check if services are defined
    services_count=$(docker-compose -f docker-compose.production.yml config --services | wc -l)
    echo "📦 Services defined: $services_count"
else
    echo "❌ docker-compose.production.yml not found"
fi

echo ""
echo "🎉 Verification complete!"
echo ""
echo "If you see issues above, check container logs:"
echo "docker logs portfolio-backend"
echo "docker logs portfolio-mongodb"
echo "docker logs portfolio-mongo-express"