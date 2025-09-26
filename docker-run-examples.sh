#!/bin/bash

# Docker Run Examples for Kamal Singh Portfolio
# Direct docker run commands with dynamic parameters

echo "========================================"
echo "Docker Run Examples - Dynamic Parameters"
echo "========================================"

echo ""
echo "1. BASIC HTTP DEPLOYMENT"
echo "========================"
echo "# Simple HTTP deployment on default port 8080"
echo 'docker run -d --name kamal-portfolio -p 8080:80 kamal-portfolio:npm'
echo ""
echo "# HTTP deployment on custom port 3000"
echo 'docker run -d --name kamal-portfolio -p 3000:80 kamal-portfolio:npm'

echo ""
echo "2. HTTPS DEPLOYMENT"
echo "==================="
echo "# HTTPS deployment with self-signed certificates"
echo 'docker run -d --name kamal-portfolio-https \'
echo '  -p 8080:80 -p 8443:443 \'
echo '  -v $(pwd)/ssl:/etc/nginx/ssl:ro \'
echo '  kamal-portfolio:https'
echo ""
echo "# HTTPS on custom ports"
echo 'docker run -d --name kamal-portfolio-https \'
echo '  -p 3000:80 -p 3443:443 \'
echo '  -v $(pwd)/ssl:/etc/nginx/ssl:ro \'
echo '  kamal-portfolio:https'

echo ""
echo "3. BACKEND WITH SMTP (Gmail)"
echo "============================"
echo "# Backend with Gmail SMTP"
echo 'docker run -d --name kamal-backend \'
echo '  -p 8001:8001 \'
echo '  -e SMTP_SERVER=smtp.gmail.com \'
echo '  -e SMTP_PORT=587 \'
echo '  -e SMTP_USE_TLS=true \'
echo '  -e SMTP_USERNAME=your-email@gmail.com \'
echo '  -e SMTP_PASSWORD=your-app-password \'
echo '  -e FROM_EMAIL=your-email@gmail.com \'
echo '  -e TO_EMAIL=kamal.singh@architecturesolutions.co.uk \'
echo '  kamal-portfolio:backend'

echo ""
echo "4. BACKEND WITH SMTP (Outlook)"
echo "==============================="
echo "# Backend with Outlook/Office365 SMTP"
echo 'docker run -d --name kamal-backend \'
echo '  -p 8001:8001 \'
echo '  -e SMTP_SERVER=smtp-mail.outlook.com \'
echo '  -e SMTP_PORT=587 \'
echo '  -e SMTP_USE_TLS=true \'
echo '  -e SMTP_USERNAME=your-email@outlook.com \'
echo '  -e SMTP_PASSWORD=your-password \'
echo '  -e FROM_EMAIL=your-email@outlook.com \'
echo '  -e TO_EMAIL=kamal.singh@architecturesolutions.co.uk \'
echo '  kamal-portfolio:backend'

echo ""
echo "5. BACKEND WITH CUSTOM SMTP"
echo "============================"
echo "# Backend with custom SMTP server"
echo 'docker run -d --name kamal-backend \'
echo '  -p 8001:8001 \'
echo '  -e SMTP_SERVER=mail.yourcompany.com \'
echo '  -e SMTP_PORT=587 \'
echo '  -e SMTP_USE_TLS=true \'
echo '  -e SMTP_USERNAME=noreply@yourcompany.com \'
echo '  -e SMTP_PASSWORD=your-smtp-password \'
echo '  -e FROM_EMAIL=noreply@yourcompany.com \'
echo '  -e TO_EMAIL=kamal.singh@architecturesolutions.co.uk \'
echo '  -e EMAIL_RATE_LIMIT_MAX=20 \'
echo '  -e SECRET_KEY=your-custom-secret-key \'
echo '  kamal-portfolio:backend'

