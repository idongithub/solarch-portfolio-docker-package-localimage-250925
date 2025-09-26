# Docker Parameters Quick Reference - Dynamic Deployment

## 📖 Documentation Navigation

**🔄 You are here:** Quick Reference  
**📚 Main Guide:** [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) ← Complete instructions  
**🚀 Getting Started:** [GETTING_STARTED.md](./GETTING_STARTED.md) ← First-time setup  

---

## 🐳 Docker Run Parameters for Kamal Singh Portfolio

### Dynamic Deployment Script (Recommended)

```bash
# Quick deployment with parameters 
./run-docker-dynamic.sh --help

# Examples:
./run-docker-dynamic.sh --type http --http-port 3000
./run-docker-dynamic.sh --type https --smtp-username you@gmail.com --smtp-password your-password
./run-docker-dynamic.sh --type both --http-port 8080 --https-port 8443
./run-docker-dynamic.sh --type fullstack --smtp-server mail.company.com --smtp-username noreply@company.com
./run-docker-dynamic.sh --type fullstack-both --smtp-username you@gmail.com --smtp-password your-password
```

### Direct Docker Commands (No .env files needed)

### Basic Frontend Deployment

**HTTP Deployment:**
```bash
# Standard HTTP deployment
docker run -d --name kamal-portfolio -p 8080:80 kamal-portfolio:npm

# Custom HTTP port
docker run -d --name kamal-portfolio -p 3000:80 kamal-portfolio:npm

# Production HTTP with restart policy
docker run -d --name kamal-portfolio-prod --restart unless-stopped -p 80:80 kamal-portfolio:npm
```

**HTTPS Deployment:**
```bash
# HTTPS with self-signed certificates (after running ./generate-ssl-certificates.sh)
docker run -d --name kamal-portfolio-https \
  -p 8080:80 -p 8443:443 \
  -v $(pwd)/ssl:/etc/nginx/ssl:ro \
  kamal-portfolio:https

# HTTPS with custom ports
docker run -d --name kamal-portfolio-https \
  -p 3000:80 -p 3443:443 \
  -v $(pwd)/ssl:/etc/nginx/ssl:ro \
  kamal-portfolio:https

# Production HTTPS
docker run -d --name kamal-portfolio-prod \
  --restart unless-stopped \
  -p 80:80 -p 443:443 \
  -v $(pwd)/ssl:/etc/nginx/ssl:ro \
  kamal-portfolio:https
```

### Backend with Dynamic SMTP (No .env files needed)

**Gmail SMTP (Complete Configuration):**
```bash
docker run -d --name kamal-backend \
  --restart unless-stopped \
  -p 8001:8001 \
  -e SMTP_SERVER=smtp.gmail.com \
  -e SMTP_PORT=587 \
  -e SMTP_USE_TLS=true \
  -e SMTP_USE_SSL=false \
  -e SMTP_STARTTLS=true \
  -e SMTP_TIMEOUT=30 \
  -e SMTP_RETRIES=3 \
  -e SMTP_DEBUG=false \
  -e SMTP_VERIFY_CERT=true \
  -e SMTP_AUTH=true \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-16-char-app-password \
  -e FROM_EMAIL=your-email@gmail.com \
  -e TO_EMAIL=kamal.singh@architecturesolutions.co.uk \
  -e REPLY_TO_EMAIL=your-email@gmail.com \
  -e EMAIL_SUBJECT_PREFIX="[Portfolio Contact]" \
  -e EMAIL_RATE_LIMIT_MAX=10 \
  -e EMAIL_COOLDOWN_PERIOD=60 \
  kamal-portfolio:backend
```

