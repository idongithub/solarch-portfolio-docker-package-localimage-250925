#!/bin/bash

# Frontend Environment Debug Script
# Use this to verify environment variables are properly set in deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
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

echo "🔍 Frontend Environment Variables Debug"
echo "======================================"

# 1. Check if containers are running
log "Checking running containers..."
docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}" | grep frontend || error "No frontend containers found"

# 2. Find frontend container names
HTTP_CONTAINER=$(docker ps --format "{{.Names}}" | grep frontend | grep http | head -1)
HTTPS_CONTAINER=$(docker ps --format "{{.Names}}" | grep frontend | grep https | head -1)

if [ -n "$HTTP_CONTAINER" ]; then
    log "Found HTTP container: $HTTP_CONTAINER"
else
    warning "HTTP frontend container not found"
fi

if [ -n "$HTTPS_CONTAINER" ]; then
    log "Found HTTPS container: $HTTPS_CONTAINER"
else
    warning "HTTPS frontend container not found"
fi

# 3. Check .env file
log "Checking frontend/.env file..."
if [ -f "./frontend/.env" ]; then
    success "Frontend .env file exists"
    echo "Kong variables in .env:"
    grep -E "KONG|BACKEND_URL_HTTP|RECAPTCHA" ./frontend/.env || warning "No Kong variables found in .env"
else
    error "Frontend .env file not found"
fi

# 4. Check environment variables in running containers
if [ -n "$HTTPS_CONTAINER" ]; then
    log "Checking environment variables in HTTPS container ($HTTPS_CONTAINER)..."
    
    echo "Container environment variables:"
    docker exec "$HTTPS_CONTAINER" env | grep -E "REACT_APP|NODE_ENV" || warning "No React environment variables found in container"
    
    echo ""
    log "Checking runtime config file..."
    docker exec "$HTTPS_CONTAINER" cat /usr/share/nginx/html/runtime-config.js 2>/dev/null || warning "Runtime config not found"
    
    echo ""
    log "Checking if runtime config is injected in HTML..."
    docker exec "$HTTPS_CONTAINER" grep -o "runtime-config.js" /usr/share/nginx/html/index.html 2>/dev/null && success "Runtime config found in HTML" || warning "Runtime config not injected in HTML"
fi

# 5. Test CSP headers
log "Testing CSP headers..."
CSP_TEST=$(curl -k -I https://192.168.86.75:3443 2>/dev/null | grep -i content-security-policy || echo "")
if [ -n "$CSP_TEST" ]; then
    success "CSP header found"
    echo "$CSP_TEST"
    
    # Check if Kong endpoint is allowed
    if echo "$CSP_TEST" | grep -q "192.168.86.75:8443"; then
        success "Kong endpoint (192.168.86.75:8443) allowed in CSP"
    else
        error "Kong endpoint NOT allowed in CSP"
    fi
else
    error "No CSP header found"
fi

# 6. Test Kong connectivity
log "Testing Kong connectivity..."
KONG_STATUS=$(curl -k -s -w "%{http_code}" https://192.168.86.75:8443/api/health 2>/dev/null | tail -n1)
if [ "$KONG_STATUS" = "200" ]; then
    success "Kong is responding (HTTP $KONG_STATUS)"
else
    warning "Kong response: HTTP $KONG_STATUS"
fi

# 7. Check built JavaScript for environment variables
if [ -n "$HTTPS_CONTAINER" ]; then
    log "Checking if environment variables are baked into build..."
    JS_CHECK=$(docker exec "$HTTPS_CONTAINER" find /usr/share/nginx/html/static/js -name "main.*.js" -exec cat {} \; 2>/dev/null | grep -o "192\.168\.86\.75:8443" || echo "")
    if [ -n "$JS_CHECK" ]; then
        success "Kong URL found in JavaScript build"
    else
        warning "Kong URL NOT found in JavaScript build"
    fi
fi

echo ""
echo "🎯 Summary:"
echo "==========="
echo "1. Check that environment variables are in .env file"
echo "2. Verify Docker build args are being passed during deployment"
echo "3. Ensure runtime config is being created and injected"
echo "4. Confirm CSP allows Kong connections"
echo "5. Test Kong connectivity directly"

echo ""
echo "🚀 Next Steps:"
echo "=============="
echo "If issues persist:"
echo "1. Rebuild with: docker-compose up -d --build --no-cache frontend"
echo "2. Check deployment script passes --kong-host and --kong-port"
echo "3. Verify Kong is running and accessible"
echo "4. Test frontend console for environment variable availability"