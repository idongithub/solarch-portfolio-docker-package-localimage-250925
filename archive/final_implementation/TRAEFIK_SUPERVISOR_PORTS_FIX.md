# 🚨 CRITICAL: Correct Supervisor Deployment Ports

## Architecture Clarification
You're **NOT** using Docker containers. Services are running directly via **supervisor**:

- ✅ **Frontend**: `192.168.86.75:3000` (running via supervisor)
- ✅ **Backend**: `192.168.86.75:8001` (running via supervisor)  
- ✅ **MongoDB**: `192.168.86.75:27017` (running directly)

## Corrected Traefik Configuration

Update your `dynamic.toml` with the **actual supervisor ports**:

```toml
# API routing (higher priority)
[http.routers.portfolio-api]
  rule = "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
  service = "portfolio-backend-service"
  priority = 100
  [http.routers.portfolio-api.tls]
  middlewares = ["cors-headers"]

# Frontend routing (lower priority)
[http.routers.portfolio-frontend]
  rule = "Host(`portfolio.architecturesolutions.co.uk`)"
  service = "portfolio-frontend-service"
  priority = 50
  [http.routers.portfolio-frontend.tls]

# CORRECTED: Backend service (supervisor port 8001)
[http.services.portfolio-backend-service.loadBalancer]
  [[http.services.portfolio-backend-service.loadBalancer.servers]]
    url = "http://192.168.86.75:8001"  # Actual backend port
  [http.services.portfolio-backend-service.loadBalancer.healthCheck]
    path = "/api/health"
    interval = "10s"
    timeout = "3s"

# CORRECTED: Frontend service (supervisor port 3000)
[http.services.portfolio-frontend-service.loadBalancer]
  [[http.services.portfolio-frontend-service.loadBalancer.servers]]
    url = "http://192.168.86.75:3000"  # Actual frontend port
  [http.services.portfolio-frontend-service.loadBalancer.healthCheck]
    path = "/"
    interval = "10s"
    timeout = "3s"

# CORS middleware for API
[http.middlewares.cors-headers.headers]
  accessControlAllowOriginList = ["https://portfolio.architecturesolutions.co.uk"]
  accessControlAllowMethods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  accessControlAllowHeaders = ["Content-Type", "Authorization", "X-Requested-With"]
  accessControlMaxAge = 100
  addVaryHeader = true
```

## Verification Commands

Before Traefik update:
```bash
# Test backend directly (should work)
curl http://192.168.86.75:8001/api/health
# Expected: {"status":"healthy","timestamp":"..."}

# Test frontend directly (should work)
curl http://192.168.86.75:3000
# Expected: HTML content
```

After Traefik update:
```bash
# Test via domain (should work after Traefik restart)
curl https://portfolio.architecturesolutions.co.uk/api/health
# Expected: {"status":"healthy","timestamp":"..."}
```

## Action Required

1. **Update your Traefik dynamic.toml** with ports **8001** (backend) and **3000** (frontend)
2. **Restart your Traefik binary**  
3. **Test the API endpoint**

## Port Summary (Supervisor Deployment)
- **Frontend**: `192.168.86.75:3000` ✅
- **Backend**: `192.168.86.75:8001` ✅  
- **MongoDB**: `192.168.86.75:27017` ✅

This should resolve the API routing issue completely!