#!/bin/bash

# Deploy Portfolio with Domain Configuration for architecturesolutions.co.uk
# Enhanced deployment script for DNS-based Traefik integration with custom ports

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values aligned with your setup
HTTP_PORT=3400
HTTPS_PORT=3443
BACKEND_PORT=3001
DOMAIN=""
TRAEFIK_SERVER_IP="192.168.86.56"  # Your Traefik server IP
DRY_RUN=false

# Function to display usage
show_usage() {
    cat << EOF

🌐 Portfolio Deployment with architecturesolutions.co.uk Domain

USAGE:
    $0 --domain SUBDOMAIN [OPTIONS]

REQUIRED PARAMETERS:
    --domain SUBDOMAIN          Subdomain for architecturesolutions.co.uk 
                               (e.g., portfolio for portfolio.architecturesolutions.co.uk)

OPTIONAL PARAMETERS:
    --traefik-ip IP             Traefik server IP (default: 192.168.86.56)
    --http-port PORT            HTTP port (default: 3400)
    --https-port PORT           HTTPS port (default: 3443)  
    --backend-port PORT         Backend port (default: 3001)
    --mongo-password PASS       MongoDB password (REQUIRED)
    --grafana-password PASS     Grafana password (REQUIRED)
    --smtp-server HOST          SMTP server (default: smtp.ionos.co.uk)
    --smtp-port PORT            SMTP port (default: 465)
    --smtp-username EMAIL       SMTP username
    --smtp-password PASS        SMTP password
    --dry-run                   Show configuration without deploying

EXAMPLES:
    # Deploy portfolio subdomain
    $0 --domain portfolio \\
       --mongo-password securepass123 --grafana-password admin123

    # Full deployment with your SMTP settings
    $0 --domain portfolio \\
       --smtp-server smtp.ionos.co.uk --smtp-port 465 \\
       --smtp-username kamal.singh@architecturesolutions.co.uk \\
       --smtp-password NewPass6 --smtp-use-tls true \\
       --mongo-password securepass123 --grafana-password admin123

    # Custom Traefik IP
    $0 --domain portfolio --traefik-ip 192.168.1.100 \\
       --mongo-password securepass123 --grafana-password admin123

NOTES:
    - Domain will be: SUBDOMAIN.architecturesolutions.co.uk
    - Traefik runs on custom ports: HTTP 81, HTTPS 434
    - SSL termination at Traefik using existing wildcard certificate
    - Backend URLs will point to full domain (https://SUBDOMAIN.architecturesolutions.co.uk)

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --domain)
            DOMAIN="$2.architecturesolutions.co.uk"
            shift 2
            ;;
        --traefik-ip)
            TRAEFIK_SERVER_IP="$2"
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
        --mongo-password)
            MONGO_PASSWORD="$2"
            shift 2
            ;;
        --grafana-password)
            GRAFANA_PASSWORD="$2"
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
        --smtp-username)
            SMTP_USERNAME="$2"
            shift 2
            ;;
        --smtp-password)
            SMTP_PASSWORD="$2"
            shift 2
            ;;
        --smtp-use-tls)
            SMTP_USE_TLS="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown parameter: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$DOMAIN" || "$DOMAIN" == ".architecturesolutions.co.uk" ]]; then
    echo -e "${RED}Error: Domain subdomain is required${NC}"
    echo "Example: --domain portfolio (creates portfolio.architecturesolutions.co.uk)"
    show_usage
    exit 1
fi

if [[ -z "$MONGO_PASSWORD" ]]; then
    echo -e "${RED}Error: MongoDB password is required${NC}"
    show_usage
    exit 1
fi

if [[ -z "$GRAFANA_PASSWORD" ]]; then
    echo -e "${RED}Error: Grafana password is required${NC}"
    show_usage
    exit 1
fi

