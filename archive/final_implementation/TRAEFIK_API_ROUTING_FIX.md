# 🚨 CRITICAL: Traefik API Routing Fix

## Problem Identified
- **Backend email functionality is working perfectly** ✅
- **External domain API routing is broken** ❌
- `https://portfolio.architecturesolutions.co.uk/api` returns frontend HTML instead of backend API

## Solution: Add These Rules to Your Traefik dynamic.toml

Add these **EXACT** routing rules to your existing `dynamic.toml` file:

```toml
# CRITICAL: API routing must come BEFORE frontend routing
# This ensures /api/* requests go to backend, not frontend

[http.routers.portfolio-api]
  rule = "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
  service = "portfolio-backend-service"
  priority = 100  # Higher priority than frontend router
  [http.routers.portfolio-api.tls]
  middlewares = ["security-headers", "cors-headers"]

[http.routers.portfolio-frontend]
  rule = "Host(`portfolio.architecturesolutions.co.uk`)"
  service = "portfolio-frontend-service"
  priority = 50   # Lower priority than API router
  [http.routers.portfolio-frontend.tls]
  middlewares = ["security-headers", "compress"]

# Services
[http.services.portfolio-backend-service.loadBalancer]
  [[http.services.portfolio-backend-service.loadBalancer.servers]]
    url = "http://192.168.86.75:3001"  # Your Ubuntu Docker backend
  [http.services.portfolio-backend-service.loadBalancer.healthCheck]
    path = "/api/health"
    interval = "10s"
    timeout = "3s"

[http.services.portfolio-frontend-service.loadBalancer]
  [[http.services.portfolio-frontend-service.loadBalancer.servers]]
    url = "http://192.168.86.75:3400"  # Your Ubuntu Docker frontend
  [http.services.portfolio-frontend-service.loadBalancer.healthCheck]
    path = "/"
    interval = "10s"
    timeout = "3s"

# CORS Middleware for API
[http.middlewares.cors-headers.headers]
  accessControlAllowOriginList = ["https://portfolio.architecturesolutions.co.uk"]
  accessControlAllowMethods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  accessControlAllowHeaders = ["Content-Type", "Authorization", "X-Requested-With"]
  accessControlMaxAge = 100
  addVaryHeader = true

# Security Headers
[http.middlewares.security-headers.headers]
  [http.middlewares.security-headers.headers.customRequestHeaders]
    X-Forwarded-Proto = "https"
  [http.middlewares.security-headers.headers.customResponseHeaders]
    X-Frame-Options = "SAMEORIGIN"
    X-Content-Type-Options = "nosniff"
    X-XSS-Protection = "1; mode=block"

# Compression
[http.middlewares.compress.compress]
  excludedContentTypes = ["text/event-stream"]
```

## Key Points:

1. **Priority is CRITICAL**: API router (priority=100) must be higher than frontend router (priority=50)
2. **PathPrefix `/api`**: This ensures all `/api/*` requests go to backend
3. **Backend Service**: Points to `192.168.86.75:3001` (your Ubuntu Docker backend)
4. **Frontend Service**: Points to `192.168.86.75:3400` (your Ubuntu Docker frontend)

## After Adding These Rules:

1. Restart your Traefik binary
2. Test: `curl https://portfolio.architecturesolutions.co.uk/api/health`
3. Should return: `{"status":"healthy","timestamp":"..."}`

## Verification Commands:

```bash
# Test backend API (should work)
curl https://portfolio.architecturesolutions.co.uk/api/health

# Test frontend (should work)  
curl https://portfolio.architecturesolutions.co.uk/

# Test email endpoint (should work after Traefik fix)
curl -X POST https://portfolio.architecturesolutions.co.uk/api/contact/send-email \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@test.com","message":"Test message"}'
```

**The email functionality is already working on the backend - this Traefik fix will resolve the external domain access issue.**