# 🔧 Troubleshooting Guide - Portfolio Platform

## 🎯 **Quick Diagnosis**

### **System Health Check**
```bash
# Check all services
docker ps | grep -E "(frontend|backend|mongodb|kong)"

# Quick health verification
curl -f http://192.168.86.75:3001/api/health
curl -f http://192.168.86.75:3400/
curl -k -f https://192.168.86.75:3443/

# Kong status (if using HTTPS)
curl -f http://192.168.86.75:8001/status
```

## 🚨 **Common Issues & Solutions**

### **Issue 1: Frontend Not Loading**

#### **Symptoms**
- Browser shows "This site can't be reached"
- Container exists but webpage not accessible
- Docker shows frontend container running

#### **Diagnosis**
```bash
# Check container status
docker ps | grep frontend
docker logs portfolio-frontend-http
docker logs portfolio-frontend-https

# Check port binding
netstat -tlnp | grep -E "(3400|3443)"
```

#### **Solutions**
```bash
# Solution A: Restart frontend containers
docker-compose restart frontend-http frontend-https

# Solution B: Rebuild with fresh environment
docker-compose down
./scripts/deploy-with-params.sh --http-port 3400 --https-port 3443

# Solution C: Check Nginx configuration
docker exec frontend-https cat /etc/nginx/nginx.conf
```

---

### **Issue 2: Kong Connection Refused**

#### **Symptoms**
- HTTPS frontend loads but contact form fails
- Console shows "Failed to fetch" errors
- Mixed content warnings in browser

#### **Diagnosis**  
```bash
# Check Kong service status
curl http://192.168.86.75:8001/status
docker ps | grep kong
sudo systemctl status kong

# Verify Kong configuration
curl -X GET http://192.168.86.75:8001/services
curl -X GET http://192.168.86.75:8001/routes
curl -X GET http://192.168.86.75:8001/plugins
```

#### **Solutions**
```bash
# Solution A: Restart Kong service
sudo systemctl restart kong
# Wait 30 seconds then test
curl http://192.168.86.75:8001/status

# Solution B: Reconfigure Kong services
./scripts/setup-kong.sh  # If available
# Or manually:
curl -X POST http://192.168.86.75:8001/services/ \
  --data "name=portfolio-backend" \
  --data "url=http://192.168.86.75:3001"

curl -X POST http://192.168.86.75:8001/services/portfolio-backend/routes \
  --data "name=portfolio-api-route" \
  --data "paths[]=/api"

# Solution C: Check CORS plugin
curl -X POST http://192.168.86.75:8001/services/portfolio-backend/plugins \
  --data "name=cors" \
  --data "config.origins=https://192.168.86.75:3443"
```

---

### **Issue 3: Environment Variables Not Loading**

#### **Symptoms**
- Frontend shows default Kong settings
- Backend URL points to wrong location
- Captcha type not switching correctly

#### **Diagnosis**
```bash
# Debug environment variables
./scripts/debug-frontend-env.sh

# Check container environment
docker exec frontend-https env | grep REACT_APP_
docker exec backend env | grep -E "(CORS|SMTP|RECAPTCHA)"

# Check deployment script exports
grep -n "export.*REACT_APP" ./scripts/deploy-with-params.sh
```

#### **Solutions**
```bash
# Solution A: Re-run deployment with explicit parameters
./scripts/deploy-with-params.sh \
  --kong-host 192.168.86.75 \
  --kong-port 8443 \
  --recaptcha-site-key "6LcgftMrAAAAAPJRuWA4mQgstPWYoIXoPM4PBjMM"

# Solution B: Manual environment variable fix
# Edit .env files and restart containers
docker-compose restart

# Solution C: Clean rebuild
docker-compose down
docker system prune -a -f
./scripts/deploy-with-params.sh [parameters]
```

---

### **Issue 4: Captcha System Not Working**

#### **Symptoms**
- Math captcha questions not generating
- reCAPTCHA shows "Site key error"
- Form submission returns captcha verification failed

