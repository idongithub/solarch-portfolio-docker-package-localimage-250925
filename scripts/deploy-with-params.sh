#!/bin/bash
# Complete Production Deployment Script with ALL Parameters
# Covers every parameter for all 13+ containers in the full stack

set -e

# ===========================================  
# DEFAULT VALUES FOR ALL CONTAINERS
# ===========================================

# Frontend Ports
HTTP_PORT="${HTTP_PORT:-8080}"
KONG_PORT="${KONG_PORT:-8443}"
KONG_HOST=${KONG_HOST:-}
HTTPS_PORT="${HTTPS_PORT:-8443}"
HTTP_REDIRECT_PORT="${HTTP_REDIRECT_PORT:-8080}"

# Backend & API Ports  
BACKEND_PORT="${BACKEND_PORT:-8001}"

# Database Ports
MONGO_PORT="${MONGO_PORT:-27017}"
MONGO_EXPRESS_PORT="${MONGO_EXPRESS_PORT:-8081}"
REDIS_PORT="${REDIS_PORT:-6379}"

# Monitoring Ports
PROMETHEUS_PORT="${PROMETHEUS_PORT:-9090}"
GRAFANA_PORT="${GRAFANA_PORT:-3000}"
GRAFANA_PASSWORD="${GRAFANA_PASSWORD:-}"
LOKI_PORT="${LOKI_PORT:-3100}"
REDIS_PASSWORD="${REDIS_PASSWORD:-}"

# SMTP Configuration (All Parameters)
SMTP_SERVER="${SMTP_SERVER:-smtp.gmail.com}"
SMTP_PORT="${SMTP_PORT:-587}"
SMTP_USERNAME="${SMTP_USERNAME:-}"
SMTP_PASSWORD="${SMTP_PASSWORD:-}"
SMTP_USE_TLS="${SMTP_USE_TLS:-true}"
SMTP_USE_SSL="${SMTP_USE_SSL:-false}"
SMTP_STARTTLS="${SMTP_STARTTLS:-true}"
SMTP_TIMEOUT="${SMTP_TIMEOUT:-30}"
SMTP_RETRIES="${SMTP_RETRIES:-3}"
SMTP_DEBUG="${SMTP_DEBUG:-false}"
SMTP_VERIFY_CERT="${SMTP_VERIFY_CERT:-true}"
SMTP_LOCAL_HOSTNAME="${SMTP_LOCAL_HOSTNAME:-}"
SMTP_AUTH="${SMTP_AUTH:-true}"

# Email Settings
FROM_EMAIL="${FROM_EMAIL:-}"
TO_EMAIL="${TO_EMAIL:-}"
EMAIL_SUBJECT_PREFIX="${EMAIL_SUBJECT_PREFIX:-[Portfolio Contact]}"
EMAIL_RATE_LIMIT_WINDOW="${EMAIL_RATE_LIMIT_WINDOW:-3600}"
EMAIL_RATE_LIMIT_MAX="${EMAIL_RATE_LIMIT_MAX:-10}"
EMAIL_COOLDOWN_PERIOD="${EMAIL_COOLDOWN_PERIOD:-60}"
EMAIL_TEMPLATE="${EMAIL_TEMPLATE:-default}"
EMAIL_CHARSET="${EMAIL_CHARSET:-utf-8}"

# Database Configuration
MONGO_USERNAME="${MONGO_USERNAME:-admin}"
MONGO_PASSWORD="${MONGO_PASSWORD:-}"
MONGO_DATABASE="${MONGO_DATABASE:-portfolio}"
MONGO_DATA_PATH="${MONGO_DATA_PATH:-./data/mongodb}"
MONGO_CONFIG_PATH="${MONGO_CONFIG_PATH:-./data/mongodb-config}"

# Mongo Express Configuration
MONGO_EXPRESS_USERNAME="${MONGO_EXPRESS_USERNAME:-admin}"
MONGO_EXPRESS_PASSWORD="${MONGO_EXPRESS_PASSWORD:-admin123}"

# SSL/HTTPS Configuration
SSL_CERT_PATH="${SSL_CERT_PATH:-./ssl}"
DOMAIN="${DOMAIN:-}"  # Optional domain for architecturesolutions.co.uk subdomains

# API Security Configuration
API_KEY="${API_KEY:-}"
API_SECRET="${API_SECRET:-}"
ENABLE_API_AUTH="${ENABLE_API_AUTH:-false}"

# Application Security
SECRET_KEY="${SECRET_KEY:-kamal-singh-portfolio-production-2024}"
CORS_ORIGINS="${CORS_ORIGINS:-}"

# Backup Configuration
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"
BACKUP_DIR="${BACKUP_DIR:-./backups}"

# Environment Settings
ENVIRONMENT="${ENVIRONMENT:-production}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"
STRUCTURED_LOGGING="${STRUCTURED_LOGGING:-true}"

# Analytics (Optional)
REACT_APP_GA_MEASUREMENT_ID="${REACT_APP_GA_MEASUREMENT_ID:-}"

# Notification Settings (Optional)
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
WEBHOOK_URL="${WEBHOOK_URL:-}"

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
Complete Production Deployment Script - ALL Parameters Supported

Usage: $0 [OPTIONS]

FRONTEND CONFIGURATION:
    --http-port PORT             HTTP frontend port (default: 8080)
    --https-port PORT            HTTPS frontend port (default: 8443)
    --http-redirect-port PORT    HTTP redirect port (default: 8080)
    --ssl-cert-path PATH         SSL certificate directory (default: ./ssl)
    --domain SUBDOMAIN           Subdomain for architecturesolutions.co.uk (e.g., portfolio)
                                 Multiple subdomains: portfolio,monitoring (comma-separated)

API Security & CAPTCHA Configuration:
    --enable-api-auth            Enable API key/secret authentication for domain access
    --recaptcha-site-key KEY     Google reCAPTCHA v3 site key for frontend
    --recaptcha-secret-key KEY   Google reCAPTCHA v3 secret key for backend verification
    --kong-host IP               Kong API Gateway host/IP address (default: auto-detected Ubuntu IP)
    --kong-port PORT             Kong API Gateway HTTPS port (default: 8443)
    --api-key KEY                Custom API key (auto-generated if not provided)
    --api-secret SECRET          Custom API secret (auto-generated if not provided)

BACKEND CONFIGURATION:
    --backend-port PORT          Backend API port (default: 8001)
    --secret-key KEY             Application secret key
    --cors-origins ORIGINS       CORS allowed origins (comma-separated)
    --log-level LEVEL            Logging level (DEBUG,INFO,WARNING,ERROR)
    --environment ENV            Environment name (default: production)

