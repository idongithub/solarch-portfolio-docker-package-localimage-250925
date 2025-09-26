#!/bin/bash
# Individual Container Builder with Runtime Parameters
# Build and run individual containers with custom parameters

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

show_usage() {
    cat << EOF
Individual Container Builder and Runner

Usage: $0 CONTAINER_TYPE [OPTIONS]

CONTAINER TYPES:
    frontend-http      Build and run HTTP frontend container
    frontend-https     Build and run HTTPS frontend container  
    backend           Build and run backend API container
    mongodb           Run MongoDB container
    redis             Run Redis container
    prometheus        Run Prometheus container
    grafana           Run Grafana container
    loki              Run Loki container
    mongo-express     Run Mongo Express container

COMMON OPTIONS:
    -h, --help                    Show this help message
    -p, --port PORT              Custom port for the service
    -n, --name NAME              Custom container name
    --network NETWORK            Docker network (default: portfolio-network)
    --build-only                 Only build, don't run container
    --run-only                   Only run (skip build)
    --force-rebuild              Force rebuild of images
    --detach                     Run in background (default)
    --interactive                Run in foreground
    --remove                     Remove existing container first

FRONTEND OPTIONS (frontend-http, frontend-https):
    --ssl-cert-path PATH         SSL certificate path (HTTPS only)

BACKEND OPTIONS (backend):
    --smtp-server HOST           SMTP server (default: smtp.gmail.com)
    --smtp-port PORT             SMTP port (default: 587)
    --smtp-username EMAIL        SMTP username
    --smtp-password PASS         SMTP password  
    --smtp-use-tls BOOL          Use TLS (default: true)
    --smtp-use-ssl BOOL          Use SSL (default: false)
    --from-email EMAIL           From email address
    --to-email EMAIL             To email address
    --mongo-url URL              MongoDB connection URL
    --log-level LEVEL            Log level (DEBUG,INFO,WARNING,ERROR)
    --cors-origins ORIGINS       CORS origins (comma-separated)

DATABASE OPTIONS (mongodb):
    --mongo-username USER        Admin username (default: admin)
    --mongo-password PASS        Admin password
    --mongo-database DB          Database name (default: portfolio)
    --data-path PATH             Data persistence path

REDIS OPTIONS (redis):
    --redis-password PASS        Redis password

MONITORING OPTIONS (prometheus, grafana, loki):
    --config-path PATH           Configuration file path
    --data-path PATH             Data persistence path
    --grafana-password PASS      Grafana admin password (grafana only)

EXAMPLES:

    # Build and run HTTP frontend on custom port
    $0 frontend-http --port 3000

    # Build and run backend with Gmail SMTP
    $0 backend --port 3001 --smtp-username me@gmail.com --smtp-password mypass --from-email me@gmail.com

    # Run MongoDB with custom password and data path
    $0 mongodb --port 27018 --mongo-password securepass --data-path ./my-mongo-data

    # Build HTTPS frontend with custom SSL path
    $0 frontend-https --port 3443 --ssl-cert-path ./my-ssl-certs

    # Run Grafana with custom admin password
    $0 grafana --port 3030 --grafana-password myadminpass

    # Just build backend without running
    $0 backend --build-only

    # Run pre-built backend interactively for debugging
    $0 backend --run-only --interactive --log-level DEBUG

EOF
}

# Default values
CONTAINER_TYPE=""
CUSTOM_PORT=""
CUSTOM_NAME=""
NETWORK_NAME="portfolio-network"
BUILD_ONLY=false
RUN_ONLY=false
FORCE_REBUILD=false
DETACHED=true
REMOVE_EXISTING=false

# Backend defaults
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USE_TLS="true"
SMTP_USE_SSL="false"
MONGO_URL="mongodb://localhost:27017"
LOG_LEVEL="INFO"
CORS_ORIGINS="http://localhost:3000,http://localhost:8080,https://localhost:8443"

# Database defaults
MONGO_USERNAME="admin"
MONGO_DATABASE="portfolio"

