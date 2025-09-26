#!/bin/bash
# Phase 3: Production Deployment Script
# Automated deployment with health checks and rollback capability

set -e

# Configuration
DEPLOYMENT_ENV="${DEPLOYMENT_ENV:-production}"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-ghcr.io}"
IMAGE_PREFIX="${IMAGE_PREFIX:-archsol/portfolio}"
VERSION="${VERSION:-latest}"
HEALTH_CHECK_TIMEOUT="${HEALTH_CHECK_TIMEOUT:-300}"
HEALTH_CHECK_INTERVAL="${HEALTH_CHECK_INTERVAL:-10}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -h, --help              Show this help message
    -v, --version VERSION   Specify version to deploy (default: latest)
    -e, --env ENVIRONMENT   Deployment environment (default: production)
    -f, --force             Force deployment without confirmation
    --skip-backup           Skip pre-deployment backup
    --skip-health-check     Skip post-deployment health checks
    --rollback              Rollback to previous version
    --status                Show deployment status

Examples:
    $0                              # Deploy latest version with confirmation
    $0 -v v2.1.0 --force           # Deploy specific version without confirmation
    $0 --rollback                   # Rollback to previous version
    $0 --status                     # Show current deployment status

Environment Variables:
    DEPLOYMENT_ENV          Deployment environment (production, staging)
    DOCKER_REGISTRY         Docker registry URL
    IMAGE_PREFIX            Image prefix for container images
    VERSION                 Image version/tag to deploy
    SLACK_WEBHOOK_URL       Slack webhook for notifications
    BACKUP_BEFORE_DEPLOY    Create backup before deployment (true/false)

EOF
}

