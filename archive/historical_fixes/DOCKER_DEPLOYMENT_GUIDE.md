# 🐳 Kamal Singh Portfolio - Docker Deployment Guide

## 📋 Overview

This guide covers deploying the complete Kamal Singh Portfolio application using Docker containers. The setup includes frontend (React), backend (FastAPI), database (MongoDB), and optional reverse proxy (Nginx) in a production-ready configuration.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Docker Network                           │
├─────────────────┬─────────────────┬─────────────────┬───────────┤
│     Frontend    │     Backend     │    MongoDB      │   Nginx   │
│   (React App)   │   (FastAPI)     │   (Database)    │ (Optional) │
│   Port: 3000    │   Port: 8001    │   Port: 27017   │  Port: 80 │
└─────────────────┴─────────────────┴─────────────────┴───────────┘
```

## ⚡ Quick Start

### 1. Clone Repository & Setup Environment
```bash
# Clone the repository
git clone <repository-url> kamal-singh-portfolio
cd kamal-singh-portfolio

# Copy environment template
cp .env.docker.example .env.docker

# Edit environment variables (REQUIRED)
nano .env.docker
```

### 2. Configure Email Settings (REQUIRED)
Edit `.env.docker` and configure these essential settings:

```bash
# Email Configuration - REQUIRED FOR CONTACT FORM
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
TO_EMAIL=kamal.singh@architecturesolutions.co.uk

# Database Security - CHANGE DEFAULT PASSWORDS
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=your-secure-password-here

# Application Security - CHANGE DEFAULT SECRETS
SECRET_KEY=your-secret-key-here
ADMIN_TOKEN=your-admin-token-here
```

### 3. Start Application
```bash
# Start all services
docker-compose --env-file .env.docker up -d

# View logs
docker-compose logs -f

# Check service status
docker-compose ps
```

### 4. Access Application
- **🌐 Portfolio**: http://localhost:3000
- **🔧 Backend API**: http://localhost:8001
- **📚 API Docs**: http://localhost:8001/docs
- **🗄️ MongoDB**: localhost:27017

## 📧 Email Configuration

### Gmail Setup (Recommended)
1. **Enable 2-Factor Authentication** on your Gmail account
2. **Generate App Password**:
   - Go to [Google Account Settings](https://myaccount.google.com/)
   - Security → 2-Step Verification → App passwords
   - Generate password for "Mail"
3. **Configure `.env.docker`**:
   ```bash
   SMTP_SERVER=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USE_TLS=true
   SMTP_USERNAME=your-email@gmail.com
   SMTP_PASSWORD=your-16-character-app-password
   ```

### Outlook/Office365 Setup
```bash
SMTP_SERVER=smtp.office365.com
SMTP_PORT=587
SMTP_USE_TLS=true
SMTP_USERNAME=your-email@outlook.com
SMTP_PASSWORD=your-password
```

### Other Email Providers
Check your email provider's SMTP settings and update accordingly.

## 🔧 Environment Configuration

### Complete Environment Variables

```bash
# ===== DATABASE CONFIGURATION =====
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=secure_password_change_this
DB_NAME=portfolio_db
MONGO_PORT=27017

# ===== EMAIL CONFIGURATION =====
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USE_TLS=true
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
FROM_EMAIL=your-email@gmail.com
TO_EMAIL=kamal.singh@architecturesolutions.co.uk

# Email rate limiting (per hour)
EMAIL_RATE_LIMIT_WINDOW=3600
EMAIL_RATE_LIMIT_MAX=10

# ===== SECURITY CONFIGURATION =====
SECRET_KEY=kamal-singh-portfolio-production-secret-2024
ADMIN_TOKEN=admin_token_change_this_2024

# ===== APPLICATION CONFIGURATION =====
BACKEND_PORT=8001
FRONTEND_PORT=3000
ENVIRONMENT=production
DEBUG=False

REACT_APP_BACKEND_URL=http://localhost:8001
CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
WEBSITE_URL=http://localhost:3000

# ===== NGINX CONFIGURATION (Optional) =====
NGINX_HTTP_PORT=80
NGINX_HTTPS_PORT=443
```

## 🚀 Production Deployment

### With Nginx Reverse Proxy
```bash
# Start with Nginx reverse proxy
docker-compose --env-file .env.docker --profile production up -d

# Access via Nginx
# Frontend: http://localhost (port 80)
# API: http://localhost/api
```

### Custom Domain Setup
1. **Update environment variables**:
   ```bash
   REACT_APP_BACKEND_URL=https://api.yourdomain.com
   CORS_ORIGINS=https://yourdomain.com
   WEBSITE_URL=https://yourdomain.com
   ```

2. **Configure SSL certificates** (place in `./ssl/` directory):
   ```bash
   ./ssl/cert.pem
   ./ssl/key.pem
   ```

3. **Update nginx.conf** to enable HTTPS

### Production Security Checklist
- [ ] Change all default passwords and secrets
- [ ] Use strong, unique passwords (20+ characters)
- [ ] Configure SSL/TLS certificates
- [ ] Set up firewall rules
- [ ] Enable log monitoring
- [ ] Regular security updates
- [ ] Backup strategy implementation

## 🛠️ Management Commands

### Service Management
```bash
# Start all services
docker-compose --env-file .env.docker up -d

# Stop all services
docker-compose down

# Restart specific service
docker-compose restart backend

# View logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongodb

