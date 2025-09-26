# 🐳 Kamal Singh Portfolio - Single Docker Image Guide

## 📋 Overview

This guide covers deploying the complete Kamal Singh Portfolio as a **single Docker container** that includes everything: frontend (React), backend (FastAPI), database (MongoDB), and web server (Nginx). Perfect for easy deployment on any system with Docker.

## 🚀 Quick Start

### 1. Build the Image
```bash
# Clone/download the portfolio
git clone <repository-url> kamal-singh-portfolio
cd kamal-singh-portfolio

# Build the single container image
chmod +x build-single-image.sh
./build-single-image.sh
```

### 2. Run the Container
```bash
# Quick start with email functionality
docker run -d -p 80:80 \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-app-password \
  --name portfolio \
  kamal-singh-portfolio:latest
```

### 3. Access Your Portfolio
- **🌐 Portfolio Website**: http://localhost
- **🔧 Backend API**: http://localhost/api
- **📚 API Documentation**: http://localhost/api/docs

## 📦 What's Included in the Single Image

The container packages everything needed:

✅ **MongoDB 6.0** - Database with sample data  
✅ **Python 3.11 + FastAPI** - Backend API with email functionality  
✅ **Node.js 18 + React** - Frontend application  
✅ **Nginx** - Web server with reverse proxy  
✅ **Supervisor** - Process management  
✅ **SSL Support** - Self-signed certificates included  

## 🎮 Deployment Options

### Option 1: HTTP Only (Port 80)
```bash
docker run -d -p 80:80 \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-app-password \
  --name portfolio \
  kamal-singh-portfolio:latest
```

### Option 2: HTTP + HTTPS (Ports 80 & 443)
```bash
docker run -d \
  -p 80:80 \
  -p 443:443 \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-app-password \
  -e WEBSITE_URL=https://yourdomain.com \
  --name portfolio \
  kamal-singh-portfolio:latest
```

### Option 3: Custom Ports
```bash
docker run -d \
  -p 8080:80 \
  -p 8443:443 \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-app-password \
  --name portfolio \
  kamal-singh-portfolio:latest
```

### Option 4: Full Configuration
```bash
docker run -d \
  -p 80:80 \
  -p 443:443 \
  -e SMTP_SERVER=smtp.gmail.com \
  -e SMTP_PORT=587 \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-app-password \
  -e FROM_EMAIL=your-email@gmail.com \
  -e TO_EMAIL=kamal.singh@architecturesolutions.co.uk \
  -e WEBSITE_URL=https://yourdomain.com \
  -e SECRET_KEY=your-custom-secret-key \
  --name portfolio \
  kamal-singh-portfolio:latest
```

## 📧 Email Configuration

### Required for Contact Form
The contact form requires SMTP configuration to send emails:

```bash
-e SMTP_USERNAME=your-email@gmail.com \
-e SMTP_PASSWORD=your-16-character-app-password \
-e TO_EMAIL=kamal.singh@architecturesolutions.co.uk
```