COMPLETE SMTP CONFIGURATION:
    --smtp-server HOST           SMTP server hostname (default: smtp.gmail.com)
    --smtp-port PORT             SMTP port (default: 587)
    --smtp-username EMAIL        SMTP username/email
    --smtp-password PASS         SMTP password/app password
    --smtp-use-tls BOOL          Use TLS encryption (default: true)
    --smtp-use-ssl BOOL          Use SSL encryption (default: false)
    --smtp-starttls BOOL         Use STARTTLS (default: true)
    --smtp-timeout SEC           Connection timeout (default: 30)
    --smtp-retries NUM           Retry attempts (default: 3)
    --smtp-debug BOOL            Enable SMTP debugging (default: false)
    --smtp-verify-cert BOOL      Verify SSL certificates (default: true)
    --smtp-local-hostname HOST   Local hostname for SMTP
    --from-email EMAIL           From email address
    --to-email EMAIL             To email address
    --email-subject-prefix STR   Email subject prefix (default: [Portfolio Contact])
    --email-rate-limit-window SEC   Rate limit window (default: 3600)
    --email-rate-limit-max NUM   Max emails per window (default: 10)
    --email-cooldown SEC         Cooldown between emails (default: 60)

DATABASE CONFIGURATION:
    --mongo-port PORT            MongoDB port (default: 27017)
    --mongo-username USER        MongoDB admin username (default: admin)
    --mongo-password PASS        MongoDB admin password
    --mongo-database DB          Database name (default: portfolio)
    --mongo-data-path PATH       Data persistence path (default: ./data/mongodb)
    --mongo-config-path PATH     Config persistence path (default: ./data/mongodb-config)
    --mongo-express-port PORT    Mongo Express port (default: 8081)
    --mongo-express-username USER Mongo Express username (default: admin)
    --mongo-express-password PASS Mongo Express password (default: admin123)
    --redis-port PORT            Redis port (default: 6379)
    --redis-password PASS        Redis password

MONITORING CONFIGURATION:
    --prometheus-port PORT       Prometheus port (default: 9090)
    --grafana-port PORT          Grafana port (default: 3000)
    --grafana-password PASS      Grafana admin password
    --loki-port PORT             Loki port (default: 3100)

BACKUP & ANALYTICS:
    --backup-retention-days NUM  Backup retention (default: 30)
    --backup-dir PATH            Backup directory (default: ./backups)
    --ga-measurement-id ID       Google Analytics 4 ID (G-XXXXXXXXXX)

NOTIFICATIONS:
    --slack-webhook-url URL      Slack webhook for notifications
    --webhook-url URL            Generic webhook URL

DEPLOYMENT OPTIONS:
    -h, --help                   Show this help message
    -f, --env-file FILE          Use environment file for configuration
    --dry-run                    Show configuration and test all Docker builds
    --build-test                 Test Docker builds only (no configuration display)
    --force                      Skip confirmation prompts
    --force-rebuild              Force rebuild all images (ignores cache)
    --skip-backup                Skip backup service deployment

EXAMPLES:

    # Complete custom deployment with all major parameters
    $0 --http-port 3000 --https-port 3443 --backend-port 3001 \\
       --grafana-port 3030 --prometheus-port 9091 \\
       --smtp-server smtp.gmail.com --smtp-port 587 \\
       --smtp-username myemail@gmail.com --smtp-password myapppass \\
       --from-email myemail@gmail.com --to-email recipient@company.com \\
       --mongo-password securepass123 --grafana-password adminpass123 \\
       --redis-password redispass123

    # Deploy with custom SMTP configuration (Outlook)
    $0 --smtp-server smtp-mail.outlook.com --smtp-port 587 \\
       --smtp-username me@outlook.com --smtp-password mypass \\
       --smtp-use-tls true --smtp-starttls true

    # Deploy with multiple domains
    $0 --domain portfolio,monitoring --mongo-password securepass123 --grafana-password admin123

    # Deploy with API security (auto-generated keys)
    $0 --domain portfolio --enable-api-auth --mongo-password securepass123 --grafana-password admin123

    # Deploy with custom API credentials
    $0 --domain portfolio --api-key "custom-api-key-here" --api-secret "custom-api-secret-here" \\
      --mongo-password securepass123 --grafana-password admin123

    # Deploy with environment file and custom ports
    $0 --env-file .env.production --http-port 3000 --backend-port 3001

    # Deploy with domain and all your parameters
    $0 --domain portfolio --http-port 3400 --https-port 3443 --backend-port 3001 \\
      --smtp-server smtp.ionos.co.uk --smtp-port 465 \\
      --smtp-username kamal.singh@architecturesolutions.co.uk \\
      --smtp-password NewPass6 --smtp-use-ssl true \\
      --from-email kamal.singh@architecturesolutions.co.uk \\
      --to-email kamal.singh@architecturesolutions.co.uk \\
      --ga-measurement-id G-B2W705K4SN \\
      --mongo-express-port 3081 --mongo-express-username admin \\
      --mongo-express-password admin123 --mongo-port 37037 \\
      --mongo-username admin --mongo-password securepass123 \\
      --grafana-password adminpass123 --redis-password redispass123 \\
      --grafana-port 3030 --loki-port 3300 --prometheus-port 3091

    # Dry run to see configuration
    $0 --dry-run --http-port 3000 --smtp-username test@gmail.com

EOF
}

