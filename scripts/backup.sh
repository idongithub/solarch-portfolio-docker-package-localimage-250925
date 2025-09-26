#!/bin/bash
# Phase 3: Automated Backup Script
# MongoDB and application data backup with rotation

set -e

# Configuration
MONGO_HOST="${MONGO_HOST:-mongodb}"
MONGO_PORT="${MONGO_PORT:-27017}"
MONGO_USERNAME="${MONGO_USERNAME:-admin}"
MONGO_PASSWORD="${MONGO_PASSWORD}"
BACKUP_DIR="${BACKUP_DIR:-/backups}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="portfolio_backup_${TIMESTAMP}"

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

# Create backup directory
mkdir -p "${BACKUP_DIR}"

log "Starting backup process for ARCHSOL IT Portfolio"
log "Backup name: ${BACKUP_NAME}"

# MongoDB Backup
if [ -n "$MONGO_PASSWORD" ]; then
    log "Creating MongoDB backup..."
    
    mongodump \
        --host "${MONGO_HOST}:${MONGO_PORT}" \
        --username "$MONGO_USERNAME" \
        --password "$MONGO_PASSWORD" \
        --authenticationDatabase admin \
        --out "${BACKUP_DIR}/${BACKUP_NAME}/mongodb" \
        --gzip \
        --verbose
    
    if [ $? -eq 0 ]; then
        success "MongoDB backup completed"
    else
        error "MongoDB backup failed"
        exit 1
    fi
else
    warning "MongoDB password not provided, skipping database backup"
fi

# Application Data Backup
log "Backing up application data..."

# Backup uploads directory if it exists
if [ -d "/app/uploads" ]; then
    log "Backing up uploads directory..."
    cp -r /app/uploads "${BACKUP_DIR}/${BACKUP_NAME}/uploads"
    success "Uploads backup completed"
fi

# Backup logs directory if it exists
if [ -d "/app/logs" ]; then
    log "Backing up logs directory..."
    cp -r /app/logs "${BACKUP_DIR}/${BACKUP_NAME}/logs"
    success "Logs backup completed"
fi

# Backup configuration files
log "Backing up configuration files..."
mkdir -p "${BACKUP_DIR}/${BACKUP_NAME}/config"

# Copy important configuration files
for config_file in \
    "/app/docker-compose.yml" \
    "/app/docker-compose.production.yml" \
    "/app/nginx/nginx-production.conf" \
    "/app/monitoring/prometheus.yml" \
    "/app/monitoring/alert_rules.yml"; do
    
    if [ -f "$config_file" ]; then
        cp "$config_file" "${BACKUP_DIR}/${BACKUP_NAME}/config/"
        log "Backed up $(basename $config_file)"
    fi
done

# Create backup metadata
log "Creating backup metadata..."
cat > "${BACKUP_DIR}/${BACKUP_NAME}/backup_info.json" << EOF
{
    "backup_name": "${BACKUP_NAME}",
    "timestamp": "${TIMESTAMP}",
    "date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "version": "3.0.0",
    "environment": "production",
    "components": {
        "mongodb": $([ -n "$MONGO_PASSWORD" ] && echo "true" || echo "false"),
        "uploads": $([ -d "/app/uploads" ] && echo "true" || echo "false"),
        "logs": $([ -d "/app/logs" ] && echo "true" || echo "false"),
        "config": true
    },
    "size_bytes": $(du -sb "${BACKUP_DIR}/${BACKUP_NAME}" | cut -f1)
}
EOF

# Compress backup
log "Compressing backup..."
cd "${BACKUP_DIR}"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"

if [ $? -eq 0 ]; then
    # Remove uncompressed backup
    rm -rf "${BACKUP_NAME}"
    
    # Get final backup size
    BACKUP_SIZE=$(du -sh "${BACKUP_NAME}.tar.gz" | cut -f1)
    success "Backup compressed: ${BACKUP_NAME}.tar.gz (${BACKUP_SIZE})"
else
    error "Backup compression failed"
    exit 1
fi

# Cleanup old backups
log "Cleaning up old backups (retention: ${RETENTION_DAYS} days)..."
find "${BACKUP_DIR}" -name "portfolio_backup_*.tar.gz" -type f -mtime +${RETENTION_DAYS} -delete

# Count remaining backups
BACKUP_COUNT=$(find "${BACKUP_DIR}" -name "portfolio_backup_*.tar.gz" -type f | wc -l)
log "Backup retention cleanup completed. ${BACKUP_COUNT} backups remaining."

# Create latest symlink
ln -sf "${BACKUP_NAME}.tar.gz" "${BACKUP_DIR}/latest_backup.tar.gz"

# Backup verification
log "Verifying backup integrity..."
if tar -tzf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" > /dev/null 2>&1; then
    success "Backup integrity verified"
else
    error "Backup integrity check failed"
    exit 1
fi

# Send notification (if configured)
if [ -n "$WEBHOOK_URL" ]; then
    log "Sending backup notification..."
    curl -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"text\": \"✅ ARCHSOL IT Portfolio backup completed successfully\",
            \"attachments\": [{
                \"color\": \"good\",
                \"fields\": [
                    {\"title\": \"Backup Name\", \"value\": \"${BACKUP_NAME}.tar.gz\", \"short\": true},
                    {\"title\": \"Size\", \"value\": \"${BACKUP_SIZE}\", \"short\": true},
                    {\"title\": \"Timestamp\", \"value\": \"$(date)\", \"short\": false}
                ]
            }]
        }" > /dev/null 2>&1
fi

# Final summary
log "================================================"
success "Backup process completed successfully!"
log "Backup file: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
log "Backup size: ${BACKUP_SIZE}"
log "Retention: ${RETENTION_DAYS} days (${BACKUP_COUNT} backups kept)"
log "================================================"

# Exit with success
exit 0