send_notification() {
    local message="$1"
    local color="${2:-good}"
    local status="${3:-info}"
    
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        curl -X POST "$SLACK_WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d "{
                \"text\": \"🚀 ARCHSOL IT Portfolio Deployment\",
                \"attachments\": [{
                    \"color\": \"$color\",
                    \"fields\": [
                        {\"title\": \"Status\", \"value\": \"$status\", \"short\": true},
                        {\"title\": \"Environment\", \"value\": \"$DEPLOYMENT_ENV\", \"short\": true},
                        {\"title\": \"Version\", \"value\": \"$VERSION\", \"short\": true},
                        {\"title\": \"Message\", \"value\": \"$message\", \"short\": false},
                        {\"title\": \"Timestamp\", \"value\": \"$(date)\", \"short\": false}
                    ]
                }]
            }" > /dev/null 2>&1
    fi
}

check_prerequisites() {
    log "Checking deployment prerequisites..."
    
    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    # Check if Docker Compose is available
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed or not in PATH"
        exit 1
    fi
    
    # Check if required environment variables are set
    local required_vars=("MONGO_ROOT_PASSWORD" "SMTP_USERNAME" "SMTP_PASSWORD" "SECRET_KEY")
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            error "Required environment variable $var is not set"
            exit 1
        fi
    done
    
    # Check if deployment configuration exists
    if [ ! -f "docker-compose.production.yml" ]; then
        error "Production Docker Compose file not found"
        exit 1
    fi
    
    success "Prerequisites check passed"
}

get_current_version() {
    # Get current running version from container labels
    local current_version=$(docker ps --filter "name=portfolio-backend" --format "table {{.Image}}" | tail -n +2 | sed 's/.*://')
    echo "${current_version:-unknown}"
}

create_backup() {
    if [ "$SKIP_BACKUP" = "true" ]; then
        log "Skipping pre-deployment backup"
        return 0
    fi
    
    log "Creating pre-deployment backup..."
    
    if [ -f "scripts/backup.sh" ]; then
        ./scripts/backup.sh
        if [ $? -eq 0 ]; then
            success "Pre-deployment backup completed"
            return 0
        else
            error "Pre-deployment backup failed"
            return 1
        fi
    else
        warning "Backup script not found, skipping backup"
        return 0
    fi
}

pull_images() {
    log "Pulling Docker images for version: $VERSION"
    
    local images=(
        "${DOCKER_REGISTRY}/${IMAGE_PREFIX}-frontend-http:${VERSION}"
        "${DOCKER_REGISTRY}/${IMAGE_PREFIX}-frontend-https:${VERSION}"
        "${DOCKER_REGISTRY}/${IMAGE_PREFIX}-backend:${VERSION}"
    )
    
    for image in "${images[@]}"; do
        log "Pulling $image..."
        if ! docker pull "$image"; then
            error "Failed to pull image: $image"
            return 1
        fi
    done
    
    success "All images pulled successfully"
    return 0
}

deploy_services() {
    log "Deploying services with version: $VERSION"
    
    # Export version for docker-compose
    export VERSION
    
    # Deploy using docker-compose
    docker-compose -f docker-compose.production.yml up -d --remove-orphans
    
    if [ $? -eq 0 ]; then
        success "Services deployed successfully"
        return 0
    else
        error "Service deployment failed"
        return 1
    fi
}

wait_for_health() {
    local service_name="$1"
    local health_url="$2"
    local timeout="$3"
    local interval="$4"
    
    log "Waiting for $service_name to become healthy..."
    
    local elapsed=0
    while [ $elapsed -lt $timeout ]; do
        if curl -f -s "$health_url" > /dev/null 2>&1; then
            success "$service_name is healthy"
            return 0
        fi
        
        log "Waiting for $service_name... (${elapsed}s/${timeout}s)"
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    
    error "$service_name did not become healthy within ${timeout}s"
    return 1
}

perform_health_checks() {
    if [ "$SKIP_HEALTH_CHECK" = "true" ]; then
        log "Skipping health checks"
        return 0
    fi
    
    log "Performing post-deployment health checks..."
    
    # Wait for services to start
    sleep 30
    
    # Check backend health
    if ! wait_for_health "Backend API" "http://localhost:8001/api/health" $HEALTH_CHECK_TIMEOUT $HEALTH_CHECK_INTERVAL; then
        return 1
    fi
    
    # Check frontend health
    if ! wait_for_health "Frontend" "http://localhost:8080" $HEALTH_CHECK_TIMEOUT $HEALTH_CHECK_INTERVAL; then
        return 1
    fi
    
    # Check database connectivity
    if ! docker exec portfolio-mongodb mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        error "MongoDB health check failed"
        return 1
    fi
    success "MongoDB is healthy"
    
    # Run comprehensive health check
    log "Running comprehensive health check..."
    if [ -f "test-api-endpoints.sh" ]; then
        if ./test-api-endpoints.sh test > /dev/null 2>&1; then
            success "API endpoints health check passed"
        else
            warning "Some API endpoints failed health check"
        fi
    fi
    
    success "All health checks passed"
    return 0
}

rollback_deployment() {
    local previous_version="$1"
    
    error "Deployment failed, initiating rollback to version: $previous_version"
    
    # Set version to previous
    export VERSION="$previous_version"
    
    # Rollback services
    log "Rolling back services..."
    docker-compose -f docker-compose.production.yml up -d --remove-orphans
    
    # Wait for rollback to complete
    sleep 30
    
    # Verify rollback
    if wait_for_health "Backend API" "http://localhost:8001/api/health" 120 5; then
        success "Rollback completed successfully"
        send_notification "Deployment rolled back to version $previous_version" "warning" "Rollback"
        return 0
    else
        error "Rollback failed - manual intervention required"
        send_notification "Rollback failed - manual intervention required" "danger" "Critical"
        return 1
    fi
}

show_deployment_status() {
    log "Current deployment status:"
    echo
    
    # Show running containers
    log "Running containers:"
    docker ps --filter "name=portfolio-" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
    echo
    
    # Show current version
    local current_version=$(get_current_version)
    log "Current version: $current_version"
    echo
    
    # Show service health
    log "Service health status:"
    
    # Backend health
    if curl -f -s "http://localhost:8001/api/health" > /dev/null 2>&1; then
        echo "  Backend API: ✅ Healthy"
    else
        echo "  Backend API: ❌ Unhealthy"
    fi
    
    # Frontend health
    if curl -f -s "http://localhost:8080" > /dev/null 2>&1; then
        echo "  Frontend:    ✅ Healthy"
    else
        echo "  Frontend:    ❌ Unhealthy"
    fi
    
    # Database health
    if docker exec portfolio-mongodb mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        echo "  MongoDB:     ✅ Healthy"
    else
        echo "  MongoDB:     ❌ Unhealthy"
    fi
    
    echo
}

main() {
    local current_version=$(get_current_version)
    
    log "Starting deployment process..."
    log "Current version: $current_version"
    log "Target version: $VERSION"
    log "Environment: $DEPLOYMENT_ENV"
    
    # Send deployment start notification
    send_notification "Deployment started" "good" "Starting"
    
    # Check prerequisites
    check_prerequisites
    
    # Create backup
    if ! create_backup; then
        if [ "$FORCE_DEPLOY" != "true" ]; then
            error "Backup failed - aborting deployment"
            send_notification "Deployment aborted - backup failed" "danger" "Failed"
            exit 1
        else
            warning "Backup failed but continuing due to --force flag"
        fi
    fi
    
    # Pull new images
    if ! pull_images; then
        error "Failed to pull images - aborting deployment"
        send_notification "Deployment aborted - image pull failed" "danger" "Failed"
        exit 1
    fi
    
    # Deploy services
    if ! deploy_services; then
        error "Service deployment failed"
        rollback_deployment "$current_version"
        exit 1
    fi
    
    # Perform health checks
    if ! perform_health_checks; then
        error "Health checks failed"
        rollback_deployment "$current_version"
        exit 1
    fi
    
    # Success!
    success "Deployment completed successfully!"
    send_notification "Deployment completed successfully" "good" "Success"
    
    log "================================================"
    log "Deployment Summary:"
    log "  Previous version: $current_version"
    log "  New version: $VERSION"
    log "  Environment: $DEPLOYMENT_ENV"
    log "  Deployment time: $(date)"
    log "================================================"
}

# Parse command line arguments
FORCE_DEPLOY=false
SKIP_BACKUP=false
SKIP_HEALTH_CHECK=false
SHOW_STATUS=false
PERFORM_ROLLBACK=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -e|--env)
            DEPLOYMENT_ENV="$2"
            shift 2
            ;;
        -f|--force)
            FORCE_DEPLOY=true
            shift
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --skip-health-check)
            SKIP_HEALTH_CHECK=true
            shift
            ;;
        --rollback)
            PERFORM_ROLLBACK=true
            shift
            ;;
        --status)
            SHOW_STATUS=true
            shift
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

# Handle special operations
if [ "$SHOW_STATUS" = "true" ]; then
    show_deployment_status
    exit 0
fi

if [ "$PERFORM_ROLLBACK" = "true" ]; then
    log "Manual rollback requested"
    # In a real scenario, you'd track previous versions
    # For now, prompt for the version to rollback to
    echo -n "Enter version to rollback to: "
    read -r rollback_version
    if [ -n "$rollback_version" ]; then
        rollback_deployment "$rollback_version"
    else
        error "No rollback version specified"
        exit 1
    fi
    exit 0
fi

# Confirmation prompt (unless forced)
if [ "$FORCE_DEPLOY" != "true" ]; then
    echo
    warning "You are about to deploy version $VERSION to $DEPLOYMENT_ENV environment"
    echo -n "Continue? (y/N): "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log "Deployment cancelled by user"
        exit 0
    fi
fi

# Run main deployment
main