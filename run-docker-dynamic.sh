#!/bin/bash

# Dynamic Docker Deployment Script for Kamal Singh Portfolio
# Supports command-line parameters for SMTP and ports without .env files

set -e

# Default values
HTTP_PORT=8080
HTTPS_PORT=8443
BACKEND_PORT=8001
MONGO_PORT=27017

# SMTP Server Configuration
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT=587
SMTP_USE_TLS="true"
SMTP_USE_SSL="false"
SMTP_STARTTLS="true"
SMTP_TIMEOUT=30
SMTP_RETRIES=3
SMTP_DEBUG="false"
SMTP_VERIFY_CERT="true"
SMTP_LOCAL_HOSTNAME=""
SMTP_AUTH="true"

# SMTP Credentials
SMTP_USERNAME=""
SMTP_PASSWORD=""
FROM_EMAIL=""
TO_EMAIL="kamal.singh@architecturesolutions.co.uk"
REPLY_TO_EMAIL=""
CC_EMAIL=""
BCC_EMAIL=""

# Email Content
EMAIL_SUBJECT_PREFIX="[Portfolio Contact]"
EMAIL_TEMPLATE="default"
EMAIL_CHARSET="utf-8"

# Security
EMAIL_RATE_LIMIT_MAX=10
EMAIL_COOLDOWN_PERIOD=60

DEPLOYMENT_TYPE="http"
CONTAINER_NAME="kamal-portfolio"

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Deployment Options:"
    echo "  --type TYPE              Deployment type: http, https, both, fullstack, fullstack-https, fullstack-both"
    echo "  --name NAME              Container name (default: kamal-portfolio)"
    echo ""
    echo "Port Options:"
    echo "  --http-port PORT         HTTP port (default: 8080)"
    echo "  --https-port PORT        HTTPS port (default: 8443)"
    echo "  --backend-port PORT      Backend port (default: 8001)"
    echo "  --mongo-port PORT        MongoDB port (default: 27017)"
    echo ""
    echo "SMTP Options:"
    echo "  --smtp-server SERVER     SMTP server hostname (default: smtp.gmail.com)"
    echo "  --smtp-port PORT         SMTP port (default: 587)"
    echo "  --smtp-use-tls BOOL      Use TLS encryption (default: true)"
    echo "  --smtp-use-ssl BOOL      Use SSL encryption (default: false)"
    echo "  --smtp-starttls BOOL     Use STARTTLS (default: true)"
    echo "  --smtp-timeout SEC       Connection timeout (default: 30)"
    echo "  --smtp-retries NUM       Retry attempts (default: 3)"
    echo "  --smtp-debug BOOL        Enable debug logging (default: false)"
    echo "  --smtp-verify-cert BOOL  Verify SSL certificates (default: true)"
    echo "  --smtp-local-hostname    Local hostname for SMTP"
    echo "  --smtp-auth BOOL         Use SMTP authentication (default: true)"
    echo "  --smtp-username EMAIL    SMTP username/email"
    echo "  --smtp-password PASS     SMTP password/app-password"
    echo "  --from-email EMAIL       From email address"
    echo "  --to-email EMAIL         To email address (default: kamal.singh@architecturesolutions.co.uk)"
    echo "  --reply-to-email EMAIL   Reply-to email address"
    echo "  --cc-email EMAIL         CC email address"
    echo "  --bcc-email EMAIL        BCC email address"
    echo ""
    echo "Email Content Options:"
    echo "  --email-subject-prefix   Subject prefix (default: [Portfolio Contact])"
    echo "  --email-template NAME    Email template (default: default)"
    echo "  --email-charset CHARSET  Email charset (default: utf-8)"
    echo "  --email-rate-limit NUM   Max emails per window (default: 10)"
    echo "  --email-cooldown SEC     Cooldown period (default: 60)"
    echo ""
    echo "Examples:"
    echo "  # HTTP deployment on custom port"
    echo "  $0 --type http --http-port 3000"
    echo ""
    echo "  # HTTPS deployment with Gmail SMTP"
    echo "  $0 --type https --smtp-username you@gmail.com --smtp-password your-app-password"
    echo ""
    echo "  # HTTP and HTTPS simultaneously"
    echo "  $0 --type both --http-port 8080 --https-port 8443"
    echo ""
    echo "  # Full-stack with custom SMTP server"
    echo "  $0 --type fullstack --smtp-server mail.company.com --smtp-username no-reply@company.com"
    echo ""
    echo "  # Full-stack with both HTTP and HTTPS"
    echo "  $0 --type fullstack-both --smtp-username you@gmail.com --smtp-password your-password"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --type)
            DEPLOYMENT_TYPE="$2"
            shift 2
            ;;
        --name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        --http-port)
            HTTP_PORT="$2"
            shift 2
            ;;
        --https-port)
            HTTPS_PORT="$2"
            shift 2
            ;;
        --backend-port)
            BACKEND_PORT="$2"
            shift 2
            ;;
        --mongo-port)
            MONGO_PORT="$2"
            shift 2
            ;;
        --smtp-server)
            SMTP_SERVER="$2"
            shift 2
            ;;
        --smtp-port)
            SMTP_PORT="$2"
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
        --smtp-auth)
            SMTP_AUTH="$2"
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
        --from-email)
            FROM_EMAIL="$2"
            shift 2
            ;;
        --to-email)
            TO_EMAIL="$2"
            shift 2
            ;;
        --reply-to-email)
            REPLY_TO_EMAIL="$2"
            shift 2
            ;;
        --cc-email)
            CC_EMAIL="$2"
            shift 2
            ;;
        --bcc-email)
            BCC_EMAIL="$2"
            shift 2
            ;;
        --email-subject-prefix)
            EMAIL_SUBJECT_PREFIX="$2"
            shift 2
            ;;
        --email-template)
            EMAIL_TEMPLATE="$2"
            shift 2
            ;;
        --email-charset)
            EMAIL_CHARSET="$2"
            shift 2
            ;;
        --email-rate-limit)
            EMAIL_RATE_LIMIT_MAX="$2"
            shift 2
            ;;
        --email-cooldown)
            EMAIL_COOLDOWN_PERIOD="$2"
            shift 2
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Set default FROM_EMAIL if not provided
if [ -z "$FROM_EMAIL" ] && [ -n "$SMTP_USERNAME" ]; then
    FROM_EMAIL="$SMTP_USERNAME"
