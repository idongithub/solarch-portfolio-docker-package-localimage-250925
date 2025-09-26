#!/bin/bash
# Docker Commands Generator for Individual Containers
# Generates complete docker run commands with all parameters

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

highlight() {
    echo -e "${GREEN}$1${NC}"
}

section() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

show_usage() {
    cat << EOF
Docker Commands Generator for Individual Containers

Usage: $0 CONTAINER_TYPE [OPTIONS]

CONTAINER TYPES:
    frontend-http      Generate HTTP frontend docker command
    frontend-https     Generate HTTPS frontend docker command
    backend           Generate backend API docker command
    mongodb           Generate MongoDB docker command
    redis             Generate Redis docker command
    prometheus        Generate Prometheus docker command
    grafana           Generate Grafana docker command
    loki              Generate Loki docker command
    mongo-express     Generate Mongo Express docker command
    all               Generate commands for all containers

OPTIONS:
    -h, --help                    Show this help message
    --with-params                 Show command with example parameters
    --copy-ready                  Format for easy copy-paste
    --docker-compose              Generate docker-compose equivalent

EXAMPLES:
    # Generate basic backend command
    $0 backend

    # Generate backend command with parameters
    $0 backend --with-params

    # Generate all commands
    $0 all --copy-ready

EOF
}

# Generate frontend HTTP command
generate_frontend_http() {
    local with_params="$1"
    
    section "Frontend HTTP Container"
    
    if [ "$with_params" = "true" ]; then
        highlight "# Docker run command with custom parameters:"
        cat << 'EOF'
docker run -d \
  --name portfolio-frontend-http \
  --network portfolio-network \
  -p 3000:80 \
  --restart unless-stopped \
  portfolio-frontend-http:latest
EOF
        
        echo ""
        highlight "# Build image first:"
        echo "docker build -f Dockerfile.npm.optimized -t portfolio-frontend-http:latest ."
        
    else
        highlight "# Basic command:"
        echo "docker run -d --name portfolio-frontend-http --network portfolio-network -p 8080:80 portfolio-frontend-http:latest"
    fi
    
    echo ""
    echo "Access: http://localhost:8080 (or custom port)"
}

# Generate frontend HTTPS command
generate_frontend_https() {
    local with_params="$1"
    
    section "Frontend HTTPS Container"
    
    if [ "$with_params" = "true" ]; then
        highlight "# Docker run command with SSL certificates:"
        cat << 'EOF'
docker run -d \
  --name portfolio-frontend-https \
  --network portfolio-network \
  -p 3443:443 \
  -p 3080:80 \
  -v ./ssl:/etc/nginx/ssl:ro \
  --restart unless-stopped \
  portfolio-frontend-https:latest
EOF
        
        echo ""
        highlight "# Build image first:"
        echo "docker build -f Dockerfile.https.optimized -t portfolio-frontend-https:latest ."
        
    else
        highlight "# Basic command:"
        echo "docker run -d --name portfolio-frontend-https --network portfolio-network -p 8443:443 -p 8080:80 -v ./ssl:/etc/nginx/ssl:ro portfolio-frontend-https:latest"
    fi
    
    echo ""
    echo "Access: https://localhost:8443 (or custom port)"
}