# Parse ALL command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -f|--env-file)
            ENV_FILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --build-test)
            BUILD_TEST=true
            shift
            ;;
        --force)
            FORCE_DEPLOY=true
            shift
            ;;
        --force-rebuild)
            FORCE_REBUILD=true
            shift
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;

        # Frontend Configuration
        --http-port)
            HTTP_PORT="$2"
            shift 2
            ;;
        --https-port)
            HTTPS_PORT="$2"
            shift 2
            ;;
        --http-redirect-port)
            HTTP_REDIRECT_PORT="$2"
            shift 2
            ;;
        --ssl-cert-path)
            SSL_CERT_PATH="$2"
            shift 2
            ;;
        --domain)
            if [[ "$2" == *","* ]]; then
                # Multiple subdomains comma-separated
                IFS=',' read -ra SUBDOMAINS <<< "$2"
                PRIMARY_SUBDOMAIN="${SUBDOMAINS[0]}"
                DOMAIN="$PRIMARY_SUBDOMAIN.architecturesolutions.co.uk"
                ALL_DOMAINS=""
                for subdomain in "${SUBDOMAINS[@]}"; do
                    if [[ -n "$ALL_DOMAINS" ]]; then
                        ALL_DOMAINS="$ALL_DOMAINS,$subdomain.architecturesolutions.co.uk"
                    else
                        ALL_DOMAINS="$subdomain.architecturesolutions.co.uk"
                    fi
                done
            else
                # Single subdomain
                DOMAIN="$2.architecturesolutions.co.uk"
                ALL_DOMAINS="$DOMAIN"
            fi
            shift 2
            ;;
        --enable-api-auth)
            ENABLE_API_AUTH="true"
            shift
            ;;
        --api-key)
            API_KEY="$2"
            ENABLE_API_AUTH="true"
            shift 2
            ;;
        --api-secret)
            API_SECRET="$2"
            shift 2
            ;;
        --recaptcha-site-key)
            RECAPTCHA_SITE_KEY="$2"
            shift 2
            ;;
        --recaptcha-secret-key)
            RECAPTCHA_SECRET_KEY="$2"
            shift 2
            ;;
        --kong-port)
            KONG_PORT="$2"
            shift 2
            ;;
        --kong-host)
            KONG_HOST="$2"
            shift 2
            ;;

        # Backend Configuration
        --backend-port)
            BACKEND_PORT="$2"
            shift 2
            ;;
        --secret-key)
            SECRET_KEY="$2"
            shift 2
            ;;
        --cors-origins)
            CORS_ORIGINS="$2"
            shift 2
            ;;
        --log-level)
            LOG_LEVEL="$2"
            shift 2
            ;;
        --environment)
            ENVIRONMENT="$2"
            shift 2
            ;;

        # Complete SMTP Configuration
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
        --smtp-starttls)
            SMTP_STARTTLS="$2"
            shift 2
            ;;
        --smtp-timeout)
            SMTP_TIMEOUT="$2"
            shift 2
            ;;
        --smtp-retries)
            SMTP_RETRIES="$2"
            shift 2
            ;;
        --smtp-debug)
            SMTP_DEBUG="$2"
            shift 2
            ;;
        --smtp-verify-cert)
            SMTP_VERIFY_CERT="$2"
            shift 2
            ;;
        --smtp-local-hostname)
            SMTP_LOCAL_HOSTNAME="$2"
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
        --email-subject-prefix)
            EMAIL_SUBJECT_PREFIX="$2"
            shift 2
            ;;
        --email-rate-limit-window)
            EMAIL_RATE_LIMIT_WINDOW="$2"
            shift 2
            ;;
        --email-rate-limit-max)
            EMAIL_RATE_LIMIT_MAX="$2"
            shift 2
            ;;
        --email-cooldown)
            EMAIL_COOLDOWN_PERIOD="$2"
            shift 2
            ;;

        # Database Configuration
        --mongo-port)
            MONGO_PORT="$2"
            shift 2
            ;;
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
        --mongo-data-path)
            MONGO_DATA_PATH="$2"
            shift 2
            ;;
        --mongo-config-path)
            MONGO_CONFIG_PATH="$2"
            shift 2
            ;;
        --mongo-express-port)
            MONGO_EXPRESS_PORT="$2"
            shift 2
            ;;
        --mongo-express-username)
            MONGO_EXPRESS_USERNAME="$2"
            shift 2
            ;;
        --mongo-express-password)
            MONGO_EXPRESS_PASSWORD="$2"
            shift 2
            ;;
        --redis-port)
            REDIS_PORT="$2"
            shift 2
            ;;
        --redis-password)
            REDIS_PASSWORD="$2"
            shift 2
            ;;

        # Monitoring Configuration
        --prometheus-port)
            PROMETHEUS_PORT="$2"
            shift 2
            ;;
        --grafana-port)
            GRAFANA_PORT="$2"
            shift 2
            ;;
        --grafana-password)
            GRAFANA_PASSWORD="$2"
            shift 2
            ;;
        --loki-port)
            LOKI_PORT="$2"
            shift 2
            ;;

        # Backup & Analytics
        --backup-retention-days)
            BACKUP_RETENTION_DAYS="$2"
            shift 2
            ;;
        --backup-dir)
            BACKUP_DIR="$2"
            shift 2
            ;;
        --ga-measurement-id)
            REACT_APP_GA_MEASUREMENT_ID="$2"
            shift 2
            ;;
        --domain)
            DOMAIN="$2"
            shift 2
            ;;

        # Notifications
        --slack-webhook-url)
            SLACK_WEBHOOK_URL="$2"
            shift 2
            ;;
        --webhook-url)
            WEBHOOK_URL="$2"
            shift 2
            ;;

        -*)
            error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            error "Unexpected argument: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Load environment file if specified
if [ -n "$ENV_FILE" ]; then
    if [ -f "$ENV_FILE" ]; then
        log "Loading environment from $ENV_FILE"
        set -a
        source "$ENV_FILE"
        set +a
    else
        error "Environment file not found: $ENV_FILE"
        exit 1
    fi
fi

# Build CORS_ORIGINS if not already set
if [ -z "$CORS_ORIGINS" ]; then
    # Multiple methods to detect the actual host IP (most reliable first)
    HOST_IP=""
    
    # Method 1: Use ip route (most reliable for external connectivity)
    if [ -z "$HOST_IP" ]; then
        HOST_IP=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' 2>/dev/null || echo "")
    fi
    
    # Method 2: Use hostname -I (fallback)
    if [ -z "$HOST_IP" ]; then
        HOST_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "")
    fi
    
    # Method 3: Use ip addr (last resort)
    if [ -z "$HOST_IP" ]; then
        HOST_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | cut -d/ -f1 || echo "localhost")
    fi
    
    # Build comprehensive CORS origins with dynamically detected IP and deployment-provided ports
    CORS_ORIGINS="http://localhost:$HTTP_PORT,https://localhost:$HTTPS_PORT,http://127.0.0.1:$HTTP_PORT,https://127.0.0.1:$HTTPS_PORT"
    
    # Add network IP if detected (avoid adding localhost twice)
    if [ -n "$HOST_IP" ] && [ "$HOST_IP" != "localhost" ] && [ "$HOST_IP" != "127.0.0.1" ]; then
        CORS_ORIGINS="$CORS_ORIGINS,http://$HOST_IP:$HTTP_PORT,https://$HOST_IP:$HTTPS_PORT"
        log "🔧 Auto-detected network IP: $HOST_IP"
    else
        log "⚠️  Could not detect network IP, using localhost only"
    fi
    
    log "🔧 Using deployment ports: HTTP=$HTTP_PORT, HTTPS=$HTTPS_PORT, Backend=$BACKEND_PORT"
    log "🔧 CORS origins configured: $CORS_ORIGINS"
fi