#### **Diagnosis**
```bash
# Check frontend detection logic
# Open browser console and check:
console.log(window.location.hostname.match(/^\d+\.\d+\.\d+\.\d+$/))

# Test backend captcha verification
curl -X POST http://192.168.86.75:3001/api/contact/send-email \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test",
    "email": "test@example.com",
    "message": "Testing captcha",
    "local_captcha": "{\"type\":\"local_captcha\",\"user_answer\":\"12\"}"
  }'

# Check backend logs
docker logs backend | grep -E "(captcha|reCAPTCHA)"
```

#### **Solutions**
```bash
# Solution A: Fix reCAPTCHA configuration
# Verify site key in Google reCAPTCHA console
# Update environment variables:
export REACT_APP_RECAPTCHA_SITE_KEY="correct-site-key"
export RECAPTCHA_SECRET_KEY="correct-secret-key"

# Solution B: Reset math captcha component
# Clear browser cache and reload
# Check LocalCaptcha.jsx implementation

# Solution C: Check CORS for captcha verification
# Ensure reCAPTCHA script can load
# Check CSP headers allow Google domains
```

---

### **Issue 5: Email Delivery Failing**

#### **Symptoms**
- Contact form submits successfully but no email received
- Backend logs show SMTP errors
- "Email service unavailable" message

#### **Diagnosis**
```bash
# Check SMTP configuration
docker exec backend env | grep SMTP_
docker logs backend | grep -E "(SMTP|email|smtp)"

# Test SMTP connectivity
telnet smtp.ionos.co.uk 465
# Should connect successfully

# Check email template generation
curl -X POST http://192.168.86.75:3001/api/contact/send-email \
  -H "Content-Type: application/json" \
  -d '{"name":"SMTP Test","email":"test@example.com","message":"Testing SMTP"}'
```

#### **Solutions**
```bash
# Solution A: Update SMTP credentials
# Verify with email provider:
# - Username/password correct
# - SSL/TLS settings match
# - Port 465 (SSL) or 587 (TLS)

# Solution B: Test different SMTP provider
./scripts/deploy-with-params.sh \
  --smtp-server smtp.gmail.com \
  --smtp-port 587 \
  --smtp-username your-gmail@gmail.com \
  --smtp-password your-app-password

# Solution C: Check firewall/network restrictions
# Ensure outbound SMTP ports are not blocked
sudo ufw status
sudo iptables -L OUTPUT
```

---

### **Issue 6: Database Connection Issues**

#### **Symptoms**
- Contact form fails with database error
- MongoDB GUI not accessible
- Backend logs show connection errors

#### **Diagnosis**
```bash
# Check MongoDB status
docker ps | grep mongodb
docker logs mongodb

# Test database connectivity
curl http://192.168.86.75:8081  # MongoDB GUI
docker exec mongodb mongo --eval "db.stats()"

# Check backend database connection
docker logs backend | grep -i mongo
```

#### **Solutions**
```bash
# Solution A: Restart MongoDB service
docker-compose restart mongodb
# Wait for startup then test GUI access

# Solution B: Check data volume persistence
docker volume ls | grep mongo
# If volume missing, redeploy with data persistence

# Solution C: Reset MongoDB with authentication
docker-compose down
docker volume rm $(docker volume ls -q | grep mongo)
./scripts/deploy-with-params.sh --mongo-password admin123
```

---

### **Issue 7: Performance Issues**

#### **Symptoms**
- Slow response times (> 5 seconds)
- High CPU/memory usage
- Timeouts on API calls

#### **Diagnosis**
```bash
# Check system resources
docker stats
free -h
df -h

# Test response times
time curl -s http://192.168.86.75:3001/api/health
time curl -s -k https://192.168.86.75:8443/api/health

# Check for resource limits
docker exec backend cat /sys/fs/cgroup/memory/memory.limit_in_bytes
```

