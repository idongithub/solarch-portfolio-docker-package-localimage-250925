#!/bin/bash

# Docker entrypoint script for Kamal Singh Portfolio
# Handles initialization and service startup

set -e

echo "=============================================="
echo "Kamal Singh Portfolio - Docker Initialization"
echo "=============================================="

# Function to wait for service
wait_for_service() {
    local host=$1
    local port=$2
    local service=$3
    local timeout=${4:-60}
    
    echo "⏳ Waiting for $service at $host:$port..."
    
    for i in $(seq 1 $timeout); do
        if nc -z "$host" "$port" 2>/dev/null; then
            echo "✅ $service is ready!"
            return 0
        fi
        echo "⏳ Waiting for $service... ($i/$timeout)"
        sleep 1
    done
    
    echo "❌ Timeout waiting for $service"
    return 1
}

# Function to initialize database
init_database() {
    echo "🗄️ Initializing MongoDB database..."
    
    # Wait for MongoDB to be ready
    wait_for_service mongodb 27017 "MongoDB" 120
    
    # Run database initialization script
    if [ -f "/app/init_database.js" ]; then
        echo "📊 Running database initialization script..."
        mongosh "mongodb://${MONGO_ROOT_USERNAME}:${MONGO_ROOT_PASSWORD}@mongodb:27017/${DB_NAME}?authSource=admin" --file /app/init_database.js
        echo "✅ Database initialization completed"
    else
        echo "⚠️ Database initialization script not found"
    fi
}

# Function to validate environment
validate_environment() {
    echo "🔍 Validating environment configuration..."
    
    local errors=0
    
    # Check required environment variables
    if [ -z "$MONGO_ROOT_USERNAME" ]; then
        echo "❌ MONGO_ROOT_USERNAME is not set"
        errors=$((errors + 1))
    fi
    
    if [ -z "$MONGO_ROOT_PASSWORD" ]; then
        echo "❌ MONGO_ROOT_PASSWORD is not set"
        errors=$((errors + 1))
    fi
    
    if [ -z "$SMTP_USERNAME" ]; then
        echo "⚠️ SMTP_USERNAME is not set - email functionality will be disabled"
    fi
    
    if [ -z "$SMTP_PASSWORD" ]; then
        echo "⚠️ SMTP_PASSWORD is not set - email functionality will be disabled"
    fi
    
    if [ $errors -gt 0 ]; then
        echo "❌ Environment validation failed with $errors errors"
        exit 1
    fi
    
    echo "✅ Environment validation passed"
}

# Function to show configuration summary
show_config() {
    echo "📋 Configuration Summary:"
    echo "  Database: ${DB_NAME}"
    echo "  Backend Port: ${BACKEND_PORT:-8001}"
    echo "  Frontend Port: ${FRONTEND_PORT:-3000}"
    echo "  Environment: ${ENVIRONMENT:-production}"
    echo "  Email Service: ${SMTP_SERVER:-not configured}"
    echo "  Website URL: ${WEBSITE_URL:-http://localhost:3000}"
}

# Main initialization
main() {
    echo "🚀 Starting Kamal Singh Portfolio initialization..."
    
    # Validate environment
    validate_environment
    
    # Show configuration
    show_config
    
    # Initialize database if this is the backend container
    if [ "$1" = "init-db" ]; then
        init_database
        exit 0
    fi
    
    echo "✅ Initialization completed successfully!"
    echo ""
    
    # Execute the main command
    exec "$@"
}

# Run main function with all arguments
main "$@"