#!/bin/bash

# Kong API Gateway Setup Script for Portfolio Application
# This script configures Kong to proxy HTTPS frontend calls to HTTP backend

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
KONG_ADMIN_URL="${KONG_ADMIN_URL:-http://localhost:8101}"
BACKEND_URL="${BACKEND_URL:-http://192.168.86.75:3001}"
FRONTEND_HTTPS_ORIGIN="${FRONTEND_HTTPS_ORIGIN:-https://192.168.86.75:3443}"

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to wait for Kong Admin API
wait_for_kong() {
    log "Waiting for Kong Admin API to be ready..."
    local retries=30
    local count=0
    
    while [ $count -lt $retries ]; do
        if curl -s "${KONG_ADMIN_URL}/status" > /dev/null 2>&1; then
            success "Kong Admin API is ready!"
            return 0
        fi
        
        count=$((count + 1))
        echo -n "."
        sleep 2
    done
    
    error "Kong Admin API failed to start after ${retries} attempts"
    return 1
}

# Function to create Kong service
create_service() {
    log "Creating portfolio-backend service..."
    
    local response
    response=$(curl -s -X POST "${KONG_ADMIN_URL}/services/" \
        --data "name=portfolio-backend" \
        --data "url=${BACKEND_URL}" \
        --data "protocol=http")
    
    if echo "$response" | grep -q '"name":"portfolio-backend"'; then
        success "Service 'portfolio-backend' created successfully"
    elif echo "$response" | grep -q "already exists"; then
        warning "Service 'portfolio-backend' already exists"
    else
        error "Failed to create service: $response"
        return 1
    fi
}

# Function to create Kong route
create_route() {
    log "Creating API route for /api paths..."
    
    local response
    response=$(curl -s -X POST "${KONG_ADMIN_URL}/services/portfolio-backend/routes" \
        --data "name=portfolio-api-route" \
        --data "paths[]=/api" \
        --data "methods[]=GET" \
        --data "methods[]=POST" \
        --data "methods[]=OPTIONS" \
        --data "strip_path=false" \
        --data "preserve_host=false")
    
    if echo "$response" | grep -q '"name":"portfolio-api-route"'; then
        success "Route 'portfolio-api-route' created successfully"
    elif echo "$response" | grep -q "already exists"; then
        warning "Route 'portfolio-api-route' already exists"
    else
        error "Failed to create route: $response"
        return 1
    fi
}