**Outlook/Office365 SMTP (Complete Configuration):**
```bash
docker run -d --name kamal-backend \
  --restart unless-stopped \
  -p 8001:8001 \
  -e SMTP_SERVER=smtp-mail.outlook.com \
  -e SMTP_PORT=587 \
  -e SMTP_USE_TLS=true \
  -e SMTP_USE_SSL=false \
  -e SMTP_STARTTLS=true \
  -e SMTP_TIMEOUT=30 \
  -e SMTP_RETRIES=3 \
  -e SMTP_DEBUG=false \
  -e SMTP_VERIFY_CERT=true \
  -e SMTP_AUTH=true \
  -e SMTP_USERNAME=your-email@outlook.com \
  -e SMTP_PASSWORD=your-password \
  -e FROM_EMAIL=your-email@outlook.com \
  -e TO_EMAIL=kamal.singh@architecturesolutions.co.uk \
  kamal-portfolio:backend
```

**Custom SMTP Server (Complete Configuration):**
```bash
docker run -d --name kamal-backend \
  --restart unless-stopped \
  -p 8001:8001 \
  -e SMTP_SERVER=mail.yourcompany.com \
  -e SMTP_PORT=587 \
  -e SMTP_USE_TLS=true \
  -e SMTP_USE_SSL=false \
  -e SMTP_STARTTLS=true \
  -e SMTP_TIMEOUT=45 \
  -e SMTP_RETRIES=5 \
  -e SMTP_DEBUG=false \
  -e SMTP_VERIFY_CERT=true \
  -e SMTP_LOCAL_HOSTNAME=portfolio.company.com \
  -e SMTP_AUTH=true \
  -e SMTP_USERNAME=noreply@yourcompany.com \
  -e SMTP_PASSWORD=your-smtp-password \
  -e FROM_EMAIL=noreply@yourcompany.com \
  -e TO_EMAIL=kamal.singh@architecturesolutions.co.uk \
  -e REPLY_TO_EMAIL=contact@yourcompany.com \
  -e CC_EMAIL=manager@yourcompany.com \
  -e BCC_EMAIL=admin@yourcompany.com \
  -e EMAIL_SUBJECT_PREFIX="[Company Portfolio]" \
  -e EMAIL_TEMPLATE=corporate \
  -e EMAIL_CHARSET=utf-8 \
  -e EMAIL_RATE_LIMIT_MAX=25 \
  -e EMAIL_COOLDOWN_PERIOD=30 \
  kamal-portfolio:backend
```

**Legacy SSL SMTP (Port 465):**
```bash
docker run -d --name kamal-backend \
  --restart unless-stopped \
  -p 8001:8001 \
  -e SMTP_SERVER=legacy-mail.company.com \
  -e SMTP_PORT=465 \
  -e SMTP_USE_TLS=false \
  -e SMTP_USE_SSL=true \
  -e SMTP_STARTTLS=false \
  -e SMTP_TIMEOUT=60 \
  -e SMTP_RETRIES=2 \
  -e SMTP_DEBUG=false \
  -e SMTP_VERIFY_CERT=false \
  -e SMTP_AUTH=true \
  -e SMTP_USERNAME=legacy-user \
  -e SMTP_PASSWORD=legacy-password \
  -e FROM_EMAIL=system@company.com \
  kamal-portfolio:backend
```

### Full-Stack Manual Deployment (No docker-compose needed)

**Complete HTTP Full-Stack (3 containers):**
```bash
# 1. Create network
docker network create portfolio-network

# 2. MongoDB
docker run -d --name kamal-mongo \
  --network portfolio-network \
  --restart unless-stopped \
  -p 27017:27017 \
  -e MONGO_INITDB_DATABASE=portfolio_db \
  mongo:6.0

# 3. Backend with SMTP
docker run -d --name kamal-backend \
  --network portfolio-network \
  --restart unless-stopped \
  -p 8001:8001 \
  -e MONGO_URL=mongodb://kamal-mongo:27017 \
  -e SMTP_SERVER=smtp.gmail.com \
  -e SMTP_PORT=587 \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-app-password \
  -e FROM_EMAIL=your-email@gmail.com \
  -e TO_EMAIL=kamal.singh@architecturesolutions.co.uk \
  kamal-portfolio:backend

# 4. Frontend
docker run -d --name kamal-frontend \
  --network portfolio-network \
  --restart unless-stopped \
  -p 8080:80 \
  kamal-portfolio:npm
```

