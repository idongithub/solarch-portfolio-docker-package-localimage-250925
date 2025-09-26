# 🔧 Working Traefik Configuration

## Confirmed Working Endpoints
- ✅ Backend: `http://192.168.86.75:3001/api/health` (working)
- ✅ Frontend: `http://192.168.86.75:3400` (assumed working)

## Simplified Traefik Configuration

Since your backend is working on port 3001, use this **simplified** configuration in your `dynamic.toml`:

```toml
# Portfolio API Router (MUST come first - higher priority)
[http.routers.portfolio-api]
  rule = "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
  service = "portfolio-backend"
  priority = 200
  [http.routers.portfolio-api.tls]

# Portfolio Frontend Router (lower priority)
[http.routers.portfolio-frontend]
  rule = "Host(`portfolio.architecturesolutions.co.uk`)"
  service = "portfolio-frontend"
  priority = 100
  [http.routers.portfolio-frontend.tls]

# Backend Service
[http.services.portfolio-backend]
  [http.services.portfolio-backend.loadBalancer]
    [[http.services.portfolio-backend.loadBalancer.servers]]
      url = "http://192.168.86.75:3001"

# Frontend Service
[http.services.portfolio-frontend]
  [http.services.portfolio-frontend.loadBalancer]
    [[http.services.portfolio-frontend.loadBalancer.servers]]
      url = "http://192.168.86.75:3400"
```

## Key Changes Made:
1. **Simplified service names** (removed complex naming)
2. **Higher priority for API** (200 vs 100)
3. **Removed middlewares** temporarily to eliminate complexity
4. **Clean routing rules**

## Debug Steps:

### 1. Test Traefik Rules (after updating config and restarting Traefik):

```bash
# Test API routing specifically
curl -H "Host: portfolio.architecturesolutions.co.uk" \
     http://192.168.86.56:81/api/health

# If that works, then test HTTPS
curl https://portfolio.architecturesolutions.co.uk/api/health
```

### 2. Check Traefik Logs:
Look for routing decisions in your Traefik logs when the request comes in.

### 3. Alternative Test:
```bash
# Test with explicit headers
curl -H "Host: portfolio.architecturesolutions.co.uk" \
     -H "X-Forwarded-Proto: https" \
     http://192.168.86.75:3001/api/health
```

## If Still Not Working:

### Option 1: Test with HTTP first
```toml
# Temporarily test without TLS
[http.routers.portfolio-api-http]
  rule = "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
  service = "portfolio-backend"
  entryPoints = ["web"]  # HTTP port 81
  priority = 200
```

### Option 2: Check if it's a TLS issue
Make sure your Traefik has the wildcard certificate properly configured for `*.architecturesolutions.co.uk`.

## Expected Result:
```bash
curl https://portfolio.architecturesolutions.co.uk/api/health
# Should return: {"status":"healthy","timestamp":"..."}
```

Try this simplified configuration first and let me know the results!