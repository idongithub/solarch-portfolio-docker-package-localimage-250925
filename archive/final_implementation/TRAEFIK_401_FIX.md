# 🔧 Fix 401 Unauthorized Error

## Progress ✅
- ✅ Traefik routing is now working (no more frontend HTML)
- ✅ API requests are reaching the backend
- ❌ Getting "401 Unauthorized" instead of successful response

## Root Cause Analysis

The 401 error suggests one of these issues:

### 1. Authentication Middleware in Traefik
Check if your current Traefik configuration has any authentication middleware:

```toml
# Remove any auth middleware from API router
[http.routers.portfolio-api]
  rule = "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
  service = "portfolio-backend"
  priority = 200
  [http.routers.portfolio-api.tls]
  # middlewares = ["auth-basic"]  # REMOVE THIS LINE IF PRESENT
```

### 2. Missing CORS Headers
Add CORS middleware back to handle cross-origin requests:

```toml
[http.routers.portfolio-api]
  rule = "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
  service = "portfolio-backend"
  priority = 200
  [http.routers.portfolio-api.tls]
  middlewares = ["cors-headers"]  # Add CORS back

# CORS Middleware
[http.middlewares.cors-headers.headers]
  accessControlAllowOriginList = ["https://portfolio.architecturesolutions.co.uk"]
  accessControlAllowMethods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  accessControlAllowHeaders = ["Content-Type", "Authorization", "X-Requested-With"]
  accessControlMaxAge = 100
  addVaryHeader = true
```

### 3. Missing Headers
The backend might expect specific headers. Try testing with:

```bash
# Test with proper headers
curl -H "Host: portfolio.architecturesolutions.co.uk" \
     -H "Origin: https://portfolio.architecturesolutions.co.uk" \
     -H "User-Agent: Mozilla/5.0" \
     https://portfolio.architecturesolutions.co.uk/api/health
```

## Quick Diagnostic Tests

### Test 1: Check if it's a Traefik auth issue
```bash
# Bypass Traefik authentication (if any)
curl -u "username:password" https://portfolio.architecturesolutions.co.uk/api/health
```

### Test 2: Check backend directly from Traefik server
```bash
# From your Traefik server (192.168.86.56), test direct backend
curl http://192.168.86.75:3001/api/health
```

### Test 3: Check Traefik dashboard
If you have Traefik dashboard enabled, check:
- `http://192.168.86.56:8080` (or your dashboard port)
- Look for the service status and middleware

## Recommended Fix

Update your Traefik `dynamic.toml` with this clean configuration:

```toml
# API Router (no auth middleware)
[http.routers.portfolio-api]
  rule = "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
  service = "portfolio-backend"
  priority = 200
  [http.routers.portfolio-api.tls]
  middlewares = ["cors-headers"]

# Frontend Router
[http.routers.portfolio-frontend]
  rule = "Host(`portfolio.architecturesolutions.co.uk`)"
  service = "portfolio-frontend"
  priority = 100
  [http.routers.portfolio-frontend.tls]

# Services
[http.services.portfolio-backend]
  [http.services.portfolio-backend.loadBalancer]
    [[http.services.portfolio-backend.loadBalancer.servers]]
      url = "http://192.168.86.75:3001"

[http.services.portfolio-frontend]
  [http.services.portfolio-frontend.loadBalancer]
    [[http.services.portfolio-frontend.loadBalancer.servers]]
      url = "http://192.168.86.75:3400"

# CORS Headers (no authentication)
[http.middlewares.cors-headers.headers]
  accessControlAllowOriginList = ["https://portfolio.architecturesolutions.co.uk"]
  accessControlAllowMethods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  accessControlAllowHeaders = ["Content-Type", "Authorization", "X-Requested-With"]
```

## Expected Result After Fix

```bash
curl https://portfolio.architecturesolutions.co.uk/api/health
# Should return: {"status":"healthy","timestamp":"..."}
```

The key is removing any authentication middleware from the API router while keeping CORS headers for proper cross-origin handling.