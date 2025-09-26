# 🔧 Traefik CORS Multiple Origins Fix

## Problem Identified ✅
- ✅ Backend CORS configuration is CORRECT
- ✅ Backend returns proper CORS headers for all origins  
- ❌ Traefik external proxy is filtering CORS headers for IP-based origins

## Root Cause
Your Traefik middleware is currently only allowing same-domain CORS but blocking cross-origin requests from IP addresses.

## Solution: Update Traefik Dynamic Configuration

Replace your current CORS middleware in `dynamic.toml` with this corrected version:

```toml
# CORRECTED: CORS Headers Middleware for Multiple Origins
[http.middlewares.cors-headers.headers]
  # Allow multiple specific origins (including IP addresses)
  accessControlAllowOriginList = [
    "https://portfolio.architecturesolutions.co.uk",
    "http://192.168.86.75:3400",
    "https://192.168.86.75:3443"
  ]
  
  # Allow required HTTP methods
  accessControlAllowMethods = [
    "GET", 
    "POST", 
    "PUT", 
    "DELETE", 
    "OPTIONS"
  ]
  
  # Allow required headers
  accessControlAllowHeaders = [
    "Content-Type",
    "Authorization", 
    "X-Requested-With",
    "Accept",
    "Origin"
  ]
  
  # Enable credentials (required for cookies/auth)
  accessControlAllowCredentials = true
  
  # Cache preflight requests for 24 hours
  accessControlMaxAge = 86400
  
  # Add Vary header for proper caching
  addVaryHeader = true
  
  # Custom headers for HTTPS forwarding
  [http.middlewares.cors-headers.headers.customRequestHeaders]
    X-Forwarded-Proto = "https"

# API Router with CORS middleware
[http.routers.portfolio-api]
  rule = "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
  service = "portfolio-backend"
  priority = 200
  [http.routers.portfolio-api.tls]
  middlewares = ["cors-headers"]  # Apply CORS middleware

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
```

## Key Changes Made:

1. **`accessControlAllowOriginList`**: Now explicitly lists all allowed origins including IP addresses
2. **`accessControlAllowCredentials = true`**: Enables credentials for authenticated requests
3. **`accessControlMaxAge = 86400`**: Caches preflight requests for 24 hours  
4. **`addVaryHeader = true`**: Ensures proper caching behavior across origins

## Why This Fixes the Issue:

- **Before**: Traefik was filtering out CORS headers for cross-origin IP requests
- **After**: Traefik will explicitly allow and forward CORS headers for all listed origins

## Testing After Update:

1. **Update your Traefik configuration** with the above middleware
2. **Restart Traefik** to load new configuration
3. **Rebuild and redeploy** frontend containers (they need the updated SimpleContact.jsx)
4. **Test from all URLs**:
   - ✅ https://portfolio.architecturesolutions.co.uk/contact  
   - ✅ http://192.168.86.75:3400/contact
   - ✅ https://192.168.86.75:3443/contact

## Verification Commands:

```bash
# Test CORS preflight for IP origins
curl -X OPTIONS https://portfolio.architecturesolutions.co.uk/api/contact/send-email \
  -H "Origin: http://192.168.86.75:3400" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v

# Should return CORS headers allowing the IP origin
```

This configuration will resolve the CORS blocking issue for IP-based frontend access while maintaining security by explicitly listing allowed origins.