# Parse arguments
if [[ $# -eq 0 ]]; then
    show_usage
    exit 1
fi

CONTAINER_TYPE="$1"
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -p|--port)
            CUSTOM_PORT="$2"
            shift 2
            ;;
        -n|--name)
            CUSTOM_NAME="$2"
            shift 2
            ;;
        --network)
            NETWORK_NAME="$2"
            shift 2
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --run-only)
            RUN_ONLY=true
            shift
            ;;
        --force-rebuild)
            FORCE_REBUILD=true
            shift
            ;;
        --detach)
            DETACHED=true
            shift
            ;;
        --interactive)
            DETACHED=false
            shift
            ;;
        --remove)
            REMOVE_EXISTING=true
            shift
            ;;

        # Frontend options
        --ssl-cert-path)
            SSL_CERT_PATH="$2"
            shift 2
            ;;

        # Backend options
        --smtp-server)
            SMTP_SERVER="$2"
            shift 2
            ;;
        --smtp-port)
            SMTP_PORT="$2"
            shift 2
            ;;
        --smtp-username)
            SMTP_USERNAME="$2"
            shift 2
            ;;
        --smtp-password)
            SMTP_PASSWORD="$2"
            shift 2
            ;;
        --smtp-use-tls)
            SMTP_USE_TLS="$2"
            shift 2
            ;;
        --smtp-use-ssl)
            SMTP_USE_SSL="$2"
            shift 2
            ;;
        --from-email)
            FROM_EMAIL="$2"
            shift 2
            ;;
        --to-email)
            TO_EMAIL="$2"
            shift 2
            ;;
        --mongo-url)
            MONGO_URL="$2"
            shift 2
            ;;
        --log-level)
            LOG_LEVEL="$2"
            shift 2
            ;;
        --cors-origins)
            CORS_ORIGINS="$2"
            shift 2
            ;;

        # Database options
        --mongo-username)
            MONGO_USERNAME="$2"
            shift 2
            ;;
        --mongo-password)
            MONGO_PASSWORD="$2"
            shift 2
            ;;
        --mongo-database)
            MONGO_DATABASE="$2"
            shift 2
            ;;
        --data-path)
            DATA_PATH="$2"
            shift 2
            ;;

        # Redis options
        --redis-password)
            REDIS_PASSWORD="$2"
            shift 2
            ;;

        # Monitoring options
        --config-path)
            CONFIG_PATH="$2"
            shift 2
            ;;
        --grafana-password)
            GRAFANA_PASSWORD="$2"
            shift 2
            ;;

        -*)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Set default ports and names based on container type
set_defaults() {
    case $CONTAINER_TYPE in
        frontend-http)
            DEFAULT_PORT=8080
            DEFAULT_NAME="portfolio-frontend-http"
            DOCKERFILE="Dockerfile.npm.optimized"
            ;;
        frontend-https)
            DEFAULT_PORT=8443
            DEFAULT_NAME="portfolio-frontend-https"
            DOCKERFILE="Dockerfile.https.optimized"
            ;;
        backend)
            DEFAULT_PORT=8001
            DEFAULT_NAME="portfolio-backend"
            DOCKERFILE="Dockerfile.backend.optimized"
            ;;
        mongodb)
            DEFAULT_PORT=27017
            DEFAULT_NAME="portfolio-mongodb"
            IMAGE="mongo:6.0-alpine"
            ;;
        redis)
            DEFAULT_PORT=6379
            DEFAULT_NAME="portfolio-redis"
            IMAGE="redis:7-alpine"
            ;;
        prometheus)
            DEFAULT_PORT=9090
            DEFAULT_NAME="portfolio-prometheus"
            IMAGE="prom/prometheus:latest"
            ;;
        grafana)
            DEFAULT_PORT=3000
            DEFAULT_NAME="portfolio-grafana"
            IMAGE="grafana/grafana:latest"
            ;;
        loki)
            DEFAULT_PORT=3100
            DEFAULT_NAME="portfolio-loki"
            IMAGE="grafana/loki:latest"
            ;;
        mongo-express)
            DEFAULT_PORT=8081
            DEFAULT_NAME="portfolio-mongo-express"
            IMAGE="mongo-express:1.0.0-alpha"
            ;;
        *)
            error "Unknown container type: $CONTAINER_TYPE"
            echo "Supported types: frontend-http, frontend-https, backend, mongodb, redis, prometheus, grafana, loki, mongo-express"
            exit 1
            ;;
    esac

    # Use defaults if not specified
    PORT=${CUSTOM_PORT:-$DEFAULT_PORT}
    CONTAINER_NAME=${CUSTOM_NAME:-$DEFAULT_NAME}
}

# Create network if it doesn't exist
create_network() {
    if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
        log "Creating Docker network: $NETWORK_NAME"
        docker network create "$NETWORK_NAME"
    fi
}

