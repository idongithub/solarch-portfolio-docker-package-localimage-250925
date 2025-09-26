#!/bin/bash

# All-in-One Startup Script for Kamal Singh Portfolio
# Initializes and starts all services in a single container

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}=============================================="
echo -e "Kamal Singh Portfolio - All-in-One Container"
echo -e "==============================================${NC}"

# Function to log with timestamp
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Function to check if service is running
wait_for_service() {
    local service=$1
    local port=$2
    local timeout=${3:-60}
    
    log "⏳ Waiting for $service on port $port..."
    
    for i in $(seq 1 $timeout); do
        if nc -z localhost "$port" 2>/dev/null; then
            log "${GREEN}✅ $service is ready!${NC}"
            return 0
        fi
        sleep 1
    done
    
    log "${RED}❌ Timeout waiting for $service${NC}"
    return 1
}

# Function to generate SSL certificates
generate_ssl_certs() {
    log "🔒 Generating SSL certificates..."
    
    if [ ! -f /etc/ssl/certs/portfolio.crt ]; then
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /etc/ssl/private/portfolio.key \
            -out /etc/ssl/certs/portfolio.crt \
            -subj "/C=UK/ST=Buckinghamshire/L=Amersham/O=Kamal Singh Portfolio/CN=localhost" \
            > /dev/null 2>&1
        
        chmod 600 /etc/ssl/private/portfolio.key
        log "${GREEN}✅ SSL certificates generated${NC}"
    else
        log "${GREEN}✅ SSL certificates already exist${NC}"
    fi
}

# Function to initialize MongoDB
init_mongodb() {
    log "🗄️ Initializing MongoDB..."
    
    # Start MongoDB temporarily for initialization
    mongod --dbpath /data/db --fork --logpath /tmp/mongod_init.log --bind_ip_all
    
    # Wait for MongoDB to start
    sleep 5
    
    # Initialize database
    if [ -f /app/init_database.js ]; then
        log "📊 Running database initialization script..."
        mongosh --file /app/init_database.js > /dev/null 2>&1 || log "${YELLOW}⚠️ Database initialization script had issues${NC}"
    fi
    
    # Stop temporary MongoDB instance
    mongod --shutdown --dbpath /data/db > /dev/null 2>&1 || true
    
    log "${GREEN}✅ MongoDB initialization completed${NC}"
}

# Function to configure Nginx with dynamic ports
configure_nginx() {
    log "🌐 Configuring Nginx..."
    
    # Ensure SSL directories exist
    mkdir -p /etc/ssl/certs /etc/ssl/private
    
    # Update Nginx configuration with environment variables
    if [ ! -z "$HTTP_PORT" ] && [ "$HTTP_PORT" != "80" ]; then
        sed -i "s/listen 80/listen $HTTP_PORT/g" /etc/nginx/sites-available/default
    fi
    
    if [ ! -z "$HTTPS_PORT" ] && [ "$HTTPS_PORT" != "443" ]; then
        sed -i "s/listen 443/listen $HTTPS_PORT/g" /etc/nginx/sites-available/default
    fi
    
    # Ensure the configuration file exists and is readable
    if [ ! -f /etc/nginx/sites-available/default ]; then
        log "${RED}❌ Nginx configuration file not found${NC}"
        exit 1
    fi
    
    # Test Nginx configuration
    log "🔍 Testing Nginx configuration..."
    if nginx -t; then
        log "${GREEN}✅ Nginx configuration test passed${NC}"
    else
        log "${RED}❌ Nginx configuration test failed${NC}"
        log "Configuration file contents:"
        cat /etc/nginx/sites-available/default
        exit 1
    fi
}

# Function to update backend environment
configure_backend() {
    log "🔧 Configuring backend environment..."
    
    # Create backend .env file from environment variables
    cat > /app/backend/.env << EOF
# Auto-generated configuration from container environment
MONGO_URL=${MONGO_URL}
DB_NAME=${DB_NAME}
HOST=0.0.0.0
PORT=8001
ENVIRONMENT=${ENVIRONMENT}
DEBUG=${DEBUG}

# Email Configuration
SMTP_SERVER=${SMTP_SERVER}
SMTP_PORT=${SMTP_PORT}
SMTP_USE_TLS=${SMTP_USE_TLS}
SMTP_USERNAME=${SMTP_USERNAME}
SMTP_PASSWORD=${SMTP_PASSWORD}
FROM_EMAIL=${FROM_EMAIL}
TO_EMAIL=${TO_EMAIL}
EMAIL_RATE_LIMIT_WINDOW=${EMAIL_RATE_LIMIT_WINDOW}
EMAIL_RATE_LIMIT_MAX=${EMAIL_RATE_LIMIT_MAX}

# Security
SECRET_KEY=${SECRET_KEY}
ADMIN_TOKEN=${ADMIN_TOKEN}

# CORS
CORS_ORIGINS=${CORS_ORIGINS}

# Website URL
WEBSITE_URL=${WEBSITE_URL}
EOF
    
    log "${GREEN}✅ Backend configuration updated${NC}"
}

# Function to show configuration summary
show_configuration() {
    log "📋 Container Configuration:"
    echo -e "  🗄️ Database: ${DB_NAME}"
    echo -e "  🌐 HTTP Port: ${HTTP_PORT:-80}"
    echo -e "  🔒 HTTPS Port: ${HTTPS_PORT:-443}"
    echo -e "  📧 Email Service: ${SMTP_SERVER}"
    echo -e "  🎯 Environment: ${ENVIRONMENT}"
    echo -e "  📍 Website URL: ${WEBSITE_URL}"
    
    if [ -z "$SMTP_USERNAME" ] || [ -z "$SMTP_PASSWORD" ]; then
        echo -e "  ${YELLOW}⚠️ Email credentials not configured - contact form will not send emails${NC}"
    else
        echo -e "  ${GREEN}✅ Email service configured${NC}"
    fi
}

# Function to create log rotation
setup_log_rotation() {
    cat > /etc/logrotate.d/portfolio << EOF
/var/log/supervisor/*.log /var/log/nginx/*.log /var/log/mongodb/*.log {
    daily
    missingok
    rotate 7
    compress
    notifempty
    create 644 root root
    postrotate
        supervisorctl reload > /dev/null 2>&1 || true
    endscript
}
EOF
}

# Main initialization
main() {
    log "${PURPLE}🚀 Starting Kamal Singh Portfolio All-in-One Container...${NC}"
    
    # Show configuration
    show_configuration
    
    # Generate SSL certificates
    generate_ssl_certs
    
    # Configure services
    configure_backend
    configure_nginx
    
    # Setup log rotation
    setup_log_rotation
    
    # Initialize MongoDB
    init_mongodb
    
    # Create necessary directories
    mkdir -p /var/log/supervisor /var/log/nginx /var/log/mongodb /app/logs
    chown -R mongodb:mongodb /data/db
    
    log "${GREEN}✅ All services configured successfully!${NC}"
    
    # Start supervisor to manage all services
    log "${PURPLE}🎯 Starting all services with supervisor...${NC}"
    
    # Start supervisor in foreground
    exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/portfolio.conf
}

# Handle signals for graceful shutdown
trap 'log "${YELLOW}🛑 Shutting down container...${NC}"; exit 0' SIGTERM SIGINT

# Run main function
main "$@"