# 🚨 CRITICAL: Backend Port Correction

## Problem Identified
Your backend is running on port **8001**, but your Traefik configuration is pointing to port **3001**.

## Backend Verification
```bash
# This works (backend is on port 8001):
curl http://192.168.86.75:8001/api/health
# Returns: {"status":"healthy","timestamp":"..."}

# This fails (nothing on port 3001):
curl http://192.168.86.75:3001/api/health
# Connection refused
```

## Corrected Traefik Configuration

Update your `dynamic.toml` file with the **correct backend port (8001)**:

```toml
# CORRECTED: Backend service points to port 8001, not 3001
[http.routers.portfolio-api]
  rule = "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
  service = "portfolio-backend-service"
  priority = 100
  [http.routers.portfolio-api.tls]
  middlewares = ["cors-headers"]

[http.routers.portfolio-frontend]
  rule = "Host(`portfolio.architecturesolutions.co.uk`)"
  service = "portfolio-frontend-service"
  priority = 50
  [http.routers.portfolio-frontend.tls]

# CORRECTED: Backend service URL
[http.services.portfolio-backend-service.loadBalancer]
  [[http.services.portfolio-backend-service.loadBalancer.servers]]
    url = "http://192.168.86.75:8001"  # CHANGED from 3001 to 8001
  [http.services.portfolio-backend-service.loadBalancer.healthCheck]
    path = "/api/health"
    interval = "10s"
    timeout = "3s"

# Frontend service (unchanged)
[http.services.portfolio-frontend-service.loadBalancer]
  [[http.services.portfolio-frontend-service.loadBalancer.servers]]
    url = "http://192.168.86.75:3400"
  [http.services.portfolio-frontend-service.loadBalancer.healthCheck]
    path = "/"
    interval = "10s"
    timeout = "3s"

# CORS middleware
[http.middlewares.cors-headers.headers]
  accessControlAllowOriginList = ["https://portfolio.architecturesolutions.co.uk"]
  accessControlAllowMethods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  accessControlAllowHeaders = ["Content-Type", "Authorization", "X-Requested-With"]
  accessControlMaxAge = 100
  addVaryHeader = true
```

## Action Required

1. **Update your Traefik dynamic.toml** with port **8001** instead of **3001**
2. **Restart your Traefik binary**
3. **Test**: `curl https://portfolio.architecturesolutions.co.uk/api/health`

## Expected Result After Fix

```bash
curl https://portfolio.architecturesolutions.co.uk/api/health
# Should return: {"status":"healthy","timestamp":"..."}
```

## Port Summary
- **Frontend**: `192.168.86.75:3400` ✅ (correct)
- **Backend**: `192.168.86.75:8001` ✅ (was incorrectly set to 3001)
- **Grafana**: `192.168.86.75:3030` ✅ (correct)
- **Prometheus**: `192.168.86.75:3091` ✅ (correct)

Once you update the port and restart Traefik, your email functionality should work perfectly!