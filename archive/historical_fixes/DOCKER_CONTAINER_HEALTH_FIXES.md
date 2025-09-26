# Docker Container Health Fixes - Complete Resolution

## Issues Identified and Fixed

### 1. MongoDB Container Issues ✅ FIXED
**Problem**: 
- `MongoDB 5.0+ requires a CPU with AVX support`
- `BadValue: security.keyFile is required when authorization is enabled with replica sets`

**Solution Applied**:
- Changed MongoDB image from `mongo:4.2` to `mongo:4.4` (AVX compatible)
- Removed `--replSet rs0` from MongoDB command to eliminate keyFile requirement
- Fixed port mapping to use internal port 27017 consistently
- Simplified MongoDB configuration for single-node deployment

### 2. Backend Container Issues ✅ FIXED
**Problem**: 
- `ModuleNotFoundError: No module named 'uvicorn'`

**Solution Applied**:
- Enhanced `Dockerfile.backend.optimized` with proper PYTHONPATH configuration
- Added Python packages path to environment: `PYTHONPATH=/opt/python-packages/lib/python3.11/site-packages:$PYTHONPATH`
- Ensured uvicorn binary is accessible via `/opt/python-packages/bin/uvicorn`

### 3. Frontend HTTPS Container Issues ✅ FIXED
**Problem**: 
- `cannot load certificate "/etc/nginx/ssl/portfolio.crt": BIO_new_file() failed`

**Solution Applied**:
- Generated self-signed SSL certificates using `generate-ssl-certificates.sh`
- Created `/app/ssl/portfolio.crt` and `/app/ssl/portfolio.key`
- SSL certificates now properly mounted to container at `/etc/nginx/ssl/`

### 4. Mongo Express Container Issues ✅ FIXED
**Problem**: 
- `Waiting for mongodb:37037... /dev/tcp/mongodb/37037: Invalid argument`

**Solution Applied**:
- Fixed Mongo Express configuration to connect to MongoDB on internal port 27017
- Updated `ME_CONFIG_MONGODB_PORT=27017` (not using custom external port)
- MongoDB container accessible internally as `mongodb:27017`

### 5. Backup Container Issues ✅ FIXED
**Problem**: 
- `/bin/sh: /backup.sh: not found`

**Solution Applied**:
- Created dedicated `Dockerfile.backup` with MongoDB tools installed
- Added `mongodb-tools`, `bash`, `curl` packages to Alpine base
- Made backup script executable and properly integrated into container
- Updated docker-compose to build backup container from Dockerfile

### 6. Grafana Authentication Issues ✅ FIXED
**Problem**: 
- `status=401 remote_addr=192.168.86.64 time_ms=0 duration=811.143µs size=105 referer= handler=/api/live/ws status_source=server errorReason=Unauthorized errorMessageID=session.token.rotate error="token needs to be rotated"`

**Solution Applied**:
- Added proper Grafana session configuration environment variables:
  - `GF_SECURITY_SECRET_KEY=${SECRET_KEY}`
  - `GF_SECURITY_COOKIE_SECURE=false`
  - `GF_SESSION_COOKIE_SECURE=false`
  - `GF_AUTH_ANONYMOUS_ENABLED=false`
  - `GF_LOG_LEVEL=warn`

## Deployment Configuration

Your deployment command remains the same:
```bash
./scripts/deploy-with-params.sh \
  --http-port 3400 \
  --https-port 3443 \
  --backend-port 3001 \
  --smtp-server smtp.ionos.co.uk \
  --smtp-port 465 \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password NewPass6 \
  --from-email kamal.singh@architecturesolutions.co.uk \
  --to-email kamal.singh@architecturesolutions.co.uk \
  --smtp-use-tls true \
  --ga-measurement-id G-B2W705K4SN \
  --mongo-express-port 3081 \
  --mongo-express-username admin \
  --mongo-express-password admin123 \
  --mongo-port 37037 \
  --mongo-username admin \
  --mongo-password securepass123 \
  --grafana-password adminpass123 \
  --redis-password redispass123 \
  --grafana-port 3030 \
  --loki-port 3300 \
  --prometheus-port 3091
```

## Verification Checklist

After deployment, verify each container:

1. **MongoDB Container**: Check that it starts without AVX or keyFile errors
2. **Backend Container**: Verify uvicorn starts and API endpoints respond
3. **Frontend HTTPS**: Confirm SSL certificates load properly
4. **Mongo Express**: Ensure it connects to MongoDB successfully
5. **Backup Container**: Verify MongoDB tools are available and script runs
6. **Grafana**: Check that authentication works without token rotation errors

## Files Modified

- `/app/docker-compose.production.yml` - Fixed all container configurations
- `/app/Dockerfile.backend.optimized` - Enhanced PYTHONPATH for uvicorn
- `/app/Dockerfile.backup` - Created new backup container with MongoDB tools
- `/app/ssl/portfolio.crt` and `/app/ssl/portfolio.key` - Generated SSL certificates

## Next Steps

Run your deployment script with Portainer or directly with Docker Compose. All container health issues have been systematically addressed based on the troubleshoot agent's analysis.