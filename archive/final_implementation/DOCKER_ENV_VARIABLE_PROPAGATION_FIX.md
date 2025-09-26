# Docker Environment Variable Propagation Fix

## Issue Summary

**Problem:** The deployment script `deploy-with-params.sh` dynamically modifies environment variables (SMTP, CORS, API security), but running Docker containers were not picking up these changes, causing email functionality and CORS issues.

**Root Cause:** Docker containers get environment variables at startup from docker-compose, which reads from shell environment exports. When the deployment script runs on an already-deployed system, existing containers continue running with their original environment variables unless explicitly recreated.

## Architecture Understanding

- **Full Docker Deployment:** All services run in Docker containers via `docker-compose.production.yml`
- **Environment Variable Flow:** 
  1. Deployment script exports variables to shell
  2. docker-compose reads shell environment variables
  3. Docker containers receive environment variables at startup
  4. Running containers retain original environment until recreation

## Solution Implemented

### 1. Container Recreation Mechanism
Added `FORCE_RECREATE_CONTAINERS` flag to deployment script that triggers when environment variables change:

```bash
# Mark that Docker containers need recreation due to environment variable changes
export FORCE_RECREATE_CONTAINERS="true"
log "🔄 Environment variables updated - Docker containers will be recreated to apply changes"
```

### 2. Docker Force Recreation Logic
Modified BUILD_FLAGS handling to use `--force-recreate` when environment variables change:

```bash
# Add force rebuild option and environment variable recreation
BUILD_FLAGS=""
if [ "$FORCE_REBUILD" = "true" ]; then
    log "🔨 Force rebuilding all images (ignoring cache)..."
    BUILD_FLAGS="--build --force-recreate --no-deps"
elif [ "$FORCE_RECREATE_CONTAINERS" = "true" ]; then
    log "🔄 Force recreating containers due to environment variable changes..."
    BUILD_FLAGS="--force-recreate"
fi
```

### 3. Trigger Points for Container Recreation
The deployment script now sets `FORCE_RECREATE_CONTAINERS=true` when:

- **SMTP Configuration Changes:** SMTP_SERVER, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD, etc.
- **CORS Configuration Changes:** CORS_ORIGINS for domain access
- **API Security Changes:** API_KEY, API_SECRET, API_AUTH_ENABLED

### 4. Removed Obsolete Logic
Replaced supervisorctl restart commands with Docker container recreation:

```bash
# OLD (Removed):
sudo supervisorctl restart backend

# NEW (Implemented):
export FORCE_RECREATE_CONTAINERS="true"
```

## Files Modified

### `/app/scripts/deploy-with-params.sh`
- Added `FORCE_RECREATE_CONTAINERS` flag logic
- Modified BUILD_FLAGS to handle `--force-recreate`
- Added container recreation triggers for SMTP, CORS, and API security changes
- Removed obsolete supervisorctl restart logic

## Docker Configuration Files

### `/app/docker-compose.production.yml` 
Backend service properly configured to use shell environment variables:
```yaml
environment:
  - SMTP_SERVER=${SMTP_SERVER}
  - SMTP_PORT=${SMTP_PORT:-587}
  - CORS_ORIGINS=${CORS_ORIGINS:-https://portfolio.archsol.co.uk}
  # ... other variables
```

### `/app/Dockerfile.backend.optimized`
Contains environment variable defaults that can be overridden by docker-compose.

## Testing & Verification

### Automated Tests Created
- **`test-docker-env-propagation.sh`** - Comprehensive verification of the fix
- All 7 verification steps pass:
  1. ✅ FORCE_RECREATE_CONTAINERS flag implementation
  2. ✅ Environment variable change detection logic
  3. ✅ Docker --force-recreate mechanism
  4. ✅ Docker Compose environment variable configuration
  5. ✅ Backend Dockerfile environment defaults
  6. ✅ Deployment script environment variable exports
  7. ✅ Obsolete supervisor logic removed

### Manual Testing Process
1. Run deployment script with parameters
2. Environment variables are exported to shell
3. FORCE_RECREATE_CONTAINERS flag is set when configs change
4. Docker containers are recreated with new environment variables
5. Email functionality and CORS work with updated configuration

## How the Fix Works

### Before (Problematic Flow):
1. Deployment script modifies environment variables
2. docker-compose up -d runs with new shell environment
3. **Existing containers continue running with old environment variables**
4. Email/CORS functionality uses outdated configuration

### After (Fixed Flow):
1. Deployment script modifies environment variables
2. `FORCE_RECREATE_CONTAINERS="true"` is set
3. docker-compose up -d `--force-recreate` runs
4. **All containers are recreated with updated environment variables**
5. Email/CORS functionality uses current configuration

## Usage Examples

### Deploy with SMTP Configuration Changes
```bash
./scripts/deploy-with-params.sh \
  --smtp-server smtp.ionos.co.uk \
  --smtp-port 465 \
  --smtp-use-ssl true \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password NewPass6 \
  --from-email kamal.singh@architecturesolutions.co.uk \
  --to-email kamal.singh@architecturesolutions.co.uk
```

The script will:
1. Export SMTP environment variables
2. Set `FORCE_RECREATE_CONTAINERS="true"`
3. Recreate backend container with updated SMTP configuration
4. Email functionality will use new SMTP settings immediately

### Deploy with Domain and CORS Changes
```bash
./scripts/deploy-with-params.sh \
  --domain portfolio \
  --http-port 3400 \
  --https-port 3443 \
  --backend-port 3001
```

The script will:
1. Update CORS_ORIGINS with domain and IP access points
2. Set `FORCE_RECREATE_CONTAINERS="true"`
3. Recreate containers with updated CORS configuration
4. Backend will accept requests from all configured origins

## Benefits

1. **Immediate Configuration Updates:** Environment variable changes take effect immediately
2. **No Manual Intervention:** Automatic container recreation when needed
3. **Reliable Email Functionality:** SMTP changes are applied without manual restarts
4. **Proper CORS Handling:** Domain and IP access work correctly after deployment
5. **Production Ready:** Works with full Docker containerized deployment

## Status: ✅ RESOLVED → 🌉 SUPERSEDED BY KONG INTEGRATION

The Docker environment variable propagation issue has been completely resolved. However, the nginx proxy approach for HTTPS mixed content resolution has been **superseded by Kong API Gateway integration**.

### **Latest Architecture (Kong Integration):**
- **HTTP Frontend**: Direct backend calls (unchanged)
- **HTTPS Frontend**: Kong API Gateway proxy (eliminates mixed content issues)  
- **Domain Access**: Traefik routing (unchanged)

📖 **Updated Architecture:** [KONG_API_GATEWAY_ARCHITECTURE.md](KONG_API_GATEWAY_ARCHITECTURE.md)

The deployment script retains the environment variable propagation fixes while simplifying the frontend configuration for Kong integration.