# Generate backend command
generate_backend() {
    local with_params="$1"
    
    section "Backend API Container"
    
    if [ "$with_params" = "true" ]; then
        highlight "# Docker run command with full SMTP configuration:"
        cat << 'EOF'
docker run -d \
  --name portfolio-backend \
  --network portfolio-network \
  -p 3001:8001 \
  -e MONGO_URL=mongodb://portfolio-mongodb:27017/portfolio \
  -e SMTP_SERVER=smtp.gmail.com \
  -e SMTP_PORT=587 \
  -e SMTP_USE_TLS=true \
  -e SMTP_USE_SSL=false \
  -e SMTP_STARTTLS=true \
  -e SMTP_TIMEOUT=30 \
  -e SMTP_RETRIES=3 \
  -e SMTP_DEBUG=false \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-16-char-app-password \
  -e FROM_EMAIL=your-email@gmail.com \
  -e TO_EMAIL=kamal.singh@architecturesolutions.co.uk \
  -e EMAIL_SUBJECT_PREFIX="[Portfolio Contact]" \
  -e EMAIL_RATE_LIMIT_WINDOW=3600 \
  -e EMAIL_RATE_LIMIT_MAX=10 \
  -e EMAIL_COOLDOWN_PERIOD=60 \
  -e SECRET_KEY=your-secret-key-change-this \
  -e CORS_ORIGINS=http://localhost:3000,https://localhost:3443 \
  -e LOG_LEVEL=INFO \
  -e ENVIRONMENT=production \
  -e STRUCTURED_LOGGING=true \
  -v ./logs:/app/logs \
  -v ./uploads:/app/uploads \
  --restart unless-stopped \
  portfolio-backend:latest
EOF
        
        echo ""
        highlight "# Build image first:"
        echo "docker build -f Dockerfile.backend.optimized -t portfolio-backend:latest ."
        
    else
        highlight "# Basic command (requires SMTP configuration):"
        echo "docker run -d --name portfolio-backend --network portfolio-network -p 8001:8001 -e MONGO_URL=mongodb://portfolio-mongodb:27017/portfolio portfolio-backend:latest"
    fi
    
    echo ""
    echo "Access: http://localhost:8001/api/ (API), http://localhost:8001/docs (Documentation)"
}

# Generate MongoDB command
generate_mongodb() {
    local with_params="$1"
    
    section "MongoDB Database Container"
    
    if [ "$with_params" = "true" ]; then
        highlight "# Docker run command with authentication and persistence:"
        cat << 'EOF'
docker run -d \
  --name portfolio-mongodb \
  --network portfolio-network \
  -p 27018:27017 \
  -v ./data/mongodb:/data/db \
  -v ./data/mongodb-config:/data/configdb \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=your-secure-mongo-password \
  -e MONGO_INITDB_DATABASE=portfolio \
  --restart unless-stopped \
  mongo:6.0-alpine --quiet --logpath /dev/null
EOF
        
    else
        highlight "# Basic command:"
        echo "docker run -d --name portfolio-mongodb --network portfolio-network -p 27017:27017 -v ./data/mongodb:/data/db mongo:6.0-alpine --quiet"
    fi
    
    echo ""
    echo "Access: mongodb://localhost:27017 (or custom port)"
}

# Generate Redis command
generate_redis() {
    local with_params="$1"
    
    section "Redis Cache Container"
    
    if [ "$with_params" = "true" ]; then
        highlight "# Docker run command with authentication and persistence:"
        cat << 'EOF'
docker run -d \
  --name portfolio-redis \
  --network portfolio-network \
  -p 6380:6379 \
  -v ./data/redis:/data \
  --restart unless-stopped \
  redis:7-alpine sh -c 'redis-server --appendonly yes --requirepass your-redis-password --maxmemory 256mb --maxmemory-policy allkeys-lru'
EOF
        
    else
        highlight "# Basic command:"
        echo "docker run -d --name portfolio-redis --network portfolio-network -p 6379:6379 -v ./data/redis:/data redis:7-alpine redis-server --appendonly yes"
    fi
    
    echo ""
    echo "Access: redis://localhost:6379 (or custom port)"
}