# Check service status
docker-compose ps

# View resource usage
docker stats
```

### Database Management
```bash
# Access MongoDB shell
docker-compose exec mongodb mongosh -u admin -p

# Backup database
docker-compose exec mongodb mongodump --uri="mongodb://admin:password@localhost:27017/portfolio_db?authSource=admin" --out=/backup

# Restore database
docker-compose exec mongodb mongorestore --uri="mongodb://admin:password@localhost:27017/portfolio_db?authSource=admin" /backup/portfolio_db
```

### Application Updates
```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose --env-file .env.docker up --build -d

# Clean unused images
docker image prune -f
```

## 🔍 Monitoring & Troubleshooting

### Health Checks
```bash
# Check all services health
curl http://localhost:3000/health  # Frontend
curl http://localhost:8001/api/health  # Backend

# Test email functionality (requires admin token)
curl -H "Authorization: Bearer your-admin-token" \
     -X POST http://localhost:8001/api/test-email
```

### Common Issues

#### 1. Email Not Sending
```bash
# Check backend logs
docker-compose logs backend | grep -i email

# Test SMTP connection
docker-compose exec backend python -c "
import smtplib
server = smtplib.SMTP('smtp.gmail.com', 587)
server.starttls()
server.login('your-email', 'your-password')
print('SMTP connection successful')
"
```

#### 2. Database Connection Issues
```bash
# Check MongoDB logs
docker-compose logs mongodb

# Test connection
docker-compose exec mongodb mongosh --eval "db.adminCommand('ping')"

# Check network connectivity
docker-compose exec backend nc -zv mongodb 27017
```

#### 3. Frontend Build Issues
```bash
# Rebuild frontend
docker-compose build --no-cache frontend

# Check frontend logs
docker-compose logs frontend
```

#### 4. Port Conflicts
```bash
# Check port usage
lsof -i :3000
lsof -i :8001
lsof -i :27017

# Use different ports
export FRONTEND_PORT=3001
export BACKEND_PORT=8002
docker-compose --env-file .env.docker up -d
```

### Performance Tuning

#### Resource Limits
Add to `docker-compose.yml`:
```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

#### Volume Optimization
```bash
# Use named volumes for better performance
volumes:
  mongodb_data:
    driver: local
    driver_opts:
      type: none
      device: /opt/portfolio/data
      o: bind
```

## 📊 Monitoring Setup

### Log Aggregation
```bash
# Centralized logging
docker-compose logs --timestamps --follow > portfolio.log

# Log rotation
logrotate -f /etc/logrotate.d/portfolio
```

### Metrics Collection
```bash
# Monitor resource usage
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Export metrics
docker-compose exec backend curl http://localhost:8001/api/health | jq
```

## 🔐 Security Hardening

### Container Security
```bash
# Run security scan
docker scout cves portfolio_backend
docker scout cves portfolio_frontend

# Update base images
docker-compose build --no-cache --pull
```

### Network Security
```bash
# Isolate networks
docker network create portfolio_network --internal

# Configure firewall
ufw allow 80/tcp
ufw allow 443/tcp
ufw deny 8001/tcp  # Block direct backend access
```

## 💾 Backup & Recovery

### Automated Backup Script
```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/portfolio_$DATE"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup database
docker-compose exec mongodb mongodump \
  --uri="mongodb://admin:$MONGO_ROOT_PASSWORD@localhost:27017/portfolio_db?authSource=admin" \
  --out="$BACKUP_DIR/db"

# Backup application files
tar -czf "$BACKUP_DIR/app.tar.gz" .

echo "Backup completed: $BACKUP_DIR"
```

### Recovery Process
```bash
# Stop services
docker-compose down

# Restore database
docker-compose up -d mongodb
docker-compose exec mongodb mongorestore \
  --uri="mongodb://admin:password@localhost:27017/portfolio_db?authSource=admin" \
  /backup/portfolio_db

# Start all services
docker-compose up -d
```

## 🎯 Performance Optimization

### Production Optimizations
1. **Enable Gzip compression** in Nginx
2. **Configure caching headers** for static assets
3. **Use CDN** for images and static files
4. **Implement database indexing** for better query performance
5. **Set up connection pooling** for database connections

### Scaling Considerations
```yaml
# Horizontal scaling
services:
  backend:
    deploy:
      replicas: 3
    
  frontend:
    deploy:
      replicas: 2
```

## 📞 Support & Troubleshooting

### Getting Help
1. **Check logs first**: Most issues are visible in service logs
2. **Verify environment variables**: Ensure all required variables are set
3. **Test network connectivity**: Services must be able to communicate
4. **Check resource usage**: Ensure sufficient CPU/memory available

### Debug Mode
```bash
# Enable debug logging
export DEBUG=True
docker-compose --env-file .env.docker up -d

# Interactive debugging
docker-compose exec backend bash
docker-compose exec frontend sh
```

---

## 🎉 Success!

Once deployed successfully, you'll have:
- ✅ **Professional Portfolio** showcasing 26+ years of IT architecture expertise
- ✅ **5 Featured Projects** with detailed business outcomes
- ✅ **Functional Contact Form** with email notifications
- ✅ **Production-ready infrastructure** with Docker containerization
- ✅ **Scalable architecture** ready for high-traffic deployment

**Your Kamal Singh Portfolio is now running in Docker! 🐳**

For additional help, check the logs or refer to the troubleshooting section above.