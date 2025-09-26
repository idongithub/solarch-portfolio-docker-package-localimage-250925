# Traefik Configuration Copy Instructions

## 🚀 Quick Setup for Your Existing Traefik

After deploying with `--domain subdomain`, copy these sections to your existing Traefik configuration:

### 1. Copy from `/app/traefik/traefik.toml` to your `traefik.toml`:

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
```

### 2. Copy from `/app/traefik/dynamic.toml` to your `dynamic.toml`:

```toml
# Portfolio Frontend Router
[http.routers.portfolio-frontend]
  rule = "Host(`portfolio.architecturesolutions.co.uk`)"
  service = "portfolio-frontend-service"
  [http.routers.portfolio-frontend.tls]
  middlewares = ["security-headers", "compress"]

# Portfolio API Router  
[http.routers.portfolio-api]
  rule = "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
  service = "portfolio-backend-service"
  [http.routers.portfolio-api.tls]
  middlewares = ["security-headers", "cors-headers"]

# Services
[http.services.portfolio-frontend-service.loadBalancer]
  [[http.services.portfolio-frontend-service.loadBalancer.servers]]
    url = "http://192.168.86.75:3400"

[http.services.portfolio-backend-service.loadBalancer]
  [[http.services.portfolio-backend-service.loadBalancer.servers]]
    url = "http://192.168.86.75:3001"

# CORS Middleware
[http.middlewares.cors-headers.headers]
  accessControlAllowOriginList = ["https://portfolio.architecturesolutions.co.uk"]
  accessControlAllowMethods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  accessControlAllowHeaders = ["Content-Type", "Authorization", "X-Requested-With"]
```

### 3. Replace subdomain name as needed:
- Change `portfolio.architecturesolutions.co.uk` to match your `--domain` parameter
- If you used `--domain staging`, change to `staging.architecturesolutions.co.uk`

### 4. Restart your Traefik binary to load new configuration

## 🎯 Your Deployment Commands:

```bash
# Deploy with portfolio subdomain
./scripts/deploy-with-params.sh \
  --domain portfolio \
  --http-port 3400 --https-port 3443 --backend-port 3001 \
  --smtp-server smtp.ionos.co.uk --smtp-port 465 \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password NewPass6 --smtp-use-ssl true \
  --from-email kamal.singh@architecturesolutions.co.uk \
  --to-email kamal.singh@architecturesolutions.co.uk \
  --ga-measurement-id G-B2W705K4SN \
  --mongo-express-port 3081 --mongo-express-username admin \
  --mongo-express-password admin123 --mongo-port 37037 \
  --mongo-username admin --mongo-password securepass123 \
  --grafana-password adminpass123 --redis-password redispass123 \
  --grafana-port 3030 --loki-port 3300 --prometheus-port 3091

# Then access: https://portfolio.architecturesolutions.co.uk
```

That's it! Your existing workflow remains the same, just add `--domain subdomain` when you want domain access.