echo ""
echo "6. FULL-STACK WITH MONGODB"
echo "=========================="
echo "# MongoDB container"
echo 'docker network create portfolio-net'
echo 'docker run -d --name kamal-mongo \'
echo '  --network portfolio-net \'
echo '  -p 27017:27017 \'
echo '  -e MONGO_INITDB_DATABASE=portfolio_db \'
echo '  mongo:6.0'
echo ""
echo "# Backend connected to MongoDB"
echo 'docker run -d --name kamal-backend \'
echo '  --network portfolio-net \'
echo '  -p 8001:8001 \'
echo '  -e MONGO_URL=mongodb://kamal-mongo:27017 \'
echo '  -e SMTP_USERNAME=your-email@gmail.com \'
echo '  -e SMTP_PASSWORD=your-app-password \'
echo '  -e FROM_EMAIL=your-email@gmail.com \'
echo '  kamal-portfolio:backend'
echo ""
echo "# Frontend"
echo 'docker run -d --name kamal-frontend \'
echo '  --network portfolio-net \'
echo '  -p 8080:80 \'
echo '  kamal-portfolio:npm'

echo ""
echo "7. PRODUCTION HTTPS WITH CUSTOM DOMAIN"
echo "======================================="
echo "# Generate production certificates first:"
echo '# ./generate-ssl-certificates.sh'
echo '# (Choose option 2 for production CSR)'
echo '# Send CSR to CA, receive certificate'
echo '# Place certificate as ./ssl/portfolio.crt'
echo ""
echo "# Production HTTPS deployment"
echo 'docker run -d --name kamal-portfolio-prod \'
echo '  --restart unless-stopped \'
echo '  -p 80:80 -p 443:443 \'
echo '  -v $(pwd)/ssl:/etc/nginx/ssl:ro \'
echo '  kamal-portfolio:https'

echo ""
echo "8. DEVELOPMENT WITH CUSTOM PORTS"
echo "================================"
echo "# All services on custom ports"
echo 'docker run -d --name kamal-portfolio-dev \'
echo '  -p 3000:80 \'  # Frontend on port 3000
echo '  kamal-portfolio:npm'
echo ""
echo 'docker run -d --name kamal-backend-dev \'
echo '  -p 3001:8001 \'  # Backend on port 3001
echo '  -e SMTP_USERNAME=dev@company.com \'
echo '  -e SMTP_PASSWORD=dev-password \'
echo '  kamal-portfolio:backend'
echo ""
echo 'docker run -d --name kamal-mongo-dev \'
echo '  -p 3017:27017 \'  # MongoDB on port 3017
echo '  mongo:6.0'

echo ""
echo "========================================="
echo "QUICK REFERENCE - Environment Variables"
echo "========================================="
echo "SMTP Configuration:"
echo "  -e SMTP_SERVER=smtp.gmail.com"
echo "  -e SMTP_PORT=587"
echo "  -e SMTP_USE_TLS=true"
echo "  -e SMTP_USERNAME=your-email@gmail.com"
echo "  -e SMTP_PASSWORD=your-app-password"
echo "  -e FROM_EMAIL=your-email@gmail.com"
echo "  -e TO_EMAIL=recipient@company.com"
echo ""
echo "Security & Rate Limiting:"
echo "  -e SECRET_KEY=your-secret-key"
echo "  -e EMAIL_RATE_LIMIT_WINDOW=3600"
echo "  -e EMAIL_RATE_LIMIT_MAX=10"
echo ""
echo "Database:"
echo "  -e MONGO_URL=mongodb://mongo-container:27017"
echo "  -e MONGO_INITDB_DATABASE=portfolio_db"
echo ""
echo "CORS:"
echo '  -e CORS_ORIGINS="http://localhost:8080,https://localhost:8443"'

echo ""
echo "📖 DOCUMENTATION GUIDE:"
echo "========================"
echo "🚀 GETTING_STARTED.md      - START HERE for first-time setup"
echo "📚 DEPLOYMENT_GUIDE.md      - Complete deployment reference" 
echo "⚡ docker-parameters-reference.md - Quick parameter lookup"
echo ""
echo "🔧 DYNAMIC DEPLOYMENT:"
echo "======================"
echo "For automated deployment with parameters:"
echo "   ./run-docker-dynamic.sh --help"
echo ""
echo "Examples:"
echo "   ./run-docker-dynamic.sh --type http --http-port 3000"
echo "   ./run-docker-dynamic.sh --type fullstack --smtp-username you@gmail.com"