# 🚀 Quick Start Guide - Portfolio Platform

## ⚡ **5-Minute Deployment**

Get the Kamal Singh Portfolio Platform running with intelligent dual captcha security in minutes.

## 📋 **Prerequisites**

### **Required**
- **Docker** & **Docker Compose** installed
- **Kong API Gateway** running (for HTTPS local access)
- **4GB+ RAM** available

### **Ports Required**
```bash
3400    # HTTP Frontend
3443    # HTTPS Frontend  
3001    # Backend API
8443    # Kong HTTPS Proxy
27017   # MongoDB
8081    # MongoDB GUI
3000    # Grafana
9090    # Prometheus
```

## 🚀 **Option 1: Local Development (HTTP Only)**

```bash
# Clone and deploy
git clone <repository-url>
cd portfolio-app

# Basic HTTP deployment
./scripts/deploy-with-params.sh \
  --http-port 3400 \
  --backend-port 3001

# Access
open http://192.168.86.75:3400
```

**Result**: ✅ HTTP frontend with math captcha + Direct backend

## 🔒 **Option 2: Full Local Setup (HTTP + HTTPS)**

```bash
# Verify Kong is running
curl -f http://192.168.86.75:8001/status

# Deploy with Kong integration  
./scripts/deploy-with-params.sh \
  --http-port 3400 \
  --https-port 3443 \
  --kong-host 192.168.86.75 \
  --kong-port 8443

# Access both methods
open http://192.168.86.75:3400   # Math Captcha + Direct
open https://192.168.86.75:3443  # Math Captcha + Kong
```

**Result**: ✅ Dual local access with Kong HTTPS proxy

## 🌐 **Option 3: Production Domain Deployment**

```bash
# Full production deployment
./scripts/deploy-with-params.sh \
  --domain portfolio \
  --recaptcha-site-key "6LcgftMrAAAAAPJRuWA4mQgstPWYoIXoPM4PBjMM" \
  --recaptcha-secret-key "6LcgftMrAAAAANYLqKcqycaZrYzEhpVBmQNeacsm" \
  --smtp-server smtp.ionos.co.uk \
  --smtp-port 465 \
  --smtp-use-ssl true

# Access production
open https://portfolio.architecturesolutions.co.uk
```

**Result**: ✅ Production domain with Google reCAPTCHA + Traefik

## ✅ **Verification Steps**

### **1. Health Checks**
```bash
# Backend health
curl -f http://192.168.86.75:3001/api/health

# Frontend access  
curl -I http://192.168.86.75:3400
curl -k -I https://192.168.86.75:3443

# Kong status (if deployed)
curl -f http://192.168.86.75:8001/status
```

### **2. Test Contact Form**
```bash
# Test local math captcha
curl -X POST http://192.168.86.75:3001/api/contact/send-email \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com", 
    "message": "Testing deployment",
    "local_captcha": "{\"type\":\"local_captcha\",\"user_answer\":\"42\"}"
  }'
```

### **3. Check Monitoring**
```bash
# Open dashboards
open http://192.168.86.75:3000  # Grafana (admin/admin)
open http://192.168.86.75:9090  # Prometheus
open http://192.168.86.75:8081  # MongoDB GUI
```

## 🔧 **Quick Troubleshooting**

### **Frontend Not Loading**
```bash
# Check container status
docker ps | grep frontend

# Restart if needed
docker-compose restart frontend-http
```

### **Kong Connection Issues**
```bash
# Verify Kong is running
docker ps | grep kong
curl http://192.168.86.75:8001/status

# Check CORS configuration  
curl -X GET http://192.168.86.75:8001/plugins
```

### **Environment Variables Missing**
```bash
# Debug frontend environment
./scripts/debug-frontend-env.sh

# Expected output:
# ✅ Frontend .env file exists
# ✅ Kong URL found in build
# ✅ CSP headers configured
```

## 📊 **What You Get**

### **🛡️ Security Features**
- **Math Captcha**: Privacy-first for local access
- **Google reCAPTCHA**: Enterprise-grade for domain access  
- **Auto-Detection**: Seamless security selection
- **Rate Limiting**: 5 requests/minute protection

### **🌉 Gateway Features**
- **Kong Proxy**: HTTPS for local deployments
- **Traefik**: Production SSL termination
- **CORS Handling**: Cross-origin request support
- **Health Monitoring**: Real-time status checks

### **📈 Monitoring Stack**  
- **Grafana**: Visual dashboards and alerts
- **Prometheus**: Metrics collection and storage
- **Loki**: Centralized log aggregation
- **MongoDB**: Contact data with web interface

### **📧 Email Integration**
- **IONOS SMTP**: Professional email delivery
- **Template System**: HTML email formatting
- **Error Handling**: Graceful failure management
- **Multi-Access**: Works across all deployment methods

## 🎯 **Access Summary**

| Method | URL | Security | Gateway |
|--------|-----|----------|---------|
| **Local HTTP** | `http://192.168.86.75:3400` | Math Captcha | Direct |
| **Local HTTPS** | `https://192.168.86.75:3443` | Math Captcha | Kong |
| **Production** | `https://portfolio.architecturesolutions.co.uk` | reCAPTCHA | Traefik |

## 📚 **Next Steps**

- **📖 Full Documentation**: See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **🏗️ Architecture**: Review [ARCHITECTURE.md](ARCHITECTURE.md)  
- **🔒 Security Details**: Check [SECURITY_IMPLEMENTATION_SUMMARY.md](SECURITY_IMPLEMENTATION_SUMMARY.md)
- **🌉 Kong Setup**: Read [KONG_API_GATEWAY_ARCHITECTURE.md](KONG_API_GATEWAY_ARCHITECTURE.md)

---

*Get your enterprise portfolio running in minutes with intelligent dual captcha security*