# Generate Prometheus command
generate_prometheus() {
    local with_params="$1"
    
    section "Prometheus Monitoring Container"
    
    if [ "$with_params" = "true" ]; then
        highlight "# Docker run command with custom configuration:"
        cat << 'EOF'
docker run -d \
  --name portfolio-prometheus \
  --network portfolio-network \
  -p 9091:9090 \
  -v ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro \
  -v ./monitoring/alert_rules.yml:/etc/prometheus/alert_rules.yml:ro \
  -v ./data/prometheus:/prometheus \
  --restart unless-stopped \
  prom/prometheus:latest \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/prometheus \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.console.templates=/etc/prometheus/consoles \
    --storage.tsdb.retention.time=15d \
    --web.enable-lifecycle
EOF
        
    else
        highlight "# Basic command:"
        echo "docker run -d --name portfolio-prometheus --network portfolio-network -p 9090:9090 -v ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro prom/prometheus:latest"
    fi
    
    echo ""
    echo "Access: http://localhost:9090"
}

# Generate Grafana command
generate_grafana() {
    local with_params="$1"
    
    section "Grafana Dashboard Container"
    
    if [ "$with_params" = "true" ]; then
        highlight "# Docker run command with custom admin password:"
        cat << 'EOF'
docker run -d \
  --name portfolio-grafana \
  --network portfolio-network \
  -p 3030:3000 \
  -v ./data/grafana:/var/lib/grafana \
  -v ./monitoring/grafana/provisioning:/etc/grafana/provisioning \
  -e GF_SECURITY_ADMIN_PASSWORD=your-secure-grafana-password \
  -e GF_INSTALL_PLUGINS=grafana-piechart-panel \
  --restart unless-stopped \
  grafana/grafana:latest
EOF
        
    else
        highlight "# Basic command:"
        echo "docker run -d --name portfolio-grafana --network portfolio-network -p 3000:3000 -e GF_SECURITY_ADMIN_PASSWORD=admin grafana/grafana:latest"
    fi
    
    echo ""
    echo "Access: http://localhost:3000 (admin/your-password)"
}

# Generate Loki command
generate_loki() {
    local with_params="$1"
    
    section "Loki Log Aggregation Container"
    
    if [ "$with_params" = "true" ]; then
        highlight "# Docker run command with custom configuration:"
        cat << 'EOF'
docker run -d \
  --name portfolio-loki \
  --network portfolio-network \
  -p 3101:3100 \
  -v ./data/loki:/loki \
  -v ./monitoring/loki-config.yml:/etc/loki/local-config.yaml \
  --restart unless-stopped \
  grafana/loki:latest -config.file=/etc/loki/local-config.yaml
EOF
        
    else
        highlight "# Basic command:"
        echo "docker run -d --name portfolio-loki --network portfolio-network -p 3100:3100 grafana/loki:latest"
    fi
    
    echo ""
    echo "Access: http://localhost:3100 (API endpoint, use via Grafana)"
}

# Generate Mongo Express command
generate_mongo_express() {
    local with_params="$1"
    
    section "Mongo Express Database Admin Container"
    
    if [ "$with_params" = "true" ]; then
        highlight "# Docker run command with MongoDB connection:"
        cat << 'EOF'
docker run -d \
  --name portfolio-mongo-express \
  --network portfolio-network \
  -p 8082:8081 \
  -e ME_CONFIG_MONGODB_SERVER=portfolio-mongodb \
  -e ME_CONFIG_MONGODB_PORT=27017 \
  -e ME_CONFIG_MONGODB_ADMINUSERNAME=admin \
  -e ME_CONFIG_MONGODB_ADMINPASSWORD=your-mongo-password \
  -e ME_CONFIG_MONGODB_AUTH_DATABASE=admin \
  -e ME_CONFIG_BASICAUTH_USERNAME=admin \
  -e ME_CONFIG_BASICAUTH_PASSWORD=your-admin-password \
  -e ME_CONFIG_MONGODB_ENABLE_ADMIN=true \
  --restart unless-stopped \
  mongo-express:1.0.0-alpha
EOF
        
    else
        highlight "# Basic command:"
        echo "docker run -d --name portfolio-mongo-express --network portfolio-network -p 8081:8081 -e ME_CONFIG_MONGODB_SERVER=portfolio-mongodb mongo-express:1.0.0-alpha"
    fi
    
    echo ""
    echo "Access: http://localhost:8081 (admin/admin123)"
}