fi

echo "=================================================="
echo "Dynamic Docker Deployment - Kamal Singh Portfolio"
echo "=================================================="
echo "Deployment Type: $DEPLOYMENT_TYPE"
echo "Container Name: $CONTAINER_NAME"
echo "HTTP Port: $HTTP_PORT"
echo "HTTPS Port: $HTTPS_PORT"
echo "Backend Port: $BACKEND_PORT"
echo "MongoDB Port: $MONGO_PORT"
echo "SMTP Server: $SMTP_SERVER:$SMTP_PORT"
echo "SMTP Username: $SMTP_USERNAME"
echo "From Email: $FROM_EMAIL"
echo "To Email: $TO_EMAIL"
echo "=================================================="

# Cleanup existing container
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

case $DEPLOYMENT_TYPE in
    "http")
        echo "Deploying HTTP frontend-only..."
        
        # Build if needed
        docker build --no-cache -f Dockerfile.npm -t kamal-portfolio:npm . || exit 1
        
        # Run HTTP container
        docker run -d \
            --name "$CONTAINER_NAME" \
            --restart unless-stopped \
            -p "$HTTP_PORT:80" \
            kamal-portfolio:npm
        
        echo "✅ HTTP deployment successful!"
        echo "🌐 Access: http://localhost:$HTTP_PORT"
        ;;
        
    "https")
        echo "Deploying HTTPS frontend-only..."
        
        # Check SSL certificates
        if [ ! -f "./ssl/portfolio.crt" ] || [ ! -f "./ssl/portfolio.key" ]; then
            echo "⚠️  SSL certificates not found. Generating self-signed certificates..."
            mkdir -p ssl
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout ssl/portfolio.key \
                -out ssl/portfolio.crt \
                -subj "/C=UK/ST=London/L=London/O=ARCHSOL IT Solutions/CN=localhost"
        fi
        
        # Build if needed
        docker build --no-cache -f Dockerfile.https -t kamal-portfolio:https . || exit 1
        
        # Run HTTPS container
        docker run -d \
            --name "$CONTAINER_NAME" \
            --restart unless-stopped \
            -p "$HTTP_PORT:80" \
            -p "$HTTPS_PORT:443" \
            -v "$(pwd)/ssl:/etc/nginx/ssl:ro" \
            kamal-portfolio:https
        
        echo "✅ HTTPS deployment successful!"
        echo "🔓 HTTP (redirects): http://localhost:$HTTP_PORT"
        echo "🔒 HTTPS: https://localhost:$HTTPS_PORT"
        ;;
        
    "both")
        echo "Deploying HTTP and HTTPS simultaneously..."
        
        # Check SSL certificates
        if [ ! -f "./ssl/portfolio.crt" ] || [ ! -f "./ssl/portfolio.key" ]; then
            echo "⚠️  SSL certificates not found. Generating self-signed certificates..."
            mkdir -p ssl
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout ssl/portfolio.key \
                -out ssl/portfolio.crt \
                -subj "/C=UK/ST=London/L=London/O=ARCHSOL IT Solutions/CN=localhost"
        fi
        
        # Build both images if needed
        echo "Building HTTP frontend image..."
        docker build --no-cache -f Dockerfile.npm -t kamal-portfolio:npm . || exit 1
        
        echo "Building HTTPS frontend image..."
        docker build --no-cache -f Dockerfile.https -t kamal-portfolio:https . || exit 1
        
        # Run HTTP container
        echo "Starting HTTP container..."
        docker run -d \
            --name "$CONTAINER_NAME-http" \
            --restart unless-stopped \
            -p "$HTTP_PORT:80" \
            kamal-portfolio:npm
        
        # Run HTTPS container
        echo "Starting HTTPS container..."
        docker run -d \
            --name "$CONTAINER_NAME-https" \
            --restart unless-stopped \
            -p "$HTTPS_PORT:443" \
            -v "$(pwd)/ssl:/etc/nginx/ssl:ro" \
            kamal-portfolio:https
        
        echo "✅ HTTP and HTTPS deployment successful!"
        echo "🔓 HTTP: http://localhost:$HTTP_PORT"
        echo "🔒 HTTPS: https://localhost:$HTTPS_PORT"
        echo "📝 Note: Both HTTP and HTTPS are running simultaneously on separate containers"
        ;;
        
    "fullstack"|"fullstack-https"|"fullstack-both")
        echo "Deploying full-stack with SMTP..."
        
        # Validate SMTP settings
        if [ -z "$SMTP_USERNAME" ] || [ -z "$SMTP_PASSWORD" ]; then
            echo "❌ ERROR: SMTP username and password are required for full-stack deployment"
            echo "Use: --smtp-username your@email.com --smtp-password your-password"
            exit 1
        fi
        
        # Handle HTTPS certificates for fullstack-https and fullstack-both
        if [[ "$DEPLOYMENT_TYPE" =~ "https" ]] || [ "$DEPLOYMENT_TYPE" = "fullstack-both" ]; then
            if [ ! -f "./ssl/portfolio.crt" ] || [ ! -f "./ssl/portfolio.key" ]; then
                echo "⚠️  SSL certificates not found. Generating self-signed certificates..."
                mkdir -p ssl
                openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                    -keyout ssl/portfolio.key \
                    -out ssl/portfolio.crt \
                    -subj "/C=UK/ST=London/L=London/O=ARCHSOL IT Solutions/CN=localhost"
            fi
        fi
        
        # Build images
        echo "Building backend image..."
        docker build --no-cache -f Dockerfile.backend -t kamal-portfolio:backend . || exit 1
        
        if [ "$DEPLOYMENT_TYPE" = "fullstack-both" ]; then
            echo "Building HTTP frontend image..."
            docker build --no-cache -f Dockerfile.npm -t kamal-portfolio:npm . || exit 1
            echo "Building HTTPS frontend image..."
            docker build --no-cache -f Dockerfile.https -t kamal-portfolio:https . || exit 1
        elif [ "$DEPLOYMENT_TYPE" = "fullstack-https" ]; then
            echo "Building HTTPS frontend image..."
            docker build --no-cache -f Dockerfile.https -t kamal-portfolio:https . || exit 1
        else
            echo "Building HTTP frontend image..."  
            docker build --no-cache -f Dockerfile.npm -t kamal-portfolio:npm . || exit 1
        fi
        
        # Create network
        docker network create kamal-portfolio-network 2>/dev/null || true
        
        # Start MongoDB
        echo "Starting MongoDB..."
        docker run -d \
            --name "$CONTAINER_NAME-mongo" \
            --restart unless-stopped \
            --network kamal-portfolio-network \
            -p "$MONGO_PORT:27017" \
            -e MONGO_INITDB_DATABASE=portfolio_db \
            mongo:6.0
        
        # Wait for MongoDB
        sleep 10
        
        # Start Backend
        echo "Starting Backend with complete SMTP configuration..."
        docker run -d \
            --name "$CONTAINER_NAME-backend" \
            --restart unless-stopped \
            --network kamal-portfolio-network \
            -p "$BACKEND_PORT:8001" \
            -e MONGO_URL="mongodb://$CONTAINER_NAME-mongo:27017" \
            -e SMTP_SERVER="$SMTP_SERVER" \
            -e SMTP_PORT="$SMTP_PORT" \
            -e SMTP_USE_TLS="$SMTP_USE_TLS" \
            -e SMTP_USE_SSL="$SMTP_USE_SSL" \
            -e SMTP_STARTTLS="$SMTP_STARTTLS" \
            -e SMTP_TIMEOUT="$SMTP_TIMEOUT" \
            -e SMTP_RETRIES="$SMTP_RETRIES" \
            -e SMTP_DEBUG="$SMTP_DEBUG" \
            -e SMTP_VERIFY_CERT="$SMTP_VERIFY_CERT" \
            -e SMTP_LOCAL_HOSTNAME="$SMTP_LOCAL_HOSTNAME" \
            -e SMTP_AUTH="$SMTP_AUTH" \
            -e SMTP_USERNAME="$SMTP_USERNAME" \
            -e SMTP_PASSWORD="$SMTP_PASSWORD" \
            -e FROM_EMAIL="$FROM_EMAIL" \
            -e TO_EMAIL="$TO_EMAIL" \
            -e REPLY_TO_EMAIL="$REPLY_TO_EMAIL" \
            -e CC_EMAIL="$CC_EMAIL" \
            -e BCC_EMAIL="$BCC_EMAIL" \
            -e EMAIL_SUBJECT_PREFIX="$EMAIL_SUBJECT_PREFIX" \
            -e EMAIL_TEMPLATE="$EMAIL_TEMPLATE" \
            -e EMAIL_CHARSET="$EMAIL_CHARSET" \
            -e EMAIL_RATE_LIMIT_MAX="$EMAIL_RATE_LIMIT_MAX" \
            -e EMAIL_COOLDOWN_PERIOD="$EMAIL_COOLDOWN_PERIOD" \
            -e SECRET_KEY="kamal-singh-portfolio-production-$(date +%s)" \
            -e CORS_ORIGINS="http://localhost:$HTTP_PORT,https://localhost:$HTTPS_PORT" \
            kamal-portfolio:backend
        
        # Wait for backend
        sleep 15
        
        # Start Frontend
        echo "Starting Frontend..."
        if [ "$DEPLOYMENT_TYPE" = "fullstack-both" ]; then
            # Deploy both HTTP and HTTPS frontends for fullstack-both
            echo "Starting HTTP frontend..."
            docker run -d \
                --name "$CONTAINER_NAME-frontend-http" \
                --restart unless-stopped \
                --network kamal-portfolio-network \
                -p "$HTTP_PORT:80" \
                kamal-portfolio:npm
            
            echo "Starting HTTPS frontend..."
            docker run -d \
                --name "$CONTAINER_NAME-frontend-https" \
                --restart unless-stopped \
                --network kamal-portfolio-network \
                -p "$HTTPS_PORT:443" \
                -v "$(pwd)/ssl:/etc/nginx/ssl:ro" \
                kamal-portfolio:https
        elif [ "$DEPLOYMENT_TYPE" = "fullstack-https" ]; then
            docker run -d \
                --name "$CONTAINER_NAME-frontend" \
                --restart unless-stopped \
                --network kamal-portfolio-network \
                -p "$HTTP_PORT:80" \
                -p "$HTTPS_PORT:443" \
                -v "$(pwd)/ssl:/etc/nginx/ssl:ro" \
                kamal-portfolio:https
        else
            docker run -d \
                --name "$CONTAINER_NAME-frontend" \
                --restart unless-stopped \
                --network kamal-portfolio-network \
                -p "$HTTP_PORT:80" \
                kamal-portfolio:npm
        fi
        
        echo "✅ Full-stack deployment successful!"
        if [ "$DEPLOYMENT_TYPE" = "fullstack-both" ]; then
            echo "🔓 HTTP Frontend: http://localhost:$HTTP_PORT"
            echo "🔒 HTTPS Frontend: https://localhost:$HTTPS_PORT"
            echo "📝 Note: Both HTTP and HTTPS frontends running simultaneously"
        elif [ "$DEPLOYMENT_TYPE" = "fullstack-https" ]; then
            echo "🔓 HTTP (redirects): http://localhost:$HTTP_PORT"
            echo "🔒 HTTPS Frontend: https://localhost:$HTTPS_PORT"
        else
            echo "🌐 Frontend: http://localhost:$HTTP_PORT"
        fi
        echo "🔧 Backend API: http://localhost:$BACKEND_PORT/api"
        echo "🗄️  MongoDB: localhost:$MONGO_PORT"
        echo "📧 SMTP configured with: $SMTP_USERNAME → $TO_EMAIL"
        ;;
        
    *)
        echo "❌ ERROR: Unknown deployment type: $DEPLOYMENT_TYPE"
        echo "Valid types: http, https, both, fullstack, fullstack-https, fullstack-both"
        show_usage
        exit 1
        ;;