**Complete HTTPS Full-Stack (3 containers):**
```bash
# Same as above, but replace step 4 with:
docker run -d --name kamal-frontend \
  --network portfolio-network \
  --restart unless-stopped \
  -p 8080:80 -p 8443:443 \
  -v $(pwd)/ssl:/etc/nginx/ssl:ro \
  kamal-portfolio:https
```

**Full-Stack with Custom Ports:**
```bash
# Network
docker network create portfolio-network

# MongoDB on custom port
docker run -d --name kamal-mongo \
  --network portfolio-network \
  -p 3017:27017 \
  mongo:6.0

# Backend on custom port
docker run -d --name kamal-backend \
  --network portfolio-network \
  -p 3001:8001 \
  -e MONGO_URL=mongodb://kamal-mongo:27017 \
  -e SMTP_USERNAME=your@gmail.com \
  -e SMTP_PASSWORD=your-password \
  kamal-portfolio:backend

# Frontend on custom port
docker run -d --name kamal-frontend \
  --network portfolio-network \
  -p 3000:80 \
  kamal-portfolio:npm
```

### Advanced Docker Run Options

```bash
# With health checks and resource limits
docker run -d \
  --name kamal-portfolio \
  --restart unless-stopped \
  --memory="512m" \
  --cpus="1.0" \
  --health-cmd="wget --quiet --tries=1 --spider http://localhost:80 || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  -p 8080:80 \
  -v portfolio-logs:/var/log/nginx \
  kamal-portfolio:npm
```

## 🔧 Environment Variables for Full-Stack

### SMTP Configuration
```bash
SMTP_SERVER=smtp.gmail.com              # Gmail, outlook, or custom
SMTP_PORT=587                           # 587 (TLS), 465 (SSL), 25 (plain)
SMTP_USE_TLS=true                       # Enable TLS encryption
SMTP_USERNAME=your-email@gmail.com      # Email address
SMTP_PASSWORD=your-app-password         # App password (not regular password)
FROM_EMAIL=your-email@gmail.com         # From address
TO_EMAIL=kamal.singh@architecturesolutions.co.uk  # Destination
```

### Port Configuration
```bash
FRONTEND_PORT=8080                      # External frontend port
BACKEND_PORT=8001                       # External backend port
MONGO_PORT=27017                        # External MongoDB port
NGINX_HTTP_PORT=80                      # HTTP port (internal)
NGINX_HTTPS_PORT=443                    # HTTPS port (if using SSL)
```

### Database Configuration
```bash
MONGO_ROOT_USERNAME=admin               # MongoDB admin user
MONGO_ROOT_PASSWORD=portfolio_admin_2024 # MongoDB admin password
DB_NAME=portfolio_db                    # Database name
```

### Security Configuration
```bash
SECRET_KEY=your-secret-key-here         # Application secret
ADMIN_TOKEN=your-admin-token            # Admin token
EMAIL_RATE_LIMIT_WINDOW=3600            # Rate limit window (seconds)
EMAIL_RATE_LIMIT_MAX=10                 # Max emails per window
```

### Application URLs
```bash
REACT_APP_BACKEND_URL=http://localhost:8001     # Backend URL for frontend
WEBSITE_URL=http://localhost:8080               # Main website URL
CORS_ORIGINS=http://localhost:8080,http://127.0.0.1:8080  # CORS origins
```

## 📋 SMTP Provider Examples

