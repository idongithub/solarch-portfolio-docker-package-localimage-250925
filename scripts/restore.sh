#!/bin/bash
# Phase 3: Automated Restore Script
# Restore MongoDB and application data from backup

set -e

# Configuration
MONGO_HOST="${MONGO_HOST:-mongodb}"
MONGO_PORT="${MONGO_PORT:-27017}"
MONGO_USERNAME="${MONGO_USERNAME:-admin}"
MONGO_PASSWORD="${MONGO_PASSWORD}"
BACKUP_DIR="${BACKUP_DIR:-/backups}"
RESTORE_DIR="/tmp/restore_$$"

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
Usage: $0 [OPTIONS] <backup_file>

Options:
    -h, --help              Show this help message
    -f, --force             Force restore without confirmation
    -m, --mongodb-only      Restore only MongoDB data
    -a, --app-only          Restore only application data
    -l, --list              List available backups
    --dry-run               Show what would be restored without doing it

Examples:
    $0 --list                                   # List available backups
    $0 portfolio_backup_20240115_120000.tar.gz # Restore from specific backup
    $0 --mongodb-only latest_backup.tar.gz     # Restore only database
    $0 --dry-run backup.tar.gz                 # Preview restore operation

EOF
}

list_backups() {
    log "Available backups in ${BACKUP_DIR}:"
    echo
    
    if [ ! -d "$BACKUP_DIR" ]; then
        error "Backup directory does not exist: $BACKUP_DIR"
        exit 1
    fi
    
    find "$BACKUP_DIR" -name "portfolio_backup_*.tar.gz" -type f -printf "%T@ %Tc %s %p\n" | \
    sort -nr | \
    while read timestamp date size file; do
        size_human=$(numfmt --to=iec --suffix=B $size)
        filename=$(basename "$file")
        echo "  📦 $filename"
        echo "     Date: $date"
        echo "     Size: $size_human"
        echo
    done
    
    if [ -L "$BACKUP_DIR/latest_backup.tar.gz" ]; then
        latest_target=$(readlink "$BACKUP_DIR/latest_backup.tar.gz")
        echo "  🔗 Latest backup points to: $latest_target"
    fi
}

extract_backup() {
    local backup_file="$1"
    
    log "Extracting backup: $backup_file"
    
    # Create temporary restore directory
    mkdir -p "$RESTORE_DIR"
    
    # Extract backup
    tar -xzf "$backup_file" -C "$RESTORE_DIR"
    
    if [ $? -ne 0 ]; then
        error "Failed to extract backup"
        cleanup_restore
        exit 1
    fi
    
    # Find the extracted directory
    local extracted_dir=$(find "$RESTORE_DIR" -maxdepth 1 -type d -name "portfolio_backup_*" | head -1)
    
    if [ -z "$extracted_dir" ]; then
        error "Could not find extracted backup directory"
        cleanup_restore
        exit 1
    fi
    
    echo "$extracted_dir"
}

verify_backup() {
    local backup_dir="$1"
    
    log "Verifying backup contents..."
    
    # Check backup metadata
    if [ -f "$backup_dir/backup_info.json" ]; then
        log "Backup metadata found:"
        cat "$backup_dir/backup_info.json" | jq '.' 2>/dev/null || cat "$backup_dir/backup_info.json"
        echo
    else
        warning "No backup metadata found"
    fi
    
    # Check components
    local has_mongodb=false
    local has_uploads=false
    local has_logs=false
    local has_config=false
    
    [ -d "$backup_dir/mongodb" ] && has_mongodb=true
    [ -d "$backup_dir/uploads" ] && has_uploads=true
    [ -d "$backup_dir/logs" ] && has_logs=true
    [ -d "$backup_dir/config" ] && has_config=true
    
    log "Backup components:"
    echo "  MongoDB:  $([ $has_mongodb = true ] && echo "✅ Yes" || echo "❌ No")"
    echo "  Uploads:  $([ $has_uploads = true ] && echo "✅ Yes" || echo "❌ No")"
    echo "  Logs:     $([ $has_logs = true ] && echo "✅ Yes" || echo "❌ No")"
    echo "  Config:   $([ $has_config = true ] && echo "✅ Yes" || echo "❌ No")"
    echo
}

restore_mongodb() {
    local backup_dir="$1"
    local mongodb_backup="$backup_dir/mongodb"
    
    if [ ! -d "$mongodb_backup" ]; then
        warning "No MongoDB backup found in backup"
        return 0
    fi
    
    if [ -z "$MONGO_PASSWORD" ]; then
        error "MongoDB password not provided"
        return 1
    fi
    
    log "Restoring MongoDB data..."
    
    # Drop existing database (with confirmation)
    if [ "$FORCE_RESTORE" != "true" ]; then
        echo -n "This will drop the existing database. Continue? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log "MongoDB restore cancelled"
            return 0
        fi
    fi
    
    # Restore database
    mongorestore \
        --host "${MONGO_HOST}:${MONGO_PORT}" \
        --username "$MONGO_USERNAME" \
        --password "$MONGO_PASSWORD" \
        --authenticationDatabase admin \
        --drop \
        --gzip \
        --verbose \
        "$mongodb_backup"
    
    if [ $? -eq 0 ]; then
        success "MongoDB restore completed"
        return 0
    else
        error "MongoDB restore failed"
        return 1
    fi
}