esac

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "Container Management:"

if [ "$DEPLOYMENT_TYPE" = "both" ]; then
    echo "  View status: docker ps"
    echo "  View HTTP logs: docker logs $CONTAINER_NAME-http"
    echo "  View HTTPS logs: docker logs $CONTAINER_NAME-https"
    echo "  Stop HTTP: docker stop $CONTAINER_NAME-http"
    echo "  Stop HTTPS: docker stop $CONTAINER_NAME-https"
    echo "  Stop both: docker stop $CONTAINER_NAME-http $CONTAINER_NAME-https"
    echo "  Remove both: docker rm $CONTAINER_NAME-http $CONTAINER_NAME-https"
elif [[ "$DEPLOYMENT_TYPE" =~ "fullstack" ]]; then
    echo "  View status: docker ps"
    if [ "$DEPLOYMENT_TYPE" = "fullstack-both" ]; then
        echo "  View frontend HTTP logs: docker logs $CONTAINER_NAME-frontend-http"
        echo "  View frontend HTTPS logs: docker logs $CONTAINER_NAME-frontend-https"
        echo "  View backend logs: docker logs $CONTAINER_NAME-backend"
        echo "  View MongoDB logs: docker logs $CONTAINER_NAME-mongo"
        echo ""
        echo "Full-stack Management:"
        echo "  Stop all: docker stop $CONTAINER_NAME-frontend-http $CONTAINER_NAME-frontend-https $CONTAINER_NAME-backend $CONTAINER_NAME-mongo"
        echo "  Remove all: docker rm $CONTAINER_NAME-frontend-http $CONTAINER_NAME-frontend-https $CONTAINER_NAME-backend $CONTAINER_NAME-mongo"
    else
        echo "  View frontend logs: docker logs $CONTAINER_NAME-frontend"
        echo "  View backend logs: docker logs $CONTAINER_NAME-backend"
        echo "  View MongoDB logs: docker logs $CONTAINER_NAME-mongo"
        echo ""
        echo "Full-stack Management:"
        echo "  Stop all: docker stop $CONTAINER_NAME-frontend $CONTAINER_NAME-backend $CONTAINER_NAME-mongo"
        echo "  Remove all: docker rm $CONTAINER_NAME-frontend $CONTAINER_NAME-backend $CONTAINER_NAME-mongo"
    fi
    echo "  Remove network: docker network rm kamal-portfolio-network"
else
    echo "  View status: docker ps"
    echo "  View logs: docker logs $CONTAINER_NAME"
    echo "  Stop: docker stop $CONTAINER_NAME"
    echo "  Remove: docker rm $CONTAINER_NAME"
fi