### Gmail (Complete Configuration)
```bash
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USE_TLS=true
SMTP_USE_SSL=false
SMTP_STARTTLS=true
SMTP_TIMEOUT=30
SMTP_RETRIES=3
SMTP_DEBUG=false
SMTP_VERIFY_CERT=true
SMTP_AUTH=true
SMTP_USERNAME=yourname@gmail.com
SMTP_PASSWORD=your-16-char-app-password
FROM_EMAIL=yourname@gmail.com
TO_EMAIL=kamal.singh@architecturesolutions.co.uk
REPLY_TO_EMAIL=yourname@gmail.com
EMAIL_SUBJECT_PREFIX="[Portfolio Contact]"
EMAIL_RATE_LIMIT_MAX=10
EMAIL_COOLDOWN_PERIOD=60
```

### Outlook/Office365 (Complete Configuration)
```bash
SMTP_SERVER=smtp-mail.outlook.com
SMTP_PORT=587
SMTP_USE_TLS=true
SMTP_USE_SSL=false
SMTP_STARTTLS=true
SMTP_TIMEOUT=30
SMTP_RETRIES=3
SMTP_DEBUG=false
SMTP_VERIFY_CERT=true
SMTP_AUTH=true
SMTP_USERNAME=yourname@outlook.com
SMTP_PASSWORD=your-password
FROM_EMAIL=yourname@outlook.com
TO_EMAIL=kamal.singh@architecturesolutions.co.uk
EMAIL_SUBJECT_PREFIX="[Portfolio Inquiry]"
EMAIL_RATE_LIMIT_MAX=15
EMAIL_COOLDOWN_PERIOD=45
```

### Custom SMTP (Complete Configuration)
```bash
SMTP_SERVER=mail.yourdomain.com
SMTP_PORT=587
SMTP_USE_TLS=true
SMTP_USE_SSL=false
SMTP_STARTTLS=true
SMTP_TIMEOUT=45
SMTP_RETRIES=5
SMTP_DEBUG=false
SMTP_VERIFY_CERT=true
SMTP_LOCAL_HOSTNAME=portfolio.yourdomain.com
SMTP_AUTH=true
SMTP_USERNAME=noreply@yourdomain.com
SMTP_PASSWORD=your-smtp-password
FROM_EMAIL=noreply@yourdomain.com
TO_EMAIL=kamal.singh@architecturesolutions.co.uk
REPLY_TO_EMAIL=contact@yourdomain.com
CC_EMAIL=manager@yourdomain.com
BCC_EMAIL=admin@yourdomain.com
EMAIL_SUBJECT_PREFIX="[Company Portfolio]"
EMAIL_TEMPLATE=corporate
EMAIL_CHARSET=utf-8
EMAIL_RATE_LIMIT_MAX=25
EMAIL_COOLDOWN_PERIOD=30
```

### Legacy SSL SMTP (Port 465)
```bash
SMTP_SERVER=legacy-mail.company.com
SMTP_PORT=465
SMTP_USE_TLS=false
SMTP_USE_SSL=true
SMTP_STARTTLS=false
SMTP_TIMEOUT=60
SMTP_RETRIES=2
SMTP_DEBUG=false
SMTP_VERIFY_CERT=false
SMTP_AUTH=true
SMTP_USERNAME=legacy-user
SMTP_PASSWORD=legacy-password
FROM_EMAIL=system@company.com
TO_EMAIL=kamal.singh@architecturesolutions.co.uk
```