#### **Solutions**
```bash
# Solution A: Increase container resources
# Edit docker-compose.production.yml:
# resources:
#   limits:
#     memory: 2G
#     cpus: '1.0'

# Solution B: Optimize database queries
# Add indexes to MongoDB
docker exec mongodb mongo portfolio_db --eval "db.contacts.createIndex({email: 1})"

# Solution C: Enable caching
# Add Redis for response caching (advanced)
```

---

## 🔍 **Advanced Debugging**

### **Container Deep Dive**
```bash
# Enter container for debugging
docker exec -it frontend-https /bin/bash
docker exec -it backend /bin/bash
docker exec -it mongodb /bin/bash

# Check internal networking
docker network ls
docker network inspect portfolio-network

# View detailed logs
docker logs --details --since 1h backend
docker logs --follow frontend-https
```

### **Network Debugging**
```bash
# Test internal container communication
docker exec frontend-https wget -qO- http://backend:8001/api/health
docker exec backend wget -qO- http://mongodb:27017

# Check port conflicts
sudo lsof -i -P -n | grep LISTEN
netstat -tlnp | grep -E "(3000|3001|3400|3443|8000|8001|8443|27017)"
```

### **SSL/TLS Debugging**
```bash
# Check SSL certificate validity
openssl s_client -connect 192.168.86.75:3443 -servername 192.168.86.75
openssl s_client -connect portfolio.architecturesolutions.co.uk:443

# Test Kong SSL configuration  
curl -k -v https://192.168.86.75:8443/api/health
```

## 🚨 **Emergency Recovery**

### **Complete System Reset**
```bash
# Nuclear option - complete reset
docker-compose down --volumes --remove-orphans
docker system prune -a --volumes -f
docker network prune -f

# Redeploy from scratch
./scripts/deploy-with-params.sh \
  --http-port 3400 \
  --https-port 3443 \
  --kong-host 192.168.86.75 \
  --kong-port 8443
```

### **Backup Recovery**
```bash
# Restore from previous backup (if available)
docker-compose down
docker volume rm portfolio-mongodb-data

# Restore MongoDB data
docker run --rm -v portfolio-mongodb-data:/data -v $(pwd)/backup:/backup \
  mongo:4.4 mongorestore --host mongodb:27017 /backup/mongodb_backup

# Redeploy
./scripts/deploy-with-params.sh [parameters]
```

## 📊 **Health Monitoring**

### **Automated Health Checks**
```bash
#!/bin/bash
# health-monitor.sh - Run every 5 minutes

# Check all services
services=(
  "http://192.168.86.75:3400/"
  "https://192.168.86.75:3443/"
  "http://192.168.86.75:3001/api/health"
  "http://192.168.86.75:8001/status"
  "http://192.168.86.75:8081/"
)

for service in "${services[@]}"; do
  if ! curl -f -s "$service" > /dev/null; then
    echo "ERROR: $service is not responding"
    # Send alert notification
  fi
done
```

### **Performance Monitoring**
```bash
# Monitor response times
while true; do
  echo "$(date): $(curl -w '%{time_total}' -s -o /dev/null http://192.168.86.75:3001/api/health)s"
  sleep 60
done
```

## 📞 **Getting Help**

### **Log Analysis**
When reporting issues, include:
```bash
# System information
uname -a
docker version
docker-compose version

# Service status
docker ps -a
docker logs backend --tail 50
docker logs frontend-https --tail 50

# Configuration verification
./scripts/debug-frontend-env.sh
env | grep -E "(REACT_APP|KONG|RECAPTCHA|SMTP)"
```

### **Issue Reporting Template**
```markdown
## Issue Description
Brief description of the problem

## Environment
- OS: Ubuntu 20.04
- Docker: 20.10.x
- Kong: 3.4.x (if applicable)

## Steps to Reproduce
1. Run deployment command
2. Access URL
3. Error occurs

## Expected Behavior
What should happen

## Actual Behavior  
What actually happens

## Logs
```
docker logs backend --tail 50
```

## Configuration
```
./scripts/debug-frontend-env.sh output
```
```

---

*Comprehensive troubleshooting for the dual captcha portfolio platform*