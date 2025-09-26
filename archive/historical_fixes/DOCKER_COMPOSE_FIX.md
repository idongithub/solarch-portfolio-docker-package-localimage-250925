# Docker Compose Version Compatibility Fix

## Issue Resolved

Fixed the Docker Compose version compatibility error:
```
ERROR: Version in "./docker-compose.production.yml" is unsupported. You might be seeing this error because you're using the wrong Compose file version.
```

## Changes Made

### 1. **Updated Docker Compose Version**
- Changed from `version: '3.8'` to `version: '3.3'` for broader compatibility

### 2. **Removed Docker Swarm Features**
- Removed all `deploy` sections with `replicas` and `resources` (Docker Swarm only)
- These features don't work with standard `docker-compose up` command

### 3. **Fixed Version 3.3 Compatibility Issues**
- **Removed `name` properties** from volumes and networks (not supported in 3.3)
- **Removed `start_period`** from all healthcheck configurations (not supported in 3.3)
- **Removed `x-deploy-defaults`** section (invalid top-level property)
- **Simplified network configuration** (removed IPAM and custom naming)

### 4. **Fixed Container Images**
- Changed from non-existent GitHub Container Registry images to local builds:
  - `frontend-http`: Uses `Dockerfile.npm.optimized`
  - `frontend-https`: Uses `Dockerfile.https.optimized`  
  - `backend`: Uses `Dockerfile.backend.optimized`

### 5. **Added Direct Port Mappings**
- Removed complex nginx load balancer (missing config files)
- Added direct port mappings to all services:
  - Frontend HTTP: `${HTTP_PORT:-8080}:80`
  - Frontend HTTPS: `${HTTPS_PORT:-8443}:443`
  - Backend: `${BACKEND_PORT:-8001}:8001`
  - MongoDB: `${MONGO_PORT:-27017}:27017`
  - Redis: `${REDIS_PORT:-6379}:6379`
  - Prometheus: `${PROMETHEUS_PORT:-9090}:9090`
  - Grafana: `${GRAFANA_PORT:-3000}:3000`
  - Loki: `${LOKI_PORT:-3100}:3100`

### 6. **Simplified Volume Configuration**
- Removed complex volume driver configurations
- Using simple named volumes for data persistence
- Simplified configuration for better compatibility

### 7. **Simplified Monitoring Configuration**
- Removed references to missing config files (loki-config.yml, promtail-config.yml)
- Kept only essential Prometheus configuration
- Services now use default configurations where custom configs were missing

## How to Deploy

The deployment script now works with older Docker Compose versions:

```bash
# Test the configuration (dry run)
./scripts/deploy-with-params.sh --dry-run --mongo-password securepass123 --grafana-password admin123

# Deploy with default ports
./scripts/deploy-with-params.sh --mongo-password securepass123 --grafana-password admin123

# Deploy with custom ports  
./scripts/deploy-with-params.sh \
  --http-port 3000 --https-port 3443 --backend-port 3001 \
  --grafana-port 3030 --prometheus-port 9091 \
  --mongo-password securepass123 --grafana-password admin123
```

## What Gets Deployed

The fixed `docker-compose.production.yml` now deploys:

### Application Stack
- **Frontend HTTP**: React app on port 8080 (or custom)
- **Frontend HTTPS**: React app with SSL on port 8443 (or custom)
- **Backend API**: FastAPI server on port 8001 (or custom)

### Database Stack  
- **MongoDB**: Database on port 27017 (or custom)
- **Redis**: Cache on port 6379 (or custom)

### Monitoring Stack
- **Prometheus**: Metrics collection on port 9090 (or custom)
- **Grafana**: Dashboards on port 3000 (or custom)
- **Loki**: Log aggregation on port 3100 (or custom)
- **Promtail**: Log shipping
- **Node Exporter**: System metrics

### Infrastructure
- **Backup Service**: Automated database backups
- **Persistent Volumes**: Data retention across restarts

## Access URLs After Deployment

- **Portfolio**: http://localhost:8080 & https://localhost:8443
- **Backend API**: http://localhost:8001/docs
- **Grafana**: http://localhost:3000 (admin/your-password)
- **Prometheus**: http://localhost:9090
- **MongoDB**: mongodb://localhost:27017

## Compatibility

Now works with:
- Docker Compose v1.x
- Docker Compose v2.x (docker-compose command)
- Docker Compose v2.x (docker compose command)
- Older Ubuntu/Debian systems
- Systems without Docker Swarm mode

The deployment is now compatible with standard Docker installations without requiring Docker Swarm or newer Compose versions.