# Remove existing container if requested
remove_existing() {
    if [ "$REMOVE_EXISTING" = "true" ]; then
        log "Removing existing container: $CONTAINER_NAME"
        docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    fi
}

# Build container image
build_container() {
    if [ "$RUN_ONLY" = "true" ]; then
        return 0
    fi

    case $CONTAINER_TYPE in
        frontend-http|frontend-https|backend)
            local image_tag="portfolio-${CONTAINER_TYPE}:latest"
            
            if [ "$FORCE_REBUILD" = "true" ]; then
                log "Force rebuilding image: $image_tag"
                docker build --no-cache -f "$DOCKERFILE" -t "$image_tag" .
            else
                log "Building image: $image_tag"
                docker build -f "$DOCKERFILE" -t "$image_tag" .
            fi
            
            IMAGE="$image_tag"
            ;;
        *)
            log "Using pre-built image: $IMAGE"
            docker pull "$IMAGE"
            ;;
    esac
}

# Run container with specific configuration
run_container() {
    if [ "$BUILD_ONLY" = "true" ]; then
        return 0
    fi

    local run_args=()
    run_args+=("--name" "$CONTAINER_NAME")
    run_args+=("--network" "$NETWORK_NAME")
    run_args+=("-p" "${PORT}:${PORT}")

    if [ "$DETACHED" = "true" ]; then
        run_args+=("-d")
    else
        run_args+=("-it")
    fi

    case $CONTAINER_TYPE in
        frontend-http)
            run_args+=("-p" "${PORT}:80")
            ;;
            
        frontend-https)
            run_args+=("-p" "${PORT}:443")
            run_args+=("-p" "8080:80")  # HTTP redirect
            if [ -n "$SSL_CERT_PATH" ]; then
                run_args+=("-v" "${SSL_CERT_PATH}:/etc/nginx/ssl:ro")
            else
                run_args+=("-v" "./ssl:/etc/nginx/ssl:ro")
            fi
            ;;
            
        backend)
            run_args+=("-p" "${PORT}:8001")
            run_args+=("-e" "MONGO_URL=${MONGO_URL}")
            run_args+=("-e" "SMTP_SERVER=${SMTP_SERVER}")
            run_args+=("-e" "SMTP_PORT=${SMTP_PORT}")
            run_args+=("-e" "SMTP_USE_TLS=${SMTP_USE_TLS}")
            run_args+=("-e" "SMTP_USE_SSL=${SMTP_USE_SSL}")
            run_args+=("-e" "LOG_LEVEL=${LOG_LEVEL}")
            run_args+=("-e" "CORS_ORIGINS=${CORS_ORIGINS}")
            
            if [ -n "$SMTP_USERNAME" ]; then
                run_args+=("-e" "SMTP_USERNAME=${SMTP_USERNAME}")
            fi
            if [ -n "$SMTP_PASSWORD" ]; then
                run_args+=("-e" "SMTP_PASSWORD=${SMTP_PASSWORD}")
            fi
            if [ -n "$FROM_EMAIL" ]; then
                run_args+=("-e" "FROM_EMAIL=${FROM_EMAIL}")
            fi
            if [ -n "$TO_EMAIL" ]; then
                run_args+=("-e" "TO_EMAIL=${TO_EMAIL}")
            fi
            ;;
            
        mongodb)
            run_args+=("-p" "${PORT}:27017")
            if [ -n "$DATA_PATH" ]; then
                run_args+=("-v" "${DATA_PATH}:/data/db")
            else
                run_args+=("-v" "./data/mongodb:/data/db")
            fi
            
            if [ -n "$MONGO_PASSWORD" ]; then
                run_args+=("-e" "MONGO_INITDB_ROOT_USERNAME=${MONGO_USERNAME}")
                run_args+=("-e" "MONGO_INITDB_ROOT_PASSWORD=${MONGO_PASSWORD}")
                run_args+=("-e" "MONGO_INITDB_DATABASE=${MONGO_DATABASE}")
            fi
            run_args+=("--" "--quiet")
            ;;
            
        redis)
            run_args+=("-p" "${PORT}:6379")
            run_args+=("-v" "./data/redis:/data")
            
            local redis_cmd="redis-server --appendonly yes"
            if [ -n "$REDIS_PASSWORD" ]; then
                redis_cmd="$redis_cmd --requirepass ${REDIS_PASSWORD}"
            fi
            run_args+=("--" "sh" "-c" "$redis_cmd")
            ;;
            
        prometheus)
            run_args+=("-p" "${PORT}:9090")
            if [ -n "$CONFIG_PATH" ]; then
                run_args+=("-v" "${CONFIG_PATH}:/etc/prometheus/prometheus.yml:ro")
            else
                run_args+=("-v" "./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro")
            fi
            if [ -n "$DATA_PATH" ]; then
                run_args+=("-v" "${DATA_PATH}:/prometheus")
            fi
            ;;
            
        grafana)
            run_args+=("-p" "${PORT}:3000")
            if [ -n "$GRAFANA_PASSWORD" ]; then
                run_args+=("-e" "GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}")
            fi
            if [ -n "$DATA_PATH" ]; then
                run_args+=("-v" "${DATA_PATH}:/var/lib/grafana")
            fi
            ;;
            
        loki)
            run_args+=("-p" "${PORT}:3100")
            if [ -n "$CONFIG_PATH" ]; then
                run_args+=("-v" "${CONFIG_PATH}:/etc/loki/local-config.yaml")
            fi
            if [ -n "$DATA_PATH" ]; then
                run_args+=("-v" "${DATA_PATH}:/loki")
            fi
            run_args+=("-config.file=/etc/loki/local-config.yaml")
            ;;
            
        mongo-express)
            run_args+=("-p" "${PORT}:8081")
            run_args+=("-e" "ME_CONFIG_MONGODB_SERVER=portfolio-mongodb")
            run_args+=("-e" "ME_CONFIG_MONGODB_PORT=27017")
            if [ -n "$MONGO_PASSWORD" ]; then
                run_args+=("-e" "ME_CONFIG_MONGODB_ADMINUSERNAME=${MONGO_USERNAME}")
                run_args+=("-e" "ME_CONFIG_MONGODB_ADMINPASSWORD=${MONGO_PASSWORD}")
            fi
            run_args+=("-e" "ME_CONFIG_BASICAUTH_USERNAME=admin")
            run_args+=("-e" "ME_CONFIG_BASICAUTH_PASSWORD=admin123")
            ;;
    esac

    log "Running container: $CONTAINER_NAME on port $PORT"
    docker run "${run_args[@]}" "$IMAGE"
}