# Generate all commands
generate_all() {
    local with_params="$1"
    
    log "Generating Docker commands for all containers..."
    echo ""
    
    # First, create network
    highlight "# Create Docker network first:"
    echo "docker network create portfolio-network"
    echo ""
    
    generate_mongodb "$with_params"
    generate_redis "$with_params"
    generate_backend "$with_params"
    generate_frontend_http "$with_params"
    generate_frontend_https "$with_params"
    generate_prometheus "$with_params"
    generate_grafana "$with_params"
    generate_loki "$with_params"
    generate_mongo_express "$with_params"
    
    section "Complete Startup Sequence"
    highlight "# Start containers in dependency order:"
    cat << 'EOF'
# 1. Create network
docker network create portfolio-network

# 2. Start database services first
docker run -d --name portfolio-mongodb --network portfolio-network -p 27017:27017 -v ./data/mongodb:/data/db mongo:6.0-alpine --quiet
docker run -d --name portfolio-redis --network portfolio-network -p 6379:6379 -v ./data/redis:/data redis:7-alpine redis-server --appendonly yes

# 3. Start backend API
docker run -d --name portfolio-backend --network portfolio-network -p 8001:8001 -e MONGO_URL=mongodb://portfolio-mongodb:27017/portfolio portfolio-backend:latest

# 4. Start frontend services
docker run -d --name portfolio-frontend-http --network portfolio-network -p 8080:80 portfolio-frontend-http:latest
docker run -d --name portfolio-frontend-https --network portfolio-network -p 8443:443 -p 8080:80 -v ./ssl:/etc/nginx/ssl:ro portfolio-frontend-https:latest

# 5. Start monitoring stack
docker run -d --name portfolio-prometheus --network portfolio-network -p 9090:9090 -v ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro prom/prometheus:latest
docker run -d --name portfolio-grafana --network portfolio-network -p 3000:3000 -e GF_SECURITY_ADMIN_PASSWORD=admin grafana/grafana:latest
docker run -d --name portfolio-loki --network portfolio-network -p 3100:3100 grafana/loki:latest

# 6. Start admin tools
docker run -d --name portfolio-mongo-express --network portfolio-network -p 8081:8081 -e ME_CONFIG_MONGODB_SERVER=portfolio-mongodb mongo-express:1.0.0-alpha
EOF
}

# Main execution
main() {
    local container_type="$1"
    local with_params="false"
    
    if [[ "$2" == "--with-params" ]] || [[ "$3" == "--with-params" ]]; then
        with_params="true"
    fi
    
    case $container_type in
        frontend-http)
            generate_frontend_http "$with_params"
            ;;
        frontend-https)
            generate_frontend_https "$with_params"
            ;;
        backend)
            generate_backend "$with_params"
            ;;
        mongodb)
            generate_mongodb "$with_params"
            ;;
        redis)
            generate_redis "$with_params"
            ;;
        prometheus)
            generate_prometheus "$with_params"
            ;;
        grafana)
            generate_grafana "$with_params"
            ;;
        loki)
            generate_loki "$with_params"
            ;;
        mongo-express)
            generate_mongo_express "$with_params"
            ;;
        all)
            generate_all "$with_params"
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
    
    echo ""
    log "Commands generated successfully!"
    echo ""
    echo "💡 Tips:"
    echo "   • Run with --with-params to see examples with all parameters"
    echo "   • Make sure to build custom images first (frontend-http, frontend-https, backend)"
    echo "   • Create the portfolio-network before running containers"
    echo "   • Check MONITORING_ACCESS_GUIDE.md for access URLs and credentials"
}

# Parse arguments
if [[ $# -eq 0 ]]; then
    show_usage
    exit 1
fi

main "$@"