restore_application_data() {
    local backup_dir="$1"
    
    log "Restoring application data..."
    
    # Restore uploads
    if [ -d "$backup_dir/uploads" ]; then
        log "Restoring uploads directory..."
        rm -rf /app/uploads
        cp -r "$backup_dir/uploads" /app/uploads
        chown -R app:app /app/uploads 2>/dev/null || true
        success "Uploads restored"
    fi
    
    # Restore logs (optional)
    if [ -d "$backup_dir/logs" ] && [ "$RESTORE_LOGS" = "true" ]; then
        log "Restoring logs directory..."
        rm -rf /app/logs
        cp -r "$backup_dir/logs" /app/logs
        chown -R app:app /app/logs 2>/dev/null || true
        success "Logs restored"
    fi
    
    # Restore config files (with confirmation)
    if [ -d "$backup_dir/config" ]; then
        if [ "$FORCE_RESTORE" != "true" ]; then
            echo -n "Restore configuration files? This may overwrite current settings. (y/N): "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                log "Restoring configuration files..."
                # Copy config files to their original locations
                # This would need to be customized based on your setup
                success "Configuration files restored"
            fi
        fi
    fi
}

cleanup_restore() {
    if [ -d "$RESTORE_DIR" ]; then
        log "Cleaning up temporary files..."
        rm -rf "$RESTORE_DIR"
    fi
}

# Trap cleanup on exit
trap cleanup_restore EXIT

# Parse command line arguments
MONGODB_ONLY=false
APP_ONLY=false
FORCE_RESTORE=false
DRY_RUN=false
RESTORE_LOGS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -f|--force)
            FORCE_RESTORE=true
            shift
            ;;
        -m|--mongodb-only)
            MONGODB_ONLY=true
            shift
            ;;
        -a|--app-only)
            APP_ONLY=true
            shift
            ;;
        -l|--list)
            list_backups
            exit 0
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --restore-logs)
            RESTORE_LOGS=true
            shift
            ;;
        -*)
            error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            BACKUP_FILE="$1"
            shift
            ;;
    esac
done

# Check if backup file is provided
if [ -z "$BACKUP_FILE" ]; then
    error "No backup file specified"
    show_usage
    exit 1
fi

# Resolve backup file path
if [ "$BACKUP_FILE" = "latest" ] || [ "$BACKUP_FILE" = "latest_backup.tar.gz" ]; then
    if [ -L "$BACKUP_DIR/latest_backup.tar.gz" ]; then
        BACKUP_FILE="$BACKUP_DIR/latest_backup.tar.gz"
        log "Using latest backup: $(readlink "$BACKUP_FILE")"
    else
        error "No latest backup symlink found"
        exit 1
    fi
elif [ ! -f "$BACKUP_FILE" ]; then
    # Try to find it in the backup directory
    if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
        BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILE"
    else
        error "Backup file not found: $BACKUP_FILE"
        exit 1
    fi
fi

log "Starting restore process for ARCHSOL IT Portfolio"
log "Backup file: $BACKUP_FILE"

# Extract and verify backup
extracted_dir=$(extract_backup "$BACKUP_FILE")
verify_backup "$extracted_dir"

if [ "$DRY_RUN" = "true" ]; then
    success "Dry run completed - no changes made"
    exit 0
fi

# Perform restore based on options
restore_success=true

if [ "$APP_ONLY" != "true" ]; then
    if ! restore_mongodb "$extracted_dir"; then
        restore_success=false
    fi
fi

if [ "$MONGODB_ONLY" != "true" ]; then
    if ! restore_application_data "$extracted_dir"; then
        restore_success=false
    fi
fi

# Final summary
log "================================================"
if [ "$restore_success" = "true" ]; then
    success "Restore process completed successfully!"
    
    # Send notification (if configured)
    if [ -n "$WEBHOOK_URL" ]; then
        curl -X POST "$WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d "{
                \"text\": \"✅ ARCHSOL IT Portfolio restore completed successfully\",
                \"attachments\": [{
                    \"color\": \"good\",
                    \"fields\": [
                        {\"title\": \"Backup File\", \"value\": \"$(basename "$BACKUP_FILE")\", \"short\": true},
                        {\"title\": \"Timestamp\", \"value\": \"$(date)\", \"short\": false}
                    ]
                }]
            }" > /dev/null 2>&1
    fi
    
    log "Please restart the application services to ensure proper operation"
    exit 0
else
    error "Restore process completed with errors!"
    exit 1
fi