# Show container information
show_container_info() {
    log "Container Configuration:"
    echo "  Type: $CONTAINER_TYPE"
    echo "  Name: $CONTAINER_NAME"
    echo "  Port: $PORT"
    echo "  Network: $NETWORK_NAME"
    echo "  Image: $IMAGE"
    
    case $CONTAINER_TYPE in
        backend)
            echo "  SMTP Server: $SMTP_SERVER:$SMTP_PORT"
            echo "  Log Level: $LOG_LEVEL"
            ;;
        mongodb)
            echo "  Database: $MONGO_DATABASE"
            echo "  Data Path: ${DATA_PATH:-./data/mongodb}"
            ;;
        redis)
            echo "  Password Protected: $([ -n "$REDIS_PASSWORD" ] && echo "Yes" || echo "No")"
            ;;
    esac
}

# Show access URL
show_access_info() {
    if [ "$BUILD_ONLY" = "true" ]; then
        return 0
    fi

    echo ""
    success "Container started successfully!"
    
    case $CONTAINER_TYPE in
        frontend-http)
            echo "  Access: http://localhost:$PORT"
            ;;
        frontend-https)
            echo "  Access: https://localhost:$PORT (accept certificate warning)"
            echo "  HTTP Redirect: http://localhost:8080"
            ;;
        backend)
            echo "  API: http://localhost:$PORT/api/"
            echo "  Docs: http://localhost:$PORT/docs"
            ;;
        grafana)
            echo "  Dashboard: http://localhost:$PORT"
            echo "  Login: admin / ${GRAFANA_PASSWORD:-admin}"
            ;;
        prometheus)
            echo "  Metrics: http://localhost:$PORT"
            ;;
        mongo-express)
            echo "  Admin: http://localhost:$PORT"
            echo "  Login: admin / admin123"
            ;;
        *)
            echo "  Service: localhost:$PORT"
            ;;
    esac
}

# Main execution
main() {
    set_defaults
    show_container_info
    
    if [ "$BUILD_ONLY" = "false" ] && [ "$RUN_ONLY" = "false" ]; then
        echo -n "Continue with build and run? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log "Operation cancelled"
            exit 0
        fi
    fi
    
    create_network
    remove_existing
    build_container
    run_container
    show_access_info
}

main