# Export ALL variables for docker-compose
export HTTP_PORT HTTPS_PORT HTTP_REDIRECT_PORT BACKEND_PORT
export MONGO_PORT MONGO_EXPRESS_PORT REDIS_PORT
export PROMETHEUS_PORT GRAFANA_PORT LOKI_PORT
export SMTP_SERVER SMTP_PORT SMTP_USERNAME SMTP_PASSWORD SMTP_USE_TLS SMTP_USE_SSL
export SMTP_STARTTLS SMTP_TIMEOUT SMTP_RETRIES SMTP_DEBUG SMTP_VERIFY_CERT SMTP_LOCAL_HOSTNAME SMTP_AUTH
export FROM_EMAIL TO_EMAIL EMAIL_SUBJECT_PREFIX EMAIL_RATE_LIMIT_WINDOW EMAIL_RATE_LIMIT_MAX EMAIL_COOLDOWN_PERIOD
export MONGO_USERNAME MONGO_PASSWORD MONGO_DATABASE MONGO_DATA_PATH MONGO_CONFIG_PATH
export MONGO_EXPRESS_USERNAME MONGO_EXPRESS_PASSWORD
export REDIS_PASSWORD GRAFANA_PASSWORD
export SSL_CERT_PATH SECRET_KEY CORS_ORIGINS
export BACKUP_RETENTION_DAYS BACKUP_DIR
export ENVIRONMENT LOG_LEVEL STRUCTURED_LOGGING
export REACT_APP_GA_MEASUREMENT_ID SLACK_WEBHOOK_URL WEBHOOK_URL
export RECAPTCHA_SITE_KEY RECAPTCHA_SECRET_KEY
export REACT_APP_BACKEND_URL REACT_APP_KONG_HOST REACT_APP_KONG_PORT
export REACT_APP_BACKEND_URL_HTTP REACT_APP_RECAPTCHA_SITE_KEY

# Show complete deployment summary
show_deployment_summary() {
    log "Complete Deployment Configuration:"
    echo ""
    echo "🌐 Frontend Configuration:"
    echo "  HTTP Port:     $HTTP_PORT"
    echo "  HTTPS Port:    $HTTPS_PORT"
    echo "  SSL Cert Path: $SSL_CERT_PATH"
    echo ""
    echo "🔧 Backend Configuration:"
    echo "  API Port:      $BACKEND_PORT"
    echo "  Environment:   $ENVIRONMENT"
    echo "  Log Level:     $LOG_LEVEL"
    echo "  CORS Origins:  $CORS_ORIGINS"
    echo ""
    echo "📧 Complete SMTP Configuration:"
    echo "  Server:        $SMTP_SERVER:$SMTP_PORT"
    echo "  Use TLS:       $SMTP_USE_TLS"
    echo "  Use SSL:       $SMTP_USE_SSL"
    echo "  STARTTLS:      $SMTP_STARTTLS"
    echo "  Timeout:       $SMTP_TIMEOUT seconds"
    echo "  Retries:       $SMTP_RETRIES"
    echo "  Debug:         $SMTP_DEBUG" 
    echo "  From Email:    ${FROM_EMAIL:-Not configured}"
    echo "  To Email:      $TO_EMAIL"
    echo "  Rate Limit:    $EMAIL_RATE_LIMIT_MAX emails per $EMAIL_RATE_LIMIT_WINDOW seconds"
    echo ""
    echo "💾 Database Configuration:"
    echo "  MongoDB Port:  $MONGO_PORT"
    echo "  Database:      $MONGO_DATABASE"
    echo "  Data Path:     $MONGO_DATA_PATH"
    echo "  Admin GUI:     http://localhost:$MONGO_EXPRESS_PORT ($MONGO_EXPRESS_USERNAME/***)"
    echo "  Redis Port:    $REDIS_PORT"
    echo ""
    echo "📊 Monitoring Stack:"
    echo "  Prometheus:    http://localhost:$PROMETHEUS_PORT"
    echo "  Grafana:       http://localhost:$GRAFANA_PORT (admin/***)"
    echo "  Loki:          http://localhost:$LOKI_PORT"
    echo ""
    echo "📈 Analytics & Backup:"
    echo "  GA4 ID:        ${REACT_APP_GA_MEASUREMENT_ID:-Not configured}"
    echo "  Backup Dir:    $BACKUP_DIR"
    echo "  Retention:     $BACKUP_RETENTION_DAYS days"
    echo ""
    echo "🔔 Notifications:"
    echo "  Slack Webhook: ${SLACK_WEBHOOK_URL:-Not configured}"
}

# Validation and deployment logic
validate_required_params() {
    local missing=()
    
    [ -z "$MONGO_PASSWORD" ] && missing+=("--mongo-password")
    [ -z "$GRAFANA_PASSWORD" ] && missing+=("--grafana-password")
    
    if [ -z "$SMTP_USERNAME" ] || [ -z "$SMTP_PASSWORD" ]; then
        log "⚠️  SMTP not fully configured - email functionality will be limited"
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        error "Missing required parameters: ${missing[*]}"
        exit 1
    fi
}

