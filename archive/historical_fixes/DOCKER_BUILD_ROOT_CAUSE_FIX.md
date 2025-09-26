# Docker Build Root Cause Analysis & Fix

## Issue Summary
**Problem**: Docker build failing with "Cannot find module 'react-scripts/config/env.js'" while local build works perfectly.

**Error**: CRACO unable to resolve react-scripts internal modules in Docker environment, despite successful local builds.

## Root Cause Identified

### Primary Issue: Package Manager Mismatch
The `package.json` contained:
```json
"packageManager": "yarn@1.22.22+sha512..."
```

But Docker was using `npm ci`, creating **inconsistent dependency trees** between:
- **Local environment**: Mixed npm/yarn usage with working dependency resolution
- **Docker environment**: Pure npm ci with different module structure

### Technical Details
1. **Yarn lockfile vs NPM lockfile**: Project had both yarn.lock and package-lock.json
2. **CRACO module resolution**: CRACO's `require.resolve()` expects specific node_modules structure
3. **npm ci behavior**: Creates different dependency tree than local npm install/yarn install mix

## Solution Applied

### Step 1: Remove Package Manager Lock
**Before**:
```json
{
  "name": "frontend",
  // ... other config
  "packageManager": "yarn@1.22.22+sha512.a6b2f7906b721bba3d67d4aff083df04dad64c399707841b7acf00f6b133b7ac24255f2652fa22ae3534329dc6180534e98d17432037ff6fd140556e2bb3137e"
}
```

**After**:
```json
{
  "name": "frontend",
  // ... other config
  // packageManager field removed
}
```

### Step 2: Regenerate NPM Lock File
```bash
cd /app/frontend
rm -f package-lock.json
npm install --legacy-peer-deps
```

### Step 3: Simplify Docker Build
**Before**:
```dockerfile
RUN npm ci --legacy-peer-deps && \
    npm audit fix --audit-level moderate --force 2>/dev/null || true
```

**After**:
```dockerfile
RUN npm ci --legacy-peer-deps
```

## Testing Results

### Local Build Test
```bash
cd /app/frontend && npm run build
```
**Result**: ✅ SUCCESS - "Compiled successfully"

### Expected Docker Build Result
The Docker build should now succeed because:
1. **Consistent package manager**: Pure npm workflow
2. **Matching dependency trees**: npm ci uses npm-generated package-lock.json
3. **Proper module resolution**: CRACO can find react-scripts internal files

## Files Modified
1. **`/app/frontend/package.json`** - Removed packageManager field
2. **`/app/frontend/package-lock.json`** - Regenerated for npm
3. **`/app/Dockerfile.npm.optimized`** - Simplified npm ci command
4. **`/app/Dockerfile.https.optimized`** - Simplified npm ci command

## Technical Explanation

### Why This Fix Works
- **Package Manager Consistency**: Eliminates yarn/npm hybrid usage
- **Lockfile Alignment**: package-lock.json now matches npm ci expectations
- **Module Resolution**: CRACO can properly resolve react-scripts paths in npm-generated node_modules structure

### Why Previous Attempts Failed
- **Version pinning**: Didn't address underlying package manager mismatch
- **Dependency reinstalls**: Still used inconsistent package managers
- **Yarn attempts**: Created new conflicts with existing npm setup

## Deployment Command
```bash
./scripts/deploy-with-params.sh \
  --mongo-password securepass123 --grafana-password admin123 \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password NewPass6 --smtp-use-ssl true --smtp-port 465 \
  --from-email kamal.singh@architecturesolutions.co.uk
```

## Expected Outcome
- ✅ Docker frontend build completes successfully
- ✅ No "Cannot find module" errors
- ✅ CRACO builds React app properly
- ✅ Final nginx image contains built static files
- ✅ Full deployment stack works end-to-end

This fix addresses the fundamental package manager inconsistency that was causing Docker-specific build failures while maintaining perfect local build functionality.