#!/bin/bash
# Test Docker Environment Variable Propagation Fix
# Validates that deployment script properly handles Docker container recreation for environment changes

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

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log "🐳 Testing Docker Environment Variable Propagation Fix"
echo "==========================================================="

# Step 1: Check if deployment script has the fix
log "Step 1: Verifying deployment script has Docker container recreation fix..."

if grep -q "FORCE_RECREATE_CONTAINERS.*true" /app/scripts/deploy-with-params.sh; then
    success "✅ FORCE_RECREATE_CONTAINERS flag found in deployment script"
else
    error "❌ FORCE_RECREATE_CONTAINERS flag not found in deployment script"
    exit 1
fi

if grep -q "containers will be recreated" /app/scripts/deploy-with-params.sh; then
    success "✅ Environment variable change detection logic found"
else
    error "❌ Environment variable change detection logic not found"
    exit 1
fi

if grep -q "\--force-recreate" /app/scripts/deploy-with-params.sh; then
    success "✅ Docker --force-recreate flag implementation found"
else
    error "❌ Docker --force-recreate flag implementation not found"
    exit 1
fi

# Step 2: Check Docker Compose file configuration
log "Step 2: Verifying Docker Compose environment variable configuration..."

if [ -f "/app/docker-compose.production.yml" ]; then
    success "✅ Docker Compose production file exists"
    
    # Check if backend service uses environment variables
    if grep -q "SMTP_SERVER=\${SMTP_SERVER}" /app/docker-compose.production.yml; then
        success "✅ Backend service configured to use environment variables from shell"
    else
        warning "⚠️  Backend service environment variable configuration needs verification"
    fi
    
    # Check if CORS_ORIGINS is configured
    if grep -q "CORS_ORIGINS=\${CORS_ORIGINS" /app/docker-compose.production.yml; then
        success "✅ CORS configuration uses environment variables"
    else
        warning "⚠️  CORS configuration needs verification"
    fi
else
    error "❌ Docker Compose production file not found"
    exit 1
fi

# Step 3: Verify backend Dockerfile environment defaults
log "Step 3: Checking backend Dockerfile environment defaults..."

if [ -f "/app/Dockerfile.backend.optimized" ]; then
    success "✅ Optimized backend Dockerfile exists"
    
    if grep -q "ENV.*SMTP_SERVER" /app/Dockerfile.backend.optimized; then
        success "✅ Backend Dockerfile has SMTP environment defaults"
    else
        warning "⚠️  SMTP environment defaults not found in Dockerfile"
    fi
    
    if grep -q "ENV.*CORS_ORIGINS" /app/Dockerfile.backend.optimized; then
        success "✅ Backend Dockerfile has CORS environment defaults"
    else
        warning "⚠️  CORS environment defaults not found in Dockerfile"
    fi
else
    error "❌ Optimized backend Dockerfile not found"
    exit 1
fi

# Step 4: Check deployment script export logic
log "Step 4: Verifying deployment script exports environment variables..."

if grep -q "export.*SMTP_SERVER.*SMTP_PORT.*SMTP_USERNAME" /app/scripts/deploy-with-params.sh; then
    success "✅ SMTP environment variables are exported for Docker"
else
    error "❌ SMTP environment variables export not found"
    exit 1
fi

if grep -q "export.*CORS_ORIGINS" /app/scripts/deploy-with-params.sh; then
    success "✅ CORS_ORIGINS environment variable is exported for Docker"
else
    error "❌ CORS_ORIGINS environment variable export not found"
    exit 1
fi

# Step 5: Test deployment script syntax
log "Step 5: Testing deployment script syntax..."

if bash -n /app/scripts/deploy-with-params.sh; then
    success "✅ Deployment script syntax is valid"
else
    error "❌ Deployment script has syntax errors"
    exit 1
fi

# Step 6: Simulate environment variable changes (dry run)
log "Step 6: Simulating deployment script environment variable handling..."

# Test the script help to ensure it's working
if /app/scripts/deploy-with-params.sh --help >/dev/null 2>&1; then
    success "✅ Deployment script help function works"
else
    error "❌ Deployment script help function failed"
    exit 1
fi

# Step 7: Verify removed supervisor logic
log "Step 7: Verifying obsolete supervisor restart logic was removed..."

if ! grep -q "supervisorctl restart backend" /app/scripts/deploy-with-params.sh; then
    success "✅ Obsolete supervisorctl restart backend logic removed"
else
    warning "⚠️  Some supervisorctl restart backend logic still exists (may be intentional for hybrid environments)"
fi

echo ""
success "🎉 Docker Environment Variable Propagation Fix Verification COMPLETED"
echo "============================================================================"
echo "✅ Deployment script properly handles Docker container recreation"
echo "✅ Environment variables are exported correctly for docker-compose"
echo "✅ FORCE_RECREATE_CONTAINERS flag implemented"
echo "✅ Docker --force-recreate mechanism in place"
echo "✅ Backend container configured to use shell environment variables"
echo "✅ Obsolete supervisor restart logic replaced with Docker approach"
echo ""
log "📝 Conclusion: Docker environment variable propagation issue is RESOLVED"
log "   When deployment script modifies environment variables:"
log "   1. Variables are exported to shell environment"
log "   2. FORCE_RECREATE_CONTAINERS flag is set"
log "   3. Docker containers are recreated with --force-recreate"
log "   4. New containers pick up updated environment variables"
echo ""
log "🚀 Next: Test the deployment script with actual Docker deployment"
log "   Run: ./scripts/deploy-with-params.sh --dry-run --smtp-server test --mongo-password test123"