# Main deployment function
deploy_stack() {
    log "Starting complete enterprise production deployment..."
    
    validate_required_params
    show_deployment_summary
    
    if [ "$DRY_RUN" = "true" ]; then
        log "🧪 ROBUST DRY RUN - Testing actual Docker builds..."
        echo ""
        
        # Test docker-compose file validation
        log "Step 1/5: Validating docker-compose.production.yml..."
        if ! docker-compose -f docker-compose.production.yml config --quiet; then
            error "❌ Docker Compose file validation failed"
            exit 1
        fi
        success "✅ Docker Compose file is valid"
        
        # Test Docker build process for each service
        log "Step 2/5: Testing frontend HTTP build..."
        if ! docker build -f Dockerfile.npm.optimized -t test-frontend-http . --no-cache; then
            error "❌ Frontend HTTP build failed"
            exit 1
        fi
        success "✅ Frontend HTTP builds successfully"
        
        log "Step 3/5: Testing frontend HTTPS build..."
        if ! docker build -f Dockerfile.https.optimized -t test-frontend-https . --no-cache; then
            error "❌ Frontend HTTPS build failed"
            exit 1
        fi
        success "✅ Frontend HTTPS builds successfully"
        
        log "Step 4/5: Testing backend build..."
        if ! docker build -f Dockerfile.backend.optimized -t test-backend . --no-cache; then
            error "❌ Backend build failed"
            exit 1
        fi
        success "✅ Backend builds successfully"
        
        log "Step 5/5: Cleaning up test images..."
        docker rmi test-frontend-http test-frontend-https test-backend 2>/dev/null || true
        
        echo ""
        success "🎉 ROBUST DRY RUN COMPLETED - All builds successful!"
        echo ""
        echo "🚀 Your deployment is ready to proceed:"
        echo "   Run the same command without --dry-run to deploy"
        echo ""
        exit 0
    fi
    
    if [ "$FORCE_DEPLOY" != "true" ]; then
        echo ""
        echo -n "Continue with deployment? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log "Deployment cancelled"
            exit 0
        fi
    fi
    
    mkdir -p "$MONGO_DATA_PATH" "$SSL_CERT_PATH" ./logs "$BACKUP_DIR" ./monitoring/grafana/provisioning
    
    
    # Create data directories for host volume mounting
    log "📁 Creating data directories for persistent storage..."
    mkdir -p ./data/mongodb ./data/mongodb-config ./data/redis ./data/prometheus ./data/grafana ./data/loki
    mkdir -p ./data/grafana/plugins ./data/grafana/dashboards ./data/grafana/provisioning
    mkdir -p ./data/loki/rules ./data/loki/chunks ./data/loki/wal
    mkdir -p ./monitoring/grafana/provisioning/datasources ./monitoring/grafana/provisioning/dashboards ./monitoring/grafana/dashboards
    
    # Set proper permissions for data directories
    log "🔧 Setting proper permissions for monitoring stack..."
    chmod 755 ./data/mongodb ./data/redis
    chmod 777 ./backups  # Backup directory needs write access
    
    # Set specific permissions for monitoring containers
    chmod -R 777 ./data/grafana ./data/prometheus ./data/loki  # Permissive for container users
    chmod -R 755 ./monitoring/grafana/  # Grafana configuration files
    
    # Generate Prometheus config with correct backend port
    log "📊 Generating Prometheus configuration with backend port $BACKEND_PORT..."
    envsubst < ./monitoring/prometheus.yml.template > ./monitoring/prometheus.yml
    
    # Generate dynamic frontend .env with correct backend URL
    if [[ -n "$DOMAIN" ]]; then
        log "🌐 Generating frontend .env with domain: https://$DOMAIN (SSL terminated at Traefik)..."
        # Get IP for Kong configuration (needed even for domain deployments)
        HOST_IP=$(hostname -I | awk '{print $1}')
        KONG_HOST_IP=${KONG_HOST:-$HOST_IP}
        
        cat > ./frontend/.env << EOF
REACT_APP_BACKEND_URL=https://$DOMAIN

# Kong configuration for HTTPS IP access (when not using domain)
REACT_APP_KONG_HOST=$KONG_HOST_IP
REACT_APP_KONG_PORT=$KONG_PORT
REACT_APP_BACKEND_URL_HTTP=http://$HOST_IP:$BACKEND_PORT

# reCAPTCHA configuration
REACT_APP_RECAPTCHA_SITE_KEY=${RECAPTCHA_SITE_KEY:-}

# WebSocket configuration
WDS_SOCKET_PORT=443
EOF

        # Export variables for docker-compose build args
        export REACT_APP_BACKEND_URL="https://$DOMAIN"
        export REACT_APP_KONG_HOST="$KONG_HOST_IP"
        export REACT_APP_KONG_PORT="$KONG_PORT"
        export REACT_APP_BACKEND_URL_HTTP="http://$HOST_IP:$BACKEND_PORT"
        export REACT_APP_RECAPTCHA_SITE_KEY="${RECAPTCHA_SITE_KEY:-}"
        success "Frontend .env generated with domain URL: https://$DOMAIN"
        log "   - Domain access: https://$DOMAIN"
        log "   - IP HTTP access: http://$HOST_IP:$BACKEND_PORT"
        log "   - IP HTTPS access: https://$KONG_HOST_IP:$KONG_PORT (via Kong)"
        if [[ -n "$RECAPTCHA_SITE_KEY" ]]; then
            log "   - reCAPTCHA enabled with site key"
        fi
        
        # Update backend CORS to include domain and network IP
        log "🔧 Updating backend CORS for domain access..."
        # Robust IP detection for comprehensive CORS coverage
        DETECTED_HOST_IP=""
        
        # Try multiple methods to get the host IP (same logic as above)
        if [ -z "$DETECTED_HOST_IP" ]; then
            DETECTED_HOST_IP=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' 2>/dev/null || echo "")
        fi
        if [ -z "$DETECTED_HOST_IP" ]; then
            DETECTED_HOST_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "")
        fi
        if [ -z "$DETECTED_HOST_IP" ]; then
            DETECTED_HOST_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | cut -d/ -f1 || echo "")
        fi
        
        # Build domain CORS origins with dynamic IP and deployment ports
        DOMAIN_CORS_ORIGINS="https://$DOMAIN,http://localhost:$HTTP_PORT,https://localhost:$HTTPS_PORT,http://127.0.0.1:$HTTP_PORT,https://127.0.0.1:$HTTPS_PORT"
        
        # Add detected IP if valid
        if [ -n "$DETECTED_HOST_IP" ] && [ "$DETECTED_HOST_IP" != "localhost" ] && [ "$DETECTED_HOST_IP" != "127.0.0.1" ]; then
            DOMAIN_CORS_ORIGINS="$DOMAIN_CORS_ORIGINS,http://$DETECTED_HOST_IP:$HTTP_PORT,https://$DETECTED_HOST_IP:$HTTPS_PORT"
            log "🔧 Network IP detected for CORS: $DETECTED_HOST_IP"
        fi
        
        # Ensure backend .env file exists
        touch ./backend/.env
        
        if grep -q "CORS_ORIGINS=" ./backend/.env; then
            sed -i "s|CORS_ORIGINS=.*|CORS_ORIGINS=$DOMAIN_CORS_ORIGINS|g" ./backend/.env
        else
            echo "CORS_ORIGINS=$DOMAIN_CORS_ORIGINS" >> ./backend/.env
        fi
        
        log "🔧 Domain CORS configured with ports HTTP=$HTTP_PORT, HTTPS=$HTTPS_PORT"
        success "Backend CORS configuration updated with domain and all access points"
        
        # Mark that Docker containers need recreation due to CORS environment variable changes
        export FORCE_RECREATE_CONTAINERS="true"
        
        # Update backend SMTP configuration with provided parameters
        log "🔧 Updating backend SMTP configuration..."
        sed -i "s|SMTP_SERVER=.*|SMTP_SERVER=$SMTP_SERVER|g" ./backend/.env
        sed -i "s|SMTP_PORT=.*|SMTP_PORT=$SMTP_PORT|g" ./backend/.env
        sed -i "s|SMTP_USERNAME=.*|SMTP_USERNAME=$SMTP_USERNAME|g" ./backend/.env
        sed -i "s|SMTP_PASSWORD=.*|SMTP_PASSWORD=$SMTP_PASSWORD|g" ./backend/.env
        sed -i "s|SMTP_USE_TLS=.*|SMTP_USE_TLS=$SMTP_USE_TLS|g" ./backend/.env
        sed -i "s|SMTP_USE_SSL=.*|SMTP_USE_SSL=$SMTP_USE_SSL|g" ./backend/.env
        sed -i "s|FROM_EMAIL=.*|FROM_EMAIL=$FROM_EMAIL|g" ./backend/.env
        sed -i "s|TO_EMAIL=.*|TO_EMAIL=$TO_EMAIL|g" ./backend/.env
        success "Backend SMTP configuration updated with deployment parameters"
        
        # Mark that Docker containers need recreation due to environment variable changes
        export FORCE_RECREATE_CONTAINERS="true"
        log "🔄 Environment variables updated - Docker containers will be recreated to apply changes"
        
        # Configure API Security if enabled
        if [[ "$ENABLE_API_AUTH" == "true" ]]; then
            log "🔐 Configuring API security..."
            
            # Generate API credentials if not provided
            if [[ -z "$API_KEY" ]]; then
                API_KEY=$(openssl rand -hex 32)
                log "🔐 Generated API Key: ${API_KEY:0:8}..." # Show first 8 chars for confirmation
            fi
            
            if [[ -z "$API_SECRET" ]]; then
                API_SECRET=$(openssl rand -hex 32)  
                log "🔐 Generated API Secret: ${API_SECRET:0:8}..." # Show first 8 chars for confirmation
            fi
            
            # Store in backend environment
            echo "API_KEY=$API_KEY" >> ./backend/.env
            echo "API_SECRET=$API_SECRET" >> ./backend/.env
            echo "API_AUTH_ENABLED=true" >> ./backend/.env
            
            success "API security configured for domain access only"
            
            # Mark that Docker containers need recreation for API security changes
            export FORCE_RECREATE_CONTAINERS="true"
            log "🔄 API security configuration changed - Docker containers will be recreated"
        else
            echo "API_AUTH_ENABLED=false" >> ./backend/.env
            log "🔓 API authentication disabled (development mode)"
            
            # Mark that Docker containers need recreation for API security changes
            export FORCE_RECREATE_CONTAINERS="true"
            log "🔄 API security configuration changed - Docker containers will be recreated"
        fi
        
        # Frontend nginx configuration (no proxy setup needed - using Kong for HTTPS)
        log "🔧 Frontend nginx configured for Kong API Gateway integration"
        
        # Generate Traefik configuration for all domains
        if [[ -n "$ALL_DOMAINS" && "$ALL_DOMAINS" != "$DOMAIN" ]]; then
            log "🔧 Generating Traefik config for multiple domains: $ALL_DOMAINS..."
            cat > ./traefik/multi-domain-routes.toml << EOF