### All SMTP Environment Variables Reference
```bash
# Core SMTP Server Settings
SMTP_SERVER=smtp.gmail.com              # SMTP server hostname
SMTP_PORT=587                           # SMTP port (25, 465, 587, 2525)
SMTP_USE_TLS=true                       # Enable TLS encryption
SMTP_USE_SSL=false                      # Enable SSL encryption (legacy)
SMTP_STARTTLS=true                      # Enable STARTTLS upgrade
SMTP_TIMEOUT=30                         # Connection timeout (seconds)
SMTP_RETRIES=3                          # Retry attempts on failure
SMTP_DEBUG=false                        # Enable debug logging
SMTP_VERIFY_CERT=true                   # Verify SSL certificates
SMTP_LOCAL_HOSTNAME=""                  # Local hostname for SMTP HELO
SMTP_AUTH=true                          # Use SMTP authentication

# SMTP Credentials
SMTP_USERNAME=your-email@gmail.com      # SMTP username (usually email)
SMTP_PASSWORD=your-app-password         # SMTP password or app password
FROM_EMAIL=your-email@gmail.com         # From email address
TO_EMAIL=kamal.singh@architecturesolutions.co.uk  # Primary recipient
REPLY_TO_EMAIL=your-email@gmail.com     # Reply-to address (optional)
CC_EMAIL=manager@company.com            # CC recipient (optional)
BCC_EMAIL=admin@company.com             # BCC recipient (optional)

# Email Content Configuration
EMAIL_SUBJECT_PREFIX="[Portfolio Contact]"  # Subject line prefix
EMAIL_TEMPLATE=default                  # Email template name
EMAIL_CHARSET=utf-8                     # Email character encoding
EMAIL_RATE_LIMIT_MAX=10                 # Max emails per window
EMAIL_COOLDOWN_PERIOD=60                # Cooldown between emails (seconds)
```

## 🚀 Quick Commands

### HTTP Deployment
```bash
# Build and run HTTP
./build-docker-npm.sh

# Manual HTTP build
docker build --no-cache -f Dockerfile.npm -t kamal-portfolio:npm .
docker run -d --name kamal-portfolio -p 8080:80 kamal-portfolio:npm
```

### HTTPS Deployment
```bash
# Generate certificates and build HTTPS
./generate-ssl-certificates.sh
./build-docker-https.sh

# Manual HTTPS build
docker build --no-cache -f Dockerfile.https -t kamal-portfolio:https .
docker run -d --name kamal-portfolio-https -p 8080:80 -p 8443:443 kamal-portfolio:https
```

### Full-Stack HTTP with SMTP
```bash
# Configure environment
cp .env.docker.template .env.docker
# Edit .env.docker with your settings

# Build and run
./build-docker-fullstack.sh

# Manual build
docker-compose --env-file .env.docker build
docker-compose --env-file .env.docker up -d
```

### Full-Stack HTTPS with SMTP
```bash
# Configure environment and SSL
cp .env.docker.template .env.docker
./generate-ssl-certificates.sh
# Edit .env.docker with your settings

# Build and run HTTPS
./build-docker-fullstack-https.sh

# Manual build
docker-compose -f docker-compose.https.yml --env-file .env.docker build
docker-compose -f docker-compose.https.yml --env-file .env.docker up -d
```

### Container Management
```bash
# View status
docker ps

# View logs
docker logs kamal-portfolio

# Stop container
docker stop kamal-portfolio

# Remove container
docker rm kamal-portfolio

# Clean rebuild
docker stop kamal-portfolio && docker rm kamal-portfolio && docker rmi kamal-portfolio:npm
./build-docker-npm.sh
```

## 🔍 Troubleshooting Parameters

### Debug Mode
```bash
# Run with interactive shell
docker run -it --rm -p 8080:80 kamal-portfolio:npm /bin/sh

# Check nginx config
docker exec kamal-portfolio nginx -t

# View nginx logs
docker exec kamal-portfolio tail /var/log/nginx/error.log
```

### Port Conflicts
```bash
# Check what's using port 8080
lsof -i :8080
netstat -tulpn | grep 8080

# Use alternative port
docker run -d --name kamal-portfolio -p 3000:80 kamal-portfolio:npm
```

### Volume Mounts for Development
```bash
# Mount local nginx config for testing
docker run -d --name kamal-portfolio \
  -p 8080:80 \
  -v $(pwd)/nginx-simple.conf:/etc/nginx/conf.d/default.conf \
  kamal-portfolio:npm
```

---

**For complete documentation, see [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)**