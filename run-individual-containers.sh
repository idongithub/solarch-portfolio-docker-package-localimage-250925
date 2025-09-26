#!/bin/bash

# Individual Container Runner for Kamal Singh Portfolio
# Provides Docker commands for running isolated containers for debugging

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
HTTP_PORT="${HTTP_PORT:-8080}"
HTTPS_PORT="${HTTPS_PORT:-8443}"
BACKEND_PORT="${BACKEND_PORT:-8001}"
MONGO_PORT="${MONGO_PORT:-27017}"
MONGO_EXPRESS_PORT="${MONGO_EXPRESS_PORT:-8081}"

# Network name
NETWORK_NAME="portfolio-network"

# Function to print colored output
print_color() {
    printf "${1}%s${NC}\n" "$2"
}

# Function to create network if it doesn't exist
create_network() {
    if ! docker network inspect $NETWORK_NAME >/dev/null 2>&1; then
        print_color $BLUE "Creating Docker network: $NETWORK_NAME"
        docker network create $NETWORK_NAME
    else
        print_color $GREEN "Network $NETWORK_NAME already exists"
    fi
}

# Function to show usage
show_usage() {
    cat << EOF
${GREEN}Individual Container Runner for Kamal Singh Portfolio${NC}

Usage: $0 [CONTAINER_TYPE] [OPTIONS]

${BLUE}Available Container Types:${NC}
  frontend-http     - Frontend HTTP container (port: $HTTP_PORT)
  frontend-https    - Frontend HTTPS container (port: $HTTPS_PORT)
  backend          - Backend API container (port: $BACKEND_PORT)
  mongodb          - MongoDB database container (port: $MONGO_PORT)
  mongo-express    - MongoDB admin GUI (port: $MONGO_EXPRESS_PORT)
  all              - Run all containers with dependencies

${BLUE}Environment Variables:${NC}
  HTTP_PORT                 Default: 8080
  HTTPS_PORT               Default: 8443
  BACKEND_PORT             Default: 8001
  MONGO_PORT               Default: 27017
  MONGO_EXPRESS_PORT       Default: 8081
  MONGO_DATA_PATH          Default: ./data/mongodb
  SSL_CERT_PATH            Default: ./ssl
  
  # SMTP Configuration
  SMTP_SERVER              Default: smtp.gmail.com
  SMTP_PORT                Default: 587
  SMTP_USE_TLS             Default: true
  SMTP_USERNAME            Required for email
  SMTP_PASSWORD            Required for email
  FROM_EMAIL               Required for email
  TO_EMAIL                 Default: kamal.singh@architecturesolutions.co.uk

${BLUE}Examples:${NC}
  # Run frontend HTTP only
  $0 frontend-http
  
  # Run backend with custom SMTP
  SMTP_USERNAME=myemail@gmail.com SMTP_PASSWORD=mypass $0 backend
  
  # Run MongoDB with custom data path
  MONGO_DATA_PATH=/my/custom/path $0 mongodb
  
  # Run all containers
  $0 all

${BLUE}Individual Docker Commands:${NC}
EOF

    print_color $YELLOW "Frontend HTTP Container:"
    echo "docker run -d --name portfolio-frontend-http --network $NETWORK_NAME -p $HTTP_PORT:80 \\"
    echo "  --restart unless-stopped \\"
    echo "  kamal-portfolio:frontend-http"
    echo ""

    print_color $YELLOW "Frontend HTTPS Container:"
    echo "docker run -d --name portfolio-frontend-https --network $NETWORK_NAME \\"
    echo "  -p $HTTPS_PORT:443 -p 8080:80 \\"
    echo "  -v \${SSL_CERT_PATH:-./ssl}:/etc/nginx/ssl:ro \\"
    echo "  --restart unless-stopped \\"
    echo "  kamal-portfolio:frontend-https"
    echo ""

    print_color $YELLOW "Backend API Container:"
    echo "docker run -d --name portfolio-backend --network $NETWORK_NAME -p $BACKEND_PORT:8001 \\"
    echo "  -e MONGO_URL=mongodb://portfolio-mongodb:27017/portfolio \\"
    echo "  -e SMTP_SERVER=\${SMTP_SERVER:-smtp.gmail.com} \\"
    echo "  -e SMTP_PORT=\${SMTP_PORT:-587} \\"
    echo "  -e SMTP_USE_TLS=\${SMTP_USE_TLS:-true} \\"
    echo "  -e SMTP_USERNAME=\${SMTP_USERNAME} \\"
    echo "  -e SMTP_PASSWORD=\${SMTP_PASSWORD} \\"
    echo "  -e FROM_EMAIL=\${FROM_EMAIL} \\"
    echo "  -e TO_EMAIL=\${TO_EMAIL:-kamal.singh@architecturesolutions.co.uk} \\"
    echo "  --restart unless-stopped \\"
    echo "  kamal-portfolio:backend"
    echo ""

    print_color $YELLOW "MongoDB Container:"
    echo "docker run -d --name portfolio-mongodb --network $NETWORK_NAME -p $MONGO_PORT:27017 \\"
    echo "  -v \${MONGO_DATA_PATH:-./data/mongodb}:/data/db \\"
    echo "  -e MONGO_INITDB_ROOT_USERNAME=admin \\"
    echo "  -e MONGO_INITDB_ROOT_PASSWORD=admin123 \\"
    echo "  --restart unless-stopped \\"
    echo "  mongo:6.0-alpine --quiet"
    echo ""

    print_color $YELLOW "Mongo Express Container:"
    echo "docker run -d --name portfolio-mongo-express --network $NETWORK_NAME -p $MONGO_EXPRESS_PORT:8081 \\"
    echo "  -e ME_CONFIG_MONGODB_SERVER=portfolio-mongodb \\"
    echo "  -e ME_CONFIG_MONGODB_ADMINUSERNAME=admin \\"
    echo "  -e ME_CONFIG_MONGODB_ADMINPASSWORD=admin123 \\"
    echo "  -e ME_CONFIG_BASICAUTH_USERNAME=admin \\"
    echo "  -e ME_CONFIG_BASICAUTH_PASSWORD=admin123 \\"
    echo "  --restart unless-stopped \\"
    echo "  mongo-express:1.0.0-alpha"
}

