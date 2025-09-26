# 🔄 Migration Guide - Upgrading to Final Architecture

## 🎯 **Overview**

This guide helps you migrate from previous portfolio implementations to the final production architecture with intelligent dual captcha security and Kong API Gateway integration.

## 📋 **Migration Scenarios**

### **Scenario 1: Basic Docker Setup → Dual Captcha System**
Upgrading from simple Docker deployment to full dual captcha architecture.

### **Scenario 2: Single Captcha → Intelligent Dual Captcha**  
Adding automatic security adaptation to existing captcha implementations.

### **Scenario 3: Direct Backend → Kong Integration**
Adding HTTPS proxy support for local deployments.

### **Scenario 4: Manual Deployment → Automated Scripts**
Moving to parameterized deployment scripts.

## 🛠️ **Pre-Migration Checklist**

### **1. Backup Current Setup**
```bash
# Backup existing data
mkdir -p ./backup/$(date +%Y%m%d)

# Backup MongoDB data (if exists)
docker exec mongodb mongodump --out /backup/mongodb_backup
docker cp mongodb:/backup/mongodb_backup ./backup/$(date +%Y%m%d)/

# Backup configuration files
cp -r ./frontend/.env ./backend/.env ./backup/$(date +%Y%m%d)/
```

### **2. Environment Assessment**
```bash
# Check current containers
docker ps -a | grep -E "(frontend|backend|mongodb)"

# Check current ports in use
netstat -tlnp | grep -E "(3000|3001|8080|8081|27017)"

# Verify Kong availability (if needed)
curl -f http://192.168.86.75:8001/status || echo "Kong not available"
```

### **3. Requirements Verification**
- ✅ Docker & Docker Compose updated to latest
- ✅ Kong API Gateway installed (for HTTPS local access)
- ✅ Minimum 4GB RAM available
- ✅ Required ports available (see Quick Start guide)

## 🚀 **Migration Process**

### **Step 1: Stop Current Services**
```bash
# Stop existing containers
docker-compose down
docker stop $(docker ps -q --filter "name=frontend") 2>/dev/null || true
docker stop $(docker ps -q --filter "name=backend") 2>/dev/null || true
docker stop $(docker ps -q --filter "name=mongodb") 2>/dev/null || true
```

### **Step 2: Update Codebase**
```bash
# Pull latest changes
git fetch origin
git checkout main
git pull origin main

# Verify new files are present
ls -la scripts/deploy-with-params.sh
ls -la frontend/src/components/LocalCaptcha.jsx
ls -la DUAL_CAPTCHA_ARCHITECTURE.md
```

### **Step 3: Clean Previous Build**
```bash
# Remove old containers and images
docker system prune -a --volumes -f

# Remove old environment configurations
rm -f .env docker-compose.override.yml
```

### **Step 4: Deploy New Architecture**
```bash
# Option A: Local development with Kong
./scripts/deploy-with-params.sh \
  --http-port 3400 \
  --https-port 3443 \
  --kong-host 192.168.86.75 \
  --kong-port 8443

# Option B: Production domain deployment
./scripts/deploy-with-params.sh \
  --domain portfolio \
  --recaptcha-site-key "YOUR_SITE_KEY" \
  --recaptcha-secret-key "YOUR_SECRET_KEY"
```

### **Step 5: Verify Migration**
```bash
# Check all access methods
curl -f http://192.168.86.75:3400/
curl -k -f https://192.168.86.75:3443/
curl -f http://192.168.86.75:3001/api/health

# Test environment variables
./scripts/debug-frontend-env.sh
```

## 🔄 **Configuration Migration**

### **Environment Variables Mapping**

#### **Old Configuration**
```bash
# Previous .env structure
REACT_APP_BACKEND_URL=http://localhost:8001
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
```

#### **New Configuration** 
```bash
# New dual-access configuration
REACT_APP_BACKEND_URL=https://portfolio.architecturesolutions.co.uk
REACT_APP_KONG_HOST=192.168.86.75
REACT_APP_KONG_PORT=8443
REACT_APP_BACKEND_URL_HTTP=http://192.168.86.75:3001
REACT_APP_RECAPTCHA_SITE_KEY=6LcgftMrAAAAAPJRuWA4mQgstPWYoIXoPM4PBjMM

# Backend configuration
RECAPTCHA_SECRET_KEY=6LcgftMrAAAAANYLqKcqycaZrYzEhpVBmQNeacsm
SMTP_SERVER=smtp.ionos.co.uk
SMTP_PORT=465
SMTP_USE_SSL=true
CORS_ORIGINS=https://portfolio.architecturesolutions.co.uk,http://192.168.86.75:3400,https://192.168.86.75:3443
```

### **Database Migration**
```bash
# Restore previous MongoDB data (if needed)
docker exec -i mongodb mongorestore /backup/mongodb_backup

# Verify data integrity
curl -X GET http://192.168.86.75:8081  # MongoDB GUI
```

## 🛡️ **Security Migration**

### **Captcha System Updates**

#### **From Single Captcha**
```javascript
// OLD: Single reCAPTCHA implementation
const handleSubmit = async () => {
  const token = await grecaptcha.execute(SITE_KEY, {action: 'contact'});
  // Submit with token
};
```

#### **To Dual Captcha**
```javascript
// NEW: Intelligent captcha selection
const useLocalCaptcha = isLocalAccess();

{useLocalCaptcha ? (
  <LocalCaptcha onCaptchaChange={setLocalCaptchaData} />
) : (
  <div>🛡️ Protected by Google reCAPTCHA</div>
)}
```

