#!/bin/bash

# SSL Certificate Generation Script for Kamal Singh Portfolio
# Creates development and production-ready SSL certificates

set -e

echo "========================================"
echo "SSL Certificate Generator"
echo "Kamal Singh IT Portfolio"
echo "========================================"

# Create SSL directory
mkdir -p ssl

# Function to generate self-signed certificate
generate_self_signed() {
    local domain=${1:-localhost}
    echo "Generating self-signed certificate for: $domain"
    
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ssl/portfolio.key \
        -out ssl/portfolio.crt \
        -subj "/C=UK/ST=London/L=London/O=ARCHSOL IT Solutions/OU=IT Portfolio/CN=$domain/emailAddress=kamal.singh@architecturesolutions.co.uk"
    
    echo "✅ Self-signed certificate generated successfully!"
}

# Function to generate CSR for production
generate_csr() {
    local domain=${1:-portfolio.architecturesolutions.co.uk}
    echo "Generating Certificate Signing Request (CSR) for: $domain"
    
    # Generate private key
    openssl genrsa -out ssl/portfolio.key 2048
    
    # Generate CSR
    openssl req -new -key ssl/portfolio.key -out ssl/portfolio.csr \
        -subj "/C=UK/ST=London/L=London/O=ARCHSOL IT Solutions/OU=IT Portfolio/CN=$domain/emailAddress=kamal.singh@architecturesolutions.co.uk"
    
    echo "✅ CSR generated successfully!"
    echo "📄 Send ssl/portfolio.csr to your Certificate Authority"
    echo "🔐 Keep ssl/portfolio.key secure and private"
}

# Main menu
echo "Choose certificate type:"
echo "1) Self-signed certificate (for development/testing)"
echo "2) CSR for production certificate"
echo "3) Custom domain self-signed certificate"
echo ""
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        generate_self_signed "localhost"
        echo ""
        echo "🎯 Usage with Docker:"
        echo "   ./build-docker-https.sh"
        echo "   Access: https://localhost:8443"
        echo ""
        echo "⚠️  Browser will show security warning (normal for self-signed)"
        ;;
    2)
        read -p "Enter your domain name: " domain
        generate_csr "$domain"
        echo ""
        echo "📋 Next steps:"
        echo "1. Send ssl/portfolio.csr to your Certificate Authority"
        echo "2. Receive portfolio.crt from your CA"
        echo "3. Place portfolio.crt in ssl/ directory"
        echo "4. Run: ./build-docker-https.sh"
        ;;
    3)
        read -p "Enter your domain name: " domain
        generate_self_signed "$domain"
        echo ""
        echo "🎯 Usage with Docker:"
        echo "   ./build-docker-https.sh"
        echo "   Access: https://$domain:8443"
        echo ""
        echo "⚠️  Browser will show security warning (normal for self-signed)"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Set proper permissions
chmod 600 ssl/portfolio.key 2>/dev/null || true
chmod 644 ssl/portfolio.crt 2>/dev/null || true
chmod 644 ssl/portfolio.csr 2>/dev/null || true

echo ""
echo "📁 SSL files created in ./ssl/ directory"
ls -la ssl/

echo ""
echo "🔒 Security Notes:"
echo "- Keep portfolio.key private and secure"
echo "- Never commit private keys to version control"
echo "- For production, use certificates from trusted CA"
echo "- Regularly renew certificates before expiration"