# Function to build images
build_images() {
    print_color $BLUE "Building optimized Docker images..."
    
    print_color $YELLOW "Building frontend HTTP image..."
    docker build -f Dockerfile.npm.optimized -t kamal-portfolio:frontend-http .
    
    print_color $YELLOW "Building frontend HTTPS image..."  
    docker build -f Dockerfile.https.optimized -t kamal-portfolio:frontend-https .
    
    print_color $YELLOW "Building backend image..."
    docker build -f Dockerfile.backend.optimized -t kamal-portfolio:backend .
    
    print_color $GREEN "All images built successfully!"
}

# Function to run frontend HTTP container
run_frontend_http() {
    print_color $BLUE "Starting Frontend HTTP container..."
    create_network
    
    docker run -d \
        --name portfolio-frontend-http \
        --network $NETWORK_NAME \
        -p $HTTP_PORT:80 \
        --restart unless-stopped \
        kamal-portfolio:frontend-http
        
    print_color $GREEN "Frontend HTTP container started on port $HTTP_PORT"
    print_color $YELLOW "Access at: http://localhost:$HTTP_PORT"
}

# Function to run frontend HTTPS container
run_frontend_https() {
    print_color $BLUE "Starting Frontend HTTPS container..."
    create_network
    
    # Ensure SSL directory exists
    mkdir -p ${SSL_CERT_PATH:-./ssl}
    
    docker run -d \
        --name portfolio-frontend-https \
        --network $NETWORK_NAME \
        -p $HTTPS_PORT:443 \
        -p 8080:80 \
        -v ${SSL_CERT_PATH:-./ssl}:/etc/nginx/ssl:ro \
        --restart unless-stopped \
        kamal-portfolio:frontend-https
        
    print_color $GREEN "Frontend HTTPS container started on port $HTTPS_PORT"
    print_color $YELLOW "Access at: https://localhost:$HTTPS_PORT"
}