### **CORS Configuration Updates**
```python
# OLD: Single origin CORS
CORS_ORIGINS = ["http://localhost:3000"]

# NEW: Multi-origin CORS  
CORS_ORIGINS = [
    "http://192.168.86.75:3400",      # Local HTTP
    "https://192.168.86.75:3443",     # Local HTTPS
    "https://portfolio.architecturesolutions.co.uk"  # Domain
]
```

## 🌉 **Kong Integration Migration**

### **If Kong Not Previously Used**
```bash
# Install Kong (Ubuntu/Debian)
curl -Lo kong-2.8.1.amd64.deb https://download.konghq.com/gateway-2.x-ubuntu-focal/pool/all/k/kong/kong_2.8.1_amd64.deb
sudo dpkg -i kong-2.8.1.amd64.deb

# Start Kong
sudo systemctl start kong
sudo systemctl enable kong
```

### **Kong Configuration**
```bash
# Configure Kong for portfolio backend
curl -X POST http://192.168.86.75:8001/services/ \
  --data "name=portfolio-backend" \
  --data "url=http://192.168.86.75:3001"

curl -X POST http://192.168.86.75:8001/services/portfolio-backend/routes \
  --data "name=portfolio-api-route" \
  --data "paths[]=/api"

curl -X POST http://192.168.86.75:8001/services/portfolio-backend/plugins \
  --data "name=cors" \
  --data "config.origins=https://192.168.86.75:3443"
```

## 📊 **Monitoring Migration**

### **Dashboard Access Updates**
```bash
# Previous monitoring (if any)
OLD: Basic logging or no monitoring

# New comprehensive stack
Grafana:    http://192.168.86.75:3000   (admin/admin)
Prometheus: http://192.168.86.75:9090
MongoDB:    http://192.168.86.75:8081   (admin/admin123)
Kong:       http://192.168.86.75:8001   (admin API)
```

### **Metrics Collection**
```yaml
# New metrics available
contact_form_submissions_total{method="local_captcha"}
contact_form_submissions_total{method="google_recaptcha"}
captcha_verifications_total{type="local_math"}
captcha_verifications_total{type="google_recaptcha"}
kong_bandwidth_total
http_request_duration_seconds
```

## ⚠️ **Troubleshooting Migration Issues**

### **Issue 1: Environment Variables Not Loading**
```bash
# Symptom: Frontend shows default values
# Solution: Verify export statements in deploy script
grep -n "export.*REACT_APP" ./scripts/deploy-with-params.sh

# Rebuild containers if needed
docker-compose down && docker-compose up -d --build --no-cache
```

### **Issue 2: Kong Connection Refused**
```bash
# Symptom: HTTPS frontend can't reach backend
# Check Kong status
curl http://192.168.86.75:8001/status
sudo systemctl status kong

# Verify Kong configuration
curl -X GET http://192.168.86.75:8001/services
curl -X GET http://192.168.86.75:8001/routes
```

### **Issue 3: Captcha Not Switching**
```bash
# Symptom: Always shows same captcha type
# Check detection logic in browser console
# Should log: "Detected access method: local" or "domain"

# Verify environment variables in container
docker exec frontend env | grep REACT_APP_KONG
```

### **Issue 4: Database Connection Lost**
```bash
# Symptom: Contact form fails with database error
# Check MongoDB container
docker logs mongodb

# Restore from backup if needed
docker exec -i mongodb mongorestore /backup/mongodb_backup
```

## ✅ **Post-Migration Validation**

### **1. Functional Tests**
```bash
# Test all access methods
curl -f http://192.168.86.75:3400/
curl -k -f https://192.168.86.75:3443/

# Test contact form with both captcha types
# Local math captcha
curl -X POST http://192.168.86.75:3001/api/contact/send-email \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@example.com","message":"Test math captcha","local_captcha":"{\"type\":\"local_captcha\",\"user_answer\":\"42\"}"}'

# Domain reCAPTCHA (requires valid token)
curl -X POST https://portfolio.architecturesolutions.co.uk/api/contact/send-email \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{"name":"Test","email":"test@example.com","message":"Test reCAPTCHA","recaptcha_token":"valid_token_here"}'
```

### **2. Performance Tests**
```bash
# Check response times
time curl -s http://192.168.86.75:3001/api/health
time curl -s -k https://192.168.86.75:8443/api/health

# Should be:
# Direct backend: < 200ms
# Kong proxy: < 250ms
```

### **3. Security Validation**
```bash
# Test rate limiting
for i in {1..10}; do
  curl -X POST http://192.168.86.75:3001/api/contact/send-email \
    -H "Content-Type: application/json" \
    -d '{"name":"Rate Test","email":"test@example.com","message":"Testing rate limit"}'
done
# Should get 429 after 5 requests
```

## 🎯 **Migration Success Criteria**

- ✅ **All Access Methods Working**: HTTP, HTTPS, and domain access functional
- ✅ **Dual Captcha Active**: Math captcha for local, reCAPTCHA for domain
- ✅ **Kong Integration**: HTTPS proxy routing correctly
- ✅ **Email Delivery**: SMTP working across all access methods
- ✅ **Monitoring Active**: All dashboards accessible and collecting data
- ✅ **Performance Maintained**: Response times within acceptable limits
- ✅ **Security Enhanced**: Rate limiting, CORS, and input validation active

## 📚 **Next Steps After Migration**

1. **Update Bookmarks**: Update any saved URLs to new access methods
2. **Configure Monitoring Alerts**: Set up email notifications for issues
3. **Update Documentation**: Document any environment-specific customizations
4. **Train Users**: Educate users on dual captcha system behavior
5. **Schedule Regular Backups**: Set up automated backup procedures

---

*Successfully migrate to intelligent dual captcha security with Kong API Gateway integration*