# Function to configure CORS plugin
configure_cors() {
    log "Configuring CORS plugin for HTTPS frontend..."
    
    local response
    response=$(curl -s -X POST "${KONG_ADMIN_URL}/services/portfolio-backend/plugins" \
        --data "name=cors" \
        --data "config.origins=${FRONTEND_HTTPS_ORIGIN}" \
        --data "config.methods=GET,POST,OPTIONS,PUT,DELETE,PATCH" \
        --data "config.headers=Accept,Content-Type,Authorization,X-Requested-With" \
        --data "config.credentials=true" \
        --data "config.preflight_continue=false")
    
    if echo "$response" | grep -q '"name":"cors"'; then
        success "CORS plugin configured successfully"
    elif echo "$response" | grep -q "already exists"; then
        warning "CORS plugin already exists"
        # Update existing plugin
        log "Updating existing CORS plugin..."
        local plugin_id
        plugin_id=$(curl -s "${KONG_ADMIN_URL}/services/portfolio-backend/plugins" | \
                   grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
        
        if [ -n "$plugin_id" ]; then
            curl -s -X PATCH "${KONG_ADMIN_URL}/plugins/${plugin_id}" \
                --data "config.origins=${FRONTEND_HTTPS_ORIGIN}" \
                --data "config.methods=GET,POST,OPTIONS,PUT,DELETE,PATCH" \
                --data "config.headers=Accept,Content-Type,Authorization,X-Requested-With" \
                --data "config.credentials=true" > /dev/null
            success "CORS plugin updated successfully"
        fi
    else
        error "Failed to configure CORS plugin: $response"
        return 1
    fi
}

# Function to verify configuration
verify_configuration() {
    log "Verifying Kong configuration..."
    
    # Test Kong health
    if curl -s "${KONG_ADMIN_URL}/status" | grep -q '"database":{"reachable":true}'; then
        success "Kong is healthy and database is reachable"
    else
        error "Kong health check failed"
        return 1
    fi
    
    # Test service
    if curl -s "${KONG_ADMIN_URL}/services/portfolio-backend" | grep -q '"name":"portfolio-backend"'; then
        success "Service configuration verified"
    else
        error "Service verification failed"
        return 1
    fi
    
    # Test route
    if curl -s "${KONG_ADMIN_URL}/routes" | grep -q '"name":"portfolio-api-route"'; then
        success "Route configuration verified"
    else
        error "Route verification failed"
        return 1
    fi
    
    # Test CORS plugin
    if curl -s "${KONG_ADMIN_URL}/services/portfolio-backend/plugins" | grep -q '"name":"cors"'; then
        success "CORS plugin configuration verified"
    else
        error "CORS plugin verification failed"
        return 1
    fi
}

# Function to test Kong proxy
test_kong_proxy() {
    log "Testing Kong proxy functionality..."
    
    # Test HTTP proxy (port 8000)
    local http_response
    http_response=$(curl -s -w "%{http_code}" "http://localhost:8000/api/health" | tail -n1)
    
    if [ "$http_response" = "200" ]; then
        success "Kong HTTP proxy (port 8000) is working"
    else
        warning "Kong HTTP proxy test returned status: $http_response"
    fi
    
    # Test HTTPS proxy (port 8443) - skip SSL verification for self-signed certs
    local https_response
    https_response=$(curl -s -k -w "%{http_code}" "https://localhost:8443/api/health" | tail -n1)
    
    if [ "$https_response" = "200" ]; then
        success "Kong HTTPS proxy (port 8443) is working"
    else
        warning "Kong HTTPS proxy test returned status: $https_response"
    fi
}

# Main execution
main() {
    echo -e "${BLUE}🌉 Kong API Gateway Setup for Portfolio Application${NC}"
    echo "=================================================="
    echo ""
    echo "Configuration:"
    echo "  Kong Admin URL: $KONG_ADMIN_URL"
    echo "  Backend URL: $BACKEND_URL"
    echo "  HTTPS Frontend Origin: $FRONTEND_HTTPS_ORIGIN"
    echo ""
    
    # Wait for Kong to be ready
    wait_for_kong
    
    # Create service and routes
    create_service
    create_route
    configure_cors
    
    # Verify configuration
    verify_configuration
    
    # Test proxy functionality
    test_kong_proxy
    
    echo ""
    success "Kong API Gateway setup completed successfully!"
    echo ""
    echo "🔍 Available endpoints:"
    echo "  • Kong Admin API: $KONG_ADMIN_URL"
    echo "  • Kong HTTP Proxy: http://localhost:8000"
    echo "  • Kong HTTPS Proxy: https://localhost:8443"
    echo "  • Kong Manager GUI: http://localhost:8002"
    echo ""
    echo "✅ HTTPS Frontend (${FRONTEND_HTTPS_ORIGIN}) can now call:"
    echo "  https://localhost:8443/api/health"
    echo "  https://localhost:8443/api/contact/send-email"
    echo ""
}

# Help function
show_help() {
    echo "Kong API Gateway Setup Script"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  --kong-admin URL        Kong Admin API URL (default: http://localhost:8101)"
    echo "  --backend-url URL       Backend service URL (default: http://192.168.86.75:3001)"
    echo "  --frontend-origin URL   HTTPS frontend origin (default: https://192.168.86.75:3443)"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 --backend-url http://localhost:3001 --frontend-origin https://localhost:3443"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --kong-admin)
            KONG_ADMIN_URL="$2"
            shift 2
            ;;
        --backend-url)
            BACKEND_URL="$2"
            shift 2
            ;;
        --frontend-origin)
            FRONTEND_HTTPS_ORIGIN="$2"
            shift 2
            ;;
        *)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
main