# Traefik DNS Setup Guide - architecturesolutions.co.uk

Complete guide for setting up Kamal Singh Portfolio with existing Traefik binary and architecturesolutions.co.uk domain.

## 🎯 Overview

This setup leverages your existing Traefik configuration:
- **Domain**: portfolio.architecturesolutions.co.uk
- **Traefik**: Binary running on 192.168.86.56 (ports 81/434)
- **SSL**: Existing wildcard certificate from IONOS
- **Format**: TOML configuration files

## 🏗️ Architecture

```
Internet → DNS → ISP Router → Traefik Binary (192.168.86.56:81/434) → Portfolio Server
                                     ↓                                        ↓
                            SSL Termination                          Docker Containers
                            (IONOS Wildcard Cert)                    (HTTP ports only)
```

## 📋 Prerequisites

1. ✅ **Domain**: architecturesolutions.co.uk (already owned)
2. ✅ **Traefik**: Binary running on 192.168.86.56
3. ✅ **SSL Certificate**: IONOS wildcard for *.architecturesolutions.co.uk
4. ✅ **Custom Ports**: HTTP 81, HTTPS 434
5. ✅ **Configuration**: TOML format preferred

## 🚀 Step-by-Step Setup

### Step 1: Deploy Portfolio with Domain Configuration

On your **Portfolio Server**:

```bash
# Deploy with portfolio subdomain
./scripts/deploy-with-domain.sh \
  --domain portfolio \
  --http-port 3400 \
  --https-port 3443 \
  --backend-port 3001 \
  --smtp-server smtp.ionos.co.uk \
  --smtp-port 465 \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password NewPass6 \
  --smtp-use-ssl true \
  --mongo-password securepass123 \
  --grafana-password adminpass123 \
  --redis-password redispass123

# This creates: portfolio.architecturesolutions.co.uk
```

### Step 2: Update Your Traefik Configuration

The deployment script generates TOML configurations. Add this content to your existing Traefik files:

#### Add to your `traefik.toml`:

```toml
[entryPoints]
  [entryPoints.web]
    address = ":81"
    [entryPoints.web.http]
      [entryPoints.web.http.redirections]
        [entryPoints.web.http.redirections.entryPoint]
          to = "websecure"
          scheme = "https"
          permanent = true

  [entryPoints.websecure]
    address = ":434"

[providers]
  [providers.file]
    filename = "/path/to/your/dynamic.toml"
    watch = true
```

#### Add to your `dynamic.toml`:

```toml
[http.routers.portfolio-frontend]
  rule = "Host(`portfolio.architecturesolutions.co.uk`)"
  service = "portfolio-frontend-service"
  [http.routers.portfolio-frontend.tls]
  middlewares = ["security-headers", "compress"]

[http.routers.portfolio-api]
  rule = "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
  service = "portfolio-backend-service"
  [http.routers.portfolio-api.tls]
  middlewares = ["security-headers", "cors-headers"]

[http.services.portfolio-frontend-service.loadBalancer]
  [[http.services.portfolio-frontend-service.loadBalancer.servers]]
    url = "http://192.168.86.75:3400"

[http.services.portfolio-backend-service.loadBalancer]
  [[http.services.portfolio-backend-service.loadBalancer.servers]]
    url = "http://192.168.86.75:3001"

[http.middlewares.cors-headers.headers]
  accessControlAllowOriginList = ["https://portfolio.architecturesolutions.co.uk"]
  accessControlAllowMethods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  accessControlAllowHeaders = ["Content-Type", "Authorization", "X-Requested-With"]
```

### Step 3: Configure DNS (If Not Already Done)

Ensure DNS record exists:
```
Type    Name                                    Value
A       portfolio.architecturesolutions.co.uk  YOUR_PUBLIC_IP
```

### Step 4: Restart Traefik Binary

```bash
# On your Traefik server (192.168.86.56)
sudo systemctl restart traefik
# or however you restart your Traefik binary
```

### Step 5: Verify Setup