# Additional domain routes for: $ALL_DOMAINS
# Copy these sections to your Traefik dynamic.toml

EOF
            IFS=',' read -ra DOMAIN_ARRAY <<< "$ALL_DOMAINS"
            for domain in "${DOMAIN_ARRAY[@]}"; do
                if [[ "$domain" == *"monitoring"* ]]; then
                    cat >> ./traefik/multi-domain-routes.toml << EOF
[http.routers.${domain//\./-}-grafana]
  rule = "Host(\`$domain\`)"
  service = "${domain//\./-}-grafana-service"
  [http.routers.${domain//\./-}-grafana.tls]

[http.services.${domain//\./-}-grafana-service.loadBalancer]
  [[http.services.${domain//\./-}-grafana-service.loadBalancer.servers]]
    url = "http://$HOST_IP:$GRAFANA_PORT"

EOF
                elif [[ "$domain" != "$DOMAIN" ]]; then
                    cat >> ./traefik/multi-domain-routes.toml << EOF
[http.routers.${domain//\./-}-frontend]
  rule = "Host(\`$domain\`)"
  service = "${domain//\./-}-frontend-service"
  [http.routers.${domain//\./-}-frontend.tls]

[http.routers.${domain//\./-}-api]
  rule = "Host(\`$domain\`) && PathPrefix(\`/api\`)"
  service = "${domain//\./-}-backend-service"
  [http.routers.${domain//\./-}-api.tls]

[http.services.${domain//\./-}-frontend-service.loadBalancer]
  [[http.services.${domain//\./-}-frontend-service.loadBalancer.servers]]
    url = "http://$HOST_IP:$HTTP_PORT"

[http.services.${domain//\./-}-backend-service.loadBalancer]
  [[http.services.${domain//\./-}-backend-service.loadBalancer.servers]]
    url = "http://$HOST_IP:$BACKEND_PORT"

EOF
                fi
            done
            success "Multi-domain Traefik config generated: ./traefik/multi-domain-routes.toml"
        fi
        
        # Generate Traefik API authentication configuration
        if [[ "$ENABLE_API_AUTH" == "true" ]]; then
            log "🔐 Generating Traefik API authentication middleware..."
            cat > ./traefik/api-auth-middleware.toml << EOF
# API Authentication Middleware for Traefik
# Copy this configuration to your Traefik dynamic.toml

# API Authentication Middleware - Injects API credentials
[http.middlewares.api-auth.headers.customRequestHeaders]
  X-API-Key = "$API_KEY"
  X-API-Secret = "$API_SECRET"

# Updated API Router with Authentication (replace existing portfolio-api router)
[http.routers.portfolio-api-secure]
  rule = "Host(\`$DOMAIN\`) && PathPrefix(\`/api\`)"
  service = "portfolio-backend"
  priority = 200
  [http.routers.portfolio-api-secure.tls]
  middlewares = ["api-auth", "cors-headers"]

# Note: This secures API access via domain only.
# Direct IP access (http://192.168.86.75:3400) bypasses Traefik and remains unrestricted for development.
EOF
            success "Traefik API auth config generated: ./traefik/api-auth-middleware.toml"
            
            # Create a credentials reference file
            cat > ./traefik/API_CREDENTIALS.txt << EOF
# API Security Credentials for Traefik Configuration
# Generated: $(date)
# Domain: $DOMAIN

API_KEY=$API_KEY
API_SECRET=$API_SECRET

COPY TO YOUR TRAEFIK dynamic.toml:
=====================================

[http.middlewares.api-auth.headers.customRequestHeaders]
  X-API-Key = "$API_KEY"
  X-API-Secret = "$API_SECRET"

[http.routers.portfolio-api-secure]
  rule = "Host(\`$DOMAIN\`) && PathPrefix(\`/api\`)"
  service = "portfolio-backend"
  priority = 200
  [http.routers.portfolio-api-secure.tls]
  middlewares = ["api-auth", "cors-headers"]

IMPORTANT NOTES:
================
- This secures ONLY domain access: https://$DOMAIN
- IP access remains unrestricted: http://$(hostname -I | awk '{print $1}'):$HTTP_PORT
- Frontend code requires NO changes
- Traefik automatically injects API credentials for domain requests
EOF
            
            log "🔐 API Security Summary:"
            log "   - Domain access: SECURED (requires API key/secret via Traefik)"
            log "   - IP access: UNRESTRICTED (development/testing)"
            log "   - API Key: ${API_KEY:0:12}..."
            log "   - Configuration: ./traefik/api-auth-middleware.toml"
            log "   - Credentials file: ./traefik/API_CREDENTIALS.txt"
        fi
    else
        log "🌐 Generating frontend .env for IP access (Kong-compatible)..."
        HOST_IP=$(hostname -I | awk '{print $1}')
        
        # Use custom Kong host if provided, otherwise use detected Ubuntu IP
        KONG_HOST_IP=${KONG_HOST:-$HOST_IP}
        
        # For IP access, HTTP calls backend directly, HTTPS calls via Kong
        cat > ./frontend/.env << EOF
# Backend URL for HTTP frontend (direct connection)
REACT_APP_BACKEND_URL_HTTP=http://$HOST_IP:$BACKEND_PORT

# Kong configuration for HTTPS frontend (mixed content avoidance)
REACT_APP_KONG_HOST=$KONG_HOST_IP
REACT_APP_KONG_PORT=$KONG_PORT

# reCAPTCHA configuration
REACT_APP_RECAPTCHA_SITE_KEY=${RECAPTCHA_SITE_KEY:-}

# WebSocket configuration
WDS_SOCKET_PORT=443
EOF
        
        # Export variables for docker-compose build args
        export REACT_APP_BACKEND_URL_HTTP="http://$HOST_IP:$BACKEND_PORT"
        export REACT_APP_KONG_HOST="$KONG_HOST_IP"
        export REACT_APP_KONG_PORT="$KONG_PORT"
        export REACT_APP_RECAPTCHA_SITE_KEY="${RECAPTCHA_SITE_KEY:-}"
        
        success "Frontend .env generated for Kong API Gateway integration"
        log "   - HTTP frontend: Direct backend calls to http://$HOST_IP:$BACKEND_PORT"
        log "   - HTTPS frontend: Kong proxy calls to https://$KONG_HOST_IP:$KONG_PORT"
        if [[ "$KONG_HOST_IP" != "$HOST_IP" ]]; then
            log "   - Kong configured: Custom host=$KONG_HOST_IP, Port=$KONG_PORT"
        else
            log "   - Kong configured: Auto-detected host=$KONG_HOST_IP, Port=$KONG_PORT"
        fi
        if [[ -n "$RECAPTCHA_SITE_KEY" ]]; then
            log "   - reCAPTCHA enabled: Site key configured"
        else
            log "   - reCAPTCHA disabled: No site key provided"
        fi
        
        # Mark that frontend containers need rebuilding due to environment variable changes
        export FORCE_REBUILD="true"
        log "🔄 Frontend containers will be rebuilt for Kong integration"
        
        # Update backend SMTP configuration with provided parameters
        log "🔧 Updating backend SMTP configuration..."
        sed -i "s|SMTP_SERVER=.*|SMTP_SERVER=$SMTP_SERVER|g" ./backend/.env
        sed -i "s|SMTP_PORT=.*|SMTP_PORT=$SMTP_PORT|g" ./backend/.env
        sed -i "s|SMTP_USERNAME=.*|SMTP_USERNAME=$SMTP_USERNAME|g" ./backend/.env
        sed -i "s|SMTP_PASSWORD=.*|SMTP_PASSWORD=$SMTP_PASSWORD|g" ./backend/.env
        sed -i "s|SMTP_USE_TLS=.*|SMTP_USE_TLS=$SMTP_USE_TLS|g" ./backend/.env
        sed -i "s|SMTP_USE_SSL=.*|SMTP_USE_SSL=$SMTP_USE_SSL|g" ./backend/.env
        sed -i "s|FROM_EMAIL=.*|FROM_EMAIL=$FROM_EMAIL|g" ./backend/.env
        sed -i "s|TO_EMAIL=.*|TO_EMAIL=$TO_EMAIL|g" ./backend/.env
        success "Backend SMTP configuration updated with deployment parameters"
        
        # Mark that Docker containers need recreation due to environment variable changes
        export FORCE_RECREATE_CONTAINERS="true"
        log "🔄 Environment variables updated - Docker containers will be recreated to apply changes"
        
        # Configure API Security if enabled
        if [[ "$ENABLE_API_AUTH" == "true" ]]; then
            log "🔐 Configuring API security..."
            
            # Generate API credentials if not provided
            if [[ -z "$API_KEY" ]]; then
                API_KEY=$(openssl rand -hex 32)
                log "🔐 Generated API Key: ${API_KEY:0:8}..." # Show first 8 chars for confirmation
            fi
            
            if [[ -z "$API_SECRET" ]]; then
                API_SECRET=$(openssl rand -hex 32)  
                log "🔐 Generated API Secret: ${API_SECRET:0:8}..." # Show first 8 chars for confirmation
            fi
            
            # Store in backend environment
            echo "API_KEY=$API_KEY" >> ./backend/.env
            echo "API_SECRET=$API_SECRET" >> ./backend/.env
            echo "API_AUTH_ENABLED=true" >> ./backend/.env
            
            success "API security configured for domain access only"
            
            # Mark that Docker containers need recreation for API security changes
            export FORCE_RECREATE_CONTAINERS="true"
            log "🔄 API security configuration changed - Docker containers will be recreated"
        else
            echo "API_AUTH_ENABLED=false" >> ./backend/.env
            log "🔓 API authentication disabled (development mode)"
            
            # Mark that Docker containers need recreation for API security changes
            export FORCE_RECREATE_CONTAINERS="true"
            log "🔄 API security configuration changed - Docker containers will be recreated"
        fi
        
        # Frontend nginx configuration (no proxy setup needed - using Kong for HTTPS)
        log "🔧 Frontend nginx configured for Kong API Gateway integration"
    fi
    
    # Ensure SSL certificates exist
    if [ ! -f "$SSL_CERT_PATH/portfolio.crt" ] || [ ! -f "$SSL_CERT_PATH/portfolio.key" ]; then
        log "🔐 Generating SSL certificates..."
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout "$SSL_CERT_PATH/portfolio.key" \
            -out "$SSL_CERT_PATH/portfolio.crt" \
            -subj "/C=UK/ST=London/L=London/O=ARCHSOL IT Solutions/OU=IT Portfolio/CN=localhost/emailAddress=kamal.singh@architecturesolutions.co.uk"
        success "SSL certificates generated"
    fi
    
    log "Deploying production stack with all custom parameters..."
    
    # Add force rebuild option and environment variable recreation
    BUILD_FLAGS=""
    if [ "$FORCE_REBUILD" = "true" ]; then
        log "🔨 Force rebuilding all images (ignoring cache)..."
        BUILD_FLAGS="--build --force-recreate --no-deps"
    elif [ "$FORCE_RECREATE_CONTAINERS" = "true" ]; then
        log "🔄 Force recreating containers due to environment variable changes..."
        BUILD_FLAGS="--force-recreate"
    fi
    
    # Force removal of problematic cached images and check for WiredTiger conflicts
    log "🔄 Removing cached MongoDB images to prevent version conflicts..."
    docker rmi -f $(docker images -q mongo:5.0 mongo:5.* mongo:6.* 2>/dev/null) 2>/dev/null || true
    docker rmi -f $(docker images -q --filter reference="*backend*" 2>/dev/null) 2>/dev/null || true
    
    # Check for existing MongoDB WiredTiger conflicts
    if docker ps -a --filter "name=portfolio-mongodb" --format "{{.Names}}" | grep -q portfolio-mongodb; then
        MONGODB_ERRORS=$(docker logs portfolio-mongodb 2>/dev/null | grep -c "unsupported WiredTiger file version" || echo "0")
        if [ "$MONGODB_ERRORS" -gt 0 ]; then
            warning "⚠️  DETECTED: Existing MongoDB has WiredTiger version conflict!"
            warning "Removing problematic MongoDB container and volumes..."
            docker stop portfolio-mongodb 2>/dev/null || true
            docker rm -f portfolio-mongodb 2>/dev/null || true
            docker volume rm app_mongodb-data app_mongodb-config 2>/dev/null || true
            success "MongoDB conflict resolved - will deploy fresh"
        fi
    fi
    
    # Deploy with proper dependency order
    log "🚀 Deploying with dependency-aware order..."
    
    # Step 1: Deploy core infrastructure first
    log "Step 1: Deploying core infrastructure (MongoDB, Redis)..."
    if [ -n "$ENV_FILE" ]; then
        docker-compose -f docker-compose.production.yml --env-file "$ENV_FILE" up -d $BUILD_FLAGS mongodb redis
    else
        docker-compose -f docker-compose.production.yml up -d $BUILD_FLAGS mongodb redis
    fi
    
    # Wait for MongoDB to be ready
    log "⏳ Waiting for MongoDB to be ready..."
    sleep 15
    
    # Step 2: Deploy backend (depends on MongoDB)
    log "Step 2: Deploying backend..."
    if [ -n "$ENV_FILE" ]; then
        docker-compose -f docker-compose.production.yml --env-file "$ENV_FILE" up -d $BUILD_FLAGS backend
    else
        docker-compose -f docker-compose.production.yml up -d $BUILD_FLAGS backend
    fi
    
    # Wait for backend to be ready
    log "⏳ Waiting for backend to be ready..."
    sleep 10
    
    # Step 3: Deploy database admin (depends on MongoDB)
    log "Step 3: Deploying database admin..."
    if [ -n "$ENV_FILE" ]; then
        docker-compose -f docker-compose.production.yml --env-file "$ENV_FILE" up -d $BUILD_FLAGS mongo-express
    else
        docker-compose -f docker-compose.production.yml up -d $BUILD_FLAGS mongo-express
    fi
    
    # Step 4: Deploy frontend services
    log "Step 4: Deploying frontend services..."
    if [ -n "$ENV_FILE" ]; then
        docker-compose -f docker-compose.production.yml --env-file "$ENV_FILE" up -d $BUILD_FLAGS frontend-http frontend-https
    else
        docker-compose -f docker-compose.production.yml up -d $BUILD_FLAGS frontend-http frontend-https
    fi
    
    # Step 5: Deploy monitoring stack
    log "Step 5: Deploying monitoring stack..."
    if [ -n "$ENV_FILE" ]; then
        docker-compose -f docker-compose.production.yml --env-file "$ENV_FILE" up -d $BUILD_FLAGS prometheus grafana loki promtail node-exporter
    else
        docker-compose -f docker-compose.production.yml up -d $BUILD_FLAGS prometheus grafana loki promtail node-exporter
    fi
    
    # Step 6: Deploy backup service (if not skipped)
    if [ "$SKIP_BACKUP" = "true" ]; then
        log "⏭️  Skipping backup service deployment..."
    else
        log "Step 6: Deploying backup service..."
        if [ -n "$ENV_FILE" ]; then
            docker-compose -f docker-compose.production.yml --env-file "$ENV_FILE" up -d $BUILD_FLAGS backup
        else
            docker-compose -f docker-compose.production.yml up -d $BUILD_FLAGS backup
        fi
    fi
    
    log "Waiting for services to start..."
    sleep 30
    
    success "🎉 Complete enterprise deployment finished!"
    echo ""
    
    # Display API credentials if security is enabled
    if [[ "$ENABLE_API_AUTH" == "true" && -n "$DOMAIN" ]]; then
        echo -e "${BLUE}🔐 API Security Configuration${NC}"
        echo "=================================================="
        echo -e "${YELLOW}⚠️  IMPORTANT: Copy these credentials to your Traefik configuration${NC}"
        echo ""
        echo -e "API Key:    ${GREEN}$API_KEY${NC}"
        echo -e "API Secret: ${GREEN}$API_SECRET${NC}"
        echo ""
        echo -e "📁 Traefik config file: ${BLUE}./traefik/api-auth-middleware.toml${NC}"
        echo -e "🔗 Secured domain: ${BLUE}https://$DOMAIN${NC}"
        echo -e "🔓 Development access: ${BLUE}http://$(hostname -I | awk '{print $1}'):$HTTP_PORT${NC} (no auth required)"
        echo "=================================================="
        echo ""
    fi
    
    echo "Access URLs:"
    echo "  Portfolio HTTP:   http://localhost:$HTTP_PORT"
    echo "  Portfolio HTTPS:  https://localhost:$HTTPS_PORT"
    echo "  Backend API:      http://localhost:$BACKEND_PORT/docs"
    echo "  Mongo Express:    http://localhost:$MONGO_EXPRESS_PORT"
    echo "  Grafana:          http://localhost:$GRAFANA_PORT"
    echo "  Prometheus:       http://localhost:$PROMETHEUS_PORT"
    echo "  Loki:             http://localhost:$LOKI_PORT"
}

# Build test function
test_builds_only() {
    log "🔧 BUILD TEST MODE - Testing Docker builds only..."
    echo ""
    
    # Test docker-compose file validation
    log "Step 1/4: Validating docker-compose.production.yml..."
    if ! docker-compose -f docker-compose.production.yml config --quiet; then
        error "❌ Docker Compose file validation failed"
        exit 1
    fi
    success "✅ Docker Compose file is valid"
    
    # Test Docker build process for each service
    log "Step 2/4: Testing frontend HTTP build..."
    if ! docker build -f Dockerfile.npm.optimized -t test-frontend-http . --no-cache; then
        error "❌ Frontend HTTP build failed"
        exit 1
    fi
    success "✅ Frontend HTTP builds successfully"
    
    log "Step 3/4: Testing backend build..."
    if ! docker build -f Dockerfile.backend.optimized -t test-backend . --no-cache; then
        error "❌ Backend build failed"
        exit 1
    fi
    success "✅ Backend builds successfully"
    
    log "Step 4/4: Cleaning up test images..."
    docker rmi test-frontend-http test-backend 2>/dev/null || true
    
    echo ""
    success "🎉 BUILD TEST COMPLETED - All builds successful!"
    echo ""
}

# Handle build test mode
if [ "$BUILD_TEST" = "true" ]; then
    test_builds_only
    exit 0
fi

deploy_stack