# Function to run backend container
run_backend() {
    print_color $BLUE "Starting Backend API container..."
    create_network
    
    # Check for required SMTP variables
    if [[ -z "$SMTP_USERNAME" || -z "$FROM_EMAIL" ]]; then
        print_color $RED "Warning: SMTP_USERNAME and FROM_EMAIL are recommended for email functionality"
    fi
    
    docker run -d \
        --name portfolio-backend \
        --network $NETWORK_NAME \
        -p $BACKEND_PORT:8001 \
        -e MONGO_URL=mongodb://portfolio-mongodb:27017/portfolio \
        -e SMTP_SERVER=${SMTP_SERVER:-smtp.gmail.com} \
        -e SMTP_PORT=${SMTP_PORT:-587} \
        -e SMTP_USE_TLS=${SMTP_USE_TLS:-true} \
        -e SMTP_USE_SSL=${SMTP_USE_SSL:-false} \
        -e SMTP_STARTTLS=${SMTP_STARTTLS:-true} \
        -e SMTP_USERNAME=${SMTP_USERNAME} \
        -e SMTP_PASSWORD=${SMTP_PASSWORD} \
        -e FROM_EMAIL=${FROM_EMAIL} \
        -e TO_EMAIL=${TO_EMAIL:-kamal.singh@architecturesolutions.co.uk} \
        -e SECRET_KEY=${SECRET_KEY:-kamal-singh-portfolio-production-2024} \
        -e CORS_ORIGINS=${CORS_ORIGINS:-http://localhost:3000,http://localhost:8080,https://localhost:8443} \
        --restart unless-stopped \
        kamal-portfolio:backend
        
    print_color $GREEN "Backend API container started on port $BACKEND_PORT"
    print_color $YELLOW "Access at: http://localhost:$BACKEND_PORT/api/"
}

# Function to run MongoDB container
run_mongodb() {
    print_color $BLUE "Starting MongoDB container..."
    create_network
    
    # Ensure data directory exists
    mkdir -p ${MONGO_DATA_PATH:-./data/mongodb}
    
    docker run -d \
        --name portfolio-mongodb \
        --network $NETWORK_NAME \
        -p $MONGO_PORT:27017 \
        -v ${MONGO_DATA_PATH:-./data/mongodb}:/data/db \
        -e MONGO_INITDB_ROOT_USERNAME=${MONGO_ROOT_USERNAME:-admin} \
        -e MONGO_INITDB_ROOT_PASSWORD=${MONGO_ROOT_PASSWORD:-admin123} \
        -e MONGO_INITDB_DATABASE=${MONGO_DATABASE:-portfolio} \
        --restart unless-stopped \
        mongo:6.0-alpine --quiet
        
    print_color $GREEN "MongoDB container started on port $MONGO_PORT"
    print_color $YELLOW "Data persisted to: ${MONGO_DATA_PATH:-./data/mongodb}"
}

# Function to run Mongo Express container
run_mongo_express() {
    print_color $BLUE "Starting Mongo Express container..."
    create_network
    
    docker run -d \
        --name portfolio-mongo-express \
        --network $NETWORK_NAME \
        -p $MONGO_EXPRESS_PORT:8081 \
        -e ME_CONFIG_MONGODB_SERVER=portfolio-mongodb \
        -e ME_CONFIG_MONGODB_PORT=27017 \
        -e ME_CONFIG_MONGODB_ADMINUSERNAME=${MONGO_ROOT_USERNAME:-admin} \
        -e ME_CONFIG_MONGODB_ADMINPASSWORD=${MONGO_ROOT_PASSWORD:-admin123} \
        -e ME_CONFIG_MONGODB_AUTH_DATABASE=admin \
        -e ME_CONFIG_BASICAUTH_USERNAME=${MONGO_EXPRESS_USERNAME:-admin} \
        -e ME_CONFIG_BASICAUTH_PASSWORD=${MONGO_EXPRESS_PASSWORD:-admin123} \
        -e ME_CONFIG_MONGODB_ENABLE_ADMIN=true \
        --restart unless-stopped \
        mongo-express:1.0.0-alpha
        
    print_color $GREEN "Mongo Express container started on port $MONGO_EXPRESS_PORT"
    print_color $YELLOW "Access at: http://localhost:$MONGO_EXPRESS_PORT"
    print_color $YELLOW "Login: admin / admin123"
}

# Function to run all containers with dependencies
run_all() {
    print_color $BLUE "Starting all containers with proper dependencies..."
    
    build_images
    
    # Start database first
    run_mongodb
    sleep 5
    
    # Start backend
    run_backend
    sleep 3
    
    # Start frontend services
    run_frontend_http
    run_frontend_https
    
    # Start admin interface
    run_mongo_express
    
    print_color $GREEN "All containers started successfully!"
    print_color $YELLOW "Services available at:"
    print_color $YELLOW "  HTTP:         http://localhost:$HTTP_PORT"
    print_color $YELLOW "  HTTPS:        https://localhost:$HTTPS_PORT"
    print_color $YELLOW "  Backend API:  http://localhost:$BACKEND_PORT/api/"
    print_color $YELLOW "  MongoDB:      mongodb://localhost:$MONGO_PORT"
    print_color $YELLOW "  Mongo Admin:  http://localhost:$MONGO_EXPRESS_PORT"
}

# Function to clean up containers
cleanup() {
    print_color $BLUE "Cleaning up existing containers..."
    docker rm -f portfolio-frontend-http portfolio-frontend-https portfolio-backend portfolio-mongodb portfolio-mongo-express 2>/dev/null || true
}

# Main script logic
case "${1:-help}" in
    frontend-http)
        cleanup
        build_images
        run_frontend_http
        ;;
    frontend-https)
        cleanup
        build_images
        run_frontend_https
        ;;
    backend)
        cleanup
        build_images
        run_backend
        ;;
    mongodb)
        cleanup
        run_mongodb
        ;;
    mongo-express)
        cleanup
        run_mongo_express
        ;;
    all)
        cleanup
        run_all
        ;;
    clean)
        cleanup
        print_color $GREEN "Cleanup completed"
        ;;
    help|--help|-h|*)
        show_usage
        ;;
esac