### Gmail Setup (Recommended)
1. **Enable 2-Factor Authentication** on Gmail
2. **Generate App Password**:
   - Go to [Google Account Settings](https://myaccount.google.com/)
   - Security → 2-Step Verification → App passwords
   - Generate password for "Mail"
3. **Use in Docker command**:
   ```bash
   -e SMTP_USERNAME=youremail@gmail.com \
   -e SMTP_PASSWORD=abcdwxyzabcdwxyz
   ```

### Other Email Providers
```bash
# Outlook/Office365
-e SMTP_SERVER=smtp.office365.com \
-e SMTP_USERNAME=your-email@outlook.com \

# Yahoo
-e SMTP_SERVER=smtp.mail.yahoo.com \
-e SMTP_USERNAME=your-email@yahoo.com \

# Custom SMTP
-e SMTP_SERVER=mail.yourdomain.com \
-e SMTP_PORT=587 \
-e SMTP_USERNAME=your-email@yourdomain.com
```

## 🌐 Environment Variables

### Required Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `SMTP_USERNAME` | Email username | `your-email@gmail.com` |
| `SMTP_PASSWORD` | Email password/app-password | `abcdwxyzabcdwxyz` |

### Optional Variables
| Variable | Default | Description |
|----------|---------|-------------|
| `SMTP_SERVER` | `smtp.gmail.com` | SMTP server |
| `SMTP_PORT` | `587` | SMTP port |
| `TO_EMAIL` | `kamal.singh@architecturesolutions.co.uk` | Recipient email |
| `FROM_EMAIL` | `$SMTP_USERNAME` | Sender email |
| `WEBSITE_URL` | `http://localhost` | Website URL |
| `HTTP_PORT` | `80` | HTTP port |
| `HTTPS_PORT` | `443` | HTTPS port |
| `SECRET_KEY` | `kamal-singh-portfolio-production-2024` | Security key |
| `ENVIRONMENT` | `production` | Environment |

## 🛠️ Container Management

### Basic Commands
```bash
# View logs
docker logs portfolio

# Follow logs in real-time
docker logs -f portfolio

# Access container shell
docker exec -it portfolio bash

# Stop container
docker stop portfolio

# Start container
docker start portfolio

# Restart container
docker restart portfolio

# Remove container
docker rm portfolio
```

### Health Checks
```bash
# Check container health
docker inspect portfolio | grep -A 5 Health

# Manual health check
docker exec portfolio /app/healthcheck.sh

# Check individual services
docker exec portfolio supervisorctl status
```

### Service Management Inside Container
```bash
# Access container
docker exec -it portfolio bash

# Check service status
supervisorctl status

# Restart individual services
supervisorctl restart backend
supervisorctl restart nginx

# View service logs
tail -f /var/log/supervisor/backend.log
tail -f /var/log/nginx/access.log
```

## 📊 Monitoring & Troubleshooting

### View Service Status
```bash
# Container health
docker exec portfolio supervisorctl status

# Expected output:
# backend    RUNNING   pid 123, uptime 0:01:23
# mongodb    RUNNING   pid 124, uptime 0:01:24
# nginx      RUNNING   pid 125, uptime 0:01:22
```

### Check Logs
```bash
# All container logs
docker logs portfolio

# Specific service logs
docker exec portfolio tail -f /var/log/supervisor/backend.log
docker exec portfolio tail -f /var/log/nginx/access.log
docker exec portfolio tail -f /var/log/mongodb/mongodb.log
```

### Test Functionality
```bash
# Test frontend
curl http://localhost/

# Test backend API
curl http://localhost/api/

# Test backend health
curl http://localhost/api/health

# Test contact form (requires email config)
curl -X POST http://localhost/api/contact \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@example.com","message":"Test message"}'
```

### Common Issues & Solutions

#### 1. Container Won't Start
```bash
# Check logs for errors
docker logs portfolio

# Common causes:
# - Port already in use
# - Invalid email configuration
# - Insufficient memory
```

#### 2. Email Not Working
```bash
# Check email configuration
docker exec portfolio cat /app/backend/.env | grep SMTP

# Test email service
docker exec portfolio curl -H "Authorization: Bearer admin_token_2024" \
  -X POST http://localhost:8001/api/test-email
```

#### 3. Services Not Starting
```bash
# Check supervisor status
docker exec portfolio supervisorctl status

# Restart specific service
docker exec portfolio supervisorctl restart backend

# Check service logs
docker exec portfolio tail -f /var/log/supervisor/backend.log
```

## 💾 Image Distribution

### Save Image to File
```bash
# Create compressed image file
docker save kamal-singh-portfolio:latest | gzip > portfolio.tar.gz

# Transfer to another machine and load
docker load < portfolio.tar.gz
```

### Push to Registry
```bash
# Tag for registry
docker tag kamal-singh-portfolio:latest yourusername/kamal-singh-portfolio:latest

# Push to DockerHub
docker push yourusername/kamal-singh-portfolio:latest

# Pull and run on another machine
docker run -d -p 80:80 \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-app-password \
  --name portfolio \
  yourusername/kamal-singh-portfolio:latest
```

## 🚀 Production Deployment

### Cloud Deployment Examples

#### AWS EC2
```bash
# SSH to EC2 instance
ssh -i your-key.pem ec2-user@your-instance-ip

# Install Docker
sudo yum update -y
sudo yum install -y docker
sudo service docker start

# Load and run image
docker load < portfolio.tar.gz
docker run -d -p 80:80 -p 443:443 \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-app-password \
  -e WEBSITE_URL=https://your-domain.com \
  --name portfolio \
  kamal-singh-portfolio:latest
```

#### Google Cloud Run
```bash
# Tag for Google Container Registry
docker tag kamal-singh-portfolio:latest gcr.io/your-project/portfolio:latest

# Push to registry
docker push gcr.io/your-project/portfolio:latest

# Deploy to Cloud Run
gcloud run deploy portfolio \
  --image gcr.io/your-project/portfolio:latest \
  --platform managed \
  --port 80 \
  --set-env-vars SMTP_USERNAME=your-email@gmail.com,SMTP_PASSWORD=your-app-password
```

#### Azure Container Instances
```bash
# Create container group
az container create \
  --resource-group myResourceGroup \
  --name portfolio \
  --image kamal-singh-portfolio:latest \
  --ports 80 443 \
  --environment-variables \
    SMTP_USERNAME=your-email@gmail.com \
    SMTP_PASSWORD=your-app-password \
  --cpu 2 \
  --memory 4
```

## 🔒 Security Considerations

### Production Hardening
1. **Change default secrets**:
   ```bash
   -e SECRET_KEY=your-secure-secret-key \
   -e ADMIN_TOKEN=your-secure-admin-token
   ```

2. **Use HTTPS**:
   ```bash
   -p 443:443 \
   -e WEBSITE_URL=https://yourdomain.com
   ```

3. **Limit resources**:
   ```bash
   --memory=2g \
   --cpus=1.0
   ```

4. **Network security**:
   ```bash
   --network=custom-network \
   --expose 80
   ```

## 📈 Performance Optimization

### Resource Allocation
```bash
# For high-traffic sites
docker run -d \
  --memory=4g \
  --cpus=2.0 \
  --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  kamal-singh-portfolio:latest
```

### Monitoring
```bash
# Resource usage
docker stats portfolio

# Container metrics
docker exec portfolio top
docker exec portfolio df -h
```

## 🆘 Support & Troubleshooting

### Get Help
1. **Check container logs**: `docker logs portfolio`
2. **Verify configuration**: Check environment variables
3. **Test services**: Use health check endpoints
4. **Check documentation**: Refer to this guide

### Debug Mode
```bash
# Run with debug enabled
docker run -d -p 80:80 \
  -e DEBUG=True \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-app-password \
  --name portfolio-debug \
  kamal-singh-portfolio:latest
```

---

## 🎉 Success!

Your Kamal Singh Portfolio is now running in a single, self-contained Docker container! 

**Features included:**
- ✅ Professional portfolio showcasing 26+ years of IT architecture expertise
- ✅ 5 featured projects with detailed business outcomes
- ✅ Functional contact form with email notifications
- ✅ Professional email templates and auto-replies
- ✅ SSL/HTTPS support with self-signed certificates
- ✅ Production-ready security and performance optimizations

**Perfect for:**
- 🖥️ Local development and testing
- ☁️ Cloud deployment (AWS, GCP, Azure)
- 🏢 Corporate environments
- 🔧 Easy migration between environments

**Your professional portfolio is now ready to showcase expertise and capture leads! 🚀**