```bash
# Test domain resolution
nslookup portfolio.architecturesolutions.co.uk

# Test HTTP redirect to HTTPS (port 81 → 434)
curl -I http://portfolio.architecturesolutions.co.uk:81

# Test HTTPS access (port 434)
curl -I https://portfolio.architecturesolutions.co.uk:434

# Test API access
curl https://portfolio.architecturesolutions.co.uk:434/api/health

# Test without port (if ISP forwards standard ports)
curl -I https://portfolio.architecturesolutions.co.uk
```

## 🔧 Configuration Details

### Frontend Configuration
```bash
# Generated automatically by deploy-with-domain.sh
REACT_APP_BACKEND_URL=https://portfolio.architecturesolutions.co.uk
WDS_SOCKET_PORT=443
```

### Backend CORS Configuration
```bash
# Updated automatically by deploy-with-domain.sh
CORS_ORIGINS=https://portfolio.architecturesolutions.co.uk,http://localhost:3400,https://localhost:3443
```

### Traefik Routing
- `portfolio.architecturesolutions.co.uk/*` → Frontend (192.168.86.56:3400)
- `portfolio.architecturesolutions.co.uk/api/*` → Backend (192.168.86.56:3001)
- SSL termination at Traefik using existing IONOS wildcard certificate

## 🛠️ Troubleshooting

### Common Issues

**1. Custom Ports Not Accessible**
```bash
# Check if ISP forwards ports 81/434 to your Traefik
# You may need to access with explicit ports:
https://portfolio.architecturesolutions.co.uk:434

# Or configure port forwarding: 80→81, 443→434
```

**2. SSL Certificate Issues**
```bash
# Verify your existing wildcard certificate covers:
# *.architecturesolutions.co.uk
# Should include portfolio.architecturesolutions.co.uk
```

**3. Backend API Not Accessible**
```bash
# Test direct backend access from Traefik server
curl http://192.168.86.56:3001/api/health

# Check CORS configuration
grep CORS_ORIGINS /app/backend/.env
```

**4. Traefik Configuration Not Loading**
```bash
# Check Traefik logs for configuration errors
# Verify file paths in traefik.toml
# Ensure dynamic.toml syntax is correct
```

## 📝 Additional Subdomains

To add more subdomains (e.g., `monitoring.architecturesolutions.co.uk`):

```bash
# Deploy monitoring subdomain
./scripts/deploy-with-domain.sh --domain monitoring --grafana-password admin123

# Add to dynamic.toml:
[http.routers.monitoring-grafana]
  rule = "Host(`monitoring.architecturesolutions.co.uk`)"
  service = "monitoring-grafana-service"
  [http.routers.monitoring-grafana.tls]
```

## 🎉 Success Verification

Once setup is complete:

1. **Portfolio Access**: https://portfolio.architecturesolutions.co.uk:434
2. **API Health**: https://portfolio.architecturesolutions.co.uk:434/api/health
3. **Contact Form**: Submit and verify email delivery
4. **SSL Certificate**: Green lock (IONOS wildcard)
5. **Performance**: Fast loading with Traefik caching

## 🔐 Security Notes

1. **SSL Termination**: At Traefik using existing IONOS certificate
2. **Internal Traffic**: HTTP only between Traefik and containers
3. **Custom Ports**: May provide additional security through obscurity
4. **CORS**: Restricted to specific domain
5. **Headers**: Security headers added by Traefik middlewares

---

Your portfolio is now accessible via https://portfolio.architecturesolutions.co.uk with professional SSL and domain routing! 🎉

## 🚀 Quick Commands Reference

```bash
# Deploy portfolio subdomain
./scripts/deploy-with-domain.sh --domain portfolio --mongo-password pass123 --grafana-password admin123

# Test deployment
curl -I https://portfolio.architecturesolutions.co.uk:434
curl https://portfolio.architecturesolutions.co.uk:434/api/health

# Check containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# View logs
docker logs portfolio-frontend-http
docker logs portfolio-backend
```