echo -e "${BLUE}🌐 Portfolio Domain Deployment Configuration${NC}"
echo "=================================================="
echo -e "Full Domain: ${GREEN}$DOMAIN${NC}"
echo -e "Traefik Server: ${GREEN}$TRAEFIK_SERVER_IP${NC} (ports 81/434)"
echo -e "HTTP Port: ${GREEN}$HTTP_PORT${NC}"
echo -e "HTTPS Port: ${GREEN}$HTTPS_PORT${NC}"
echo -e "Backend Port: ${GREEN}$BACKEND_PORT${NC}"
echo -e "SSL Termination: ${GREEN}At Traefik (wildcard cert)${NC}"
echo "=================================================="

if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}DRY RUN MODE - No actual deployment${NC}"
    exit 0
fi

# Generate frontend .env with domain
echo -e "${BLUE}🌐 Generating frontend .env with domain...${NC}"
cat > ./frontend/.env << EOF
REACT_APP_BACKEND_URL=https://$DOMAIN
WDS_SOCKET_PORT=443
EOF

# Update Traefik dynamic configuration (TOML format)
echo -e "${BLUE}🔧 Updating Traefik TOML configuration...${NC}"
sed -i "s/192.168.86.56/$TRAEFIK_SERVER_IP/g" ./traefik/dynamic.toml
sed -i "s/portfolio.architecturesolutions.co.uk/$DOMAIN/g" ./traefik/dynamic.toml

# Update backend CORS origins for domain
echo -e "${BLUE}🔧 Updating backend CORS for domain...${NC}"
if grep -q "CORS_ORIGINS=" ./backend/.env; then
    sed -i "s|CORS_ORIGINS=.*|CORS_ORIGINS=https://$DOMAIN,http://localhost:$HTTP_PORT,https://localhost:$HTTPS_PORT|g" ./backend/.env
else
    echo "CORS_ORIGINS=https://$DOMAIN,http://localhost:$HTTP_PORT,https://localhost:$HTTPS_PORT" >> ./backend/.env
fi

# Deploy with original deploy script
echo -e "${BLUE}🚀 Starting deployment...${NC}"
./scripts/deploy-with-params.sh \
  --http-port $HTTP_PORT \
  --https-port $HTTPS_PORT \
  --backend-port $BACKEND_PORT \
  --mongo-password "$MONGO_PASSWORD" \
  --grafana-password "$GRAFANA_PASSWORD" \
  ${SMTP_SERVER:+--smtp-server "$SMTP_SERVER"} \
  ${SMTP_PORT:+--smtp-port "$SMTP_PORT"} \
  ${SMTP_USERNAME:+--smtp-username "$SMTP_USERNAME"} \
  ${SMTP_PASSWORD:+--smtp-password "$SMTP_PASSWORD"} \
  ${SMTP_USE_TLS:+--smtp-use-tls "$SMTP_USE_TLS"} \
  --skip-backup

echo -e "${GREEN}✅ Domain deployment completed!${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps for Traefik Integration:${NC}"
echo "1. Copy the following content to your Traefik configuration:"
echo ""
echo -e "${YELLOW}📝 Add to your traefik.toml:${NC}"
echo "   (See ./traefik/traefik.toml for entryPoints configuration)"
echo ""
echo -e "${YELLOW}📝 Add to your dynamic.toml:${NC}"
echo "   (See ./traefik/dynamic.toml for routing rules)"
echo ""
echo "2. Restart your Traefik binary to load new configuration"
echo "3. Verify DNS: $DOMAIN should point to your public IP"
echo "4. Access your portfolio at: https://$DOMAIN"
echo ""
echo -e "${BLUE}🔍 Verification Commands:${NC}"
echo "curl -I https://$DOMAIN"
echo "curl https://$DOMAIN/api/health"
echo ""
echo -e "${YELLOW}⚠️  Notes:${NC}"
echo "- Traefik uses custom ports: 81 (HTTP) → 434 (HTTPS)"
echo "- SSL termination at Traefik using existing wildcard certificate"
echo "- Backend CORS updated to allow: https://$DOMAIN"