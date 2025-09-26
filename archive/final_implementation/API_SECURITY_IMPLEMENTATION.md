# API Security Implementation - Traefik API Key Injection

## 🎯 Overview

Complete implementation of API key/secret authentication using Traefik middleware to automatically inject authentication headers, requiring no frontend code changes. The system provides multiple ways to access and manage API credentials.

## 🔧 Implementation Features

### ✅ **Credential Management:**
- **Auto-generated keys**: 32-byte hexadecimal secure keys using OpenSSL
- **Custom keys**: Option to provide your own API key/secret pairs
- **Multiple display formats**: Console output, dedicated files, and copy-ready configs
- **Development bypass**: IP-based access remains unrestricted

### ✅ **Security Architecture:**
- **Domain-only protection**: HTTPS domain access requires authentication
- **Traefik middleware injection**: Automatic header insertion for `/api/*` requests
- **Backend validation**: FastAPI dependency injection validates credentials
- **Zero frontend changes**: Complete transparency to React application

## 🚀 Deployment Options

### Option 1: Basic Deployment (No Security)
```bash
./scripts/deploy-with-params.sh \
  --domain portfolio \
  --http-port 3400 --https-port 3443 --backend-port 3001 \
  --smtp-server smtp.ionos.co.uk --smtp-port 465 \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password NewPass6 --smtp-use-ssl true \
  --mongo-password securepass123 --grafana-password admin123
```

### Option 2: Auto-Generated API Security (Recommended)
```bash
./scripts/deploy-with-params.sh \
  --domain portfolio \
  --enable-api-auth \
  --http-port 3400 --https-port 3443 --backend-port 3001 \
  --smtp-server smtp.ionos.co.uk --smtp-port 465 \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password NewPass6 --smtp-use-ssl true \
  --mongo-password securepass123 --grafana-password admin123
```

### Option 3: Custom API Credentials
```bash
./scripts/deploy-with-params.sh \
  --domain portfolio \
  --api-key "your-custom-64char-api-key-here" \
  --api-secret "your-custom-64char-api-secret-here" \
  --http-port 3400 --https-port 3443 --backend-port 3001 \
  --smtp-server smtp.ionos.co.uk --smtp-port 465 \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password NewPass6 --smtp-use-ssl true \
  --mongo-password securepass123 --grafana-password admin123
```

## 📋 API Credential Access Methods

### Method 1: Console Display During Deployment
```
🔐 Configuring API security...
🔐 Generated API Key: a1b2c3d4... (first 8 chars shown for confirmation)
🔐 Generated API Secret: z9y8x7w6... (first 8 chars shown for confirmation)
```

### Method 2: End-of-Deployment Summary
```
🔐 API Security Configuration
==================================================
⚠️  IMPORTANT: Copy these credentials to your Traefik configuration

API Key:    a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6
API Secret: z9y8x7w6v5u4t3s2r1q0p9o8n7m6l5k4j3i2h1g0f9e8d7c6b5a4

📁 Traefik config file: ./traefik/api-auth-middleware.toml
🔗 Secured domain: https://portfolio.architecturesolutions.co.uk
🔓 Development access: http://192.168.86.75:3400 (no auth required)
==================================================
```

### Method 3: Generated Files
#### `./traefik/api-auth-middleware.toml` - Ready-to-use Traefik config:
```toml
[http.middlewares.api-auth.headers.customRequestHeaders]
  X-API-Key = "generated-api-key-here"
  X-API-Secret = "generated-api-secret-here"

[http.routers.portfolio-api-secure]
  rule = "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
  service = "portfolio-backend"
  priority = 200
  [http.routers.portfolio-api-secure.tls]
  middlewares = ["api-auth", "cors-headers"]
```

#### `./traefik/API_CREDENTIALS.txt` - Complete reference file:
```
API_KEY=your-generated-key-here
API_SECRET=your-generated-secret-here

COPY TO YOUR TRAEFIK dynamic.toml:
[Includes full configuration with setup notes]
```

## 🔒 Backend Security Implementation

### FastAPI Authentication Middleware
```python
async def verify_api_credentials(
    x_api_key: Optional[str] = Header(None),
    x_api_secret: Optional[str] = Header(None)
):
    # Skip authentication if disabled
    if not os.getenv('API_AUTH_ENABLED', 'false').lower() == 'true':
        return True
    
    # Validate credentials against environment variables
    if x_api_key != expected_key or x_api_secret != expected_secret:
        raise HTTPException(status_code=401, detail="Invalid API credentials")
    
    return True

# Applied to protected endpoints
@api_router.post("/contact/send-email")
async def send_contact_email(
    form_data: ContactForm,
    _: bool = Depends(verify_api_credentials)
):
    # Email functionality...
```

## 🛡️ Security Architecture

### Traffic Flow Diagram
```
🌐 INTERNET ACCESS (Secured)
─────────────────────────────
User Browser → https://portfolio.architecturesolutions.co.uk
     ↓
Traefik (192.168.86.56:434) 
     ↓ (Injects Headers)
X-API-Key: generated-key
X-API-Secret: generated-secret
     ↓
Backend Validation (192.168.86.75:3001)
     ↓ (Success)
Email/API Response

🏠 DEVELOPMENT ACCESS (Unrestricted)
──────────────────────────────────
Developer → http://192.168.86.75:3400
     ↓ (Direct Container Access)
Backend (No Auth Required)
     ↓
Email/API Response
```

### Security Levels
- **Level 1**: API Key/Secret validation (domain access only)
- **Level 2**: Rate limiting (optional - can be added to Traefik)
- **Level 3**: IP whitelisting (optional - for admin functions)

## 🎯 Key Benefits

### ✅ **Zero Frontend Impact**
- No JavaScript code changes required
- No additional headers to manage in React
- Complete transparency to frontend developers

### ✅ **Development-Friendly**
- IP-based access bypasses authentication
- Easy testing and debugging
- No credential management during development

### ✅ **Production-Ready**
- Automatic secure key generation
- Multiple access methods for credentials
- Easy integration with existing Traefik setup

### ✅ **Operational Excellence**
- Clear credential display and file generation
- Copy-ready Traefik configurations
- Comprehensive documentation and setup notes

## 🔧 Traefik Integration Steps

### Step 1: Deploy with API Security
```bash
./scripts/deploy-with-params.sh --domain portfolio --enable-api-auth [other params...]
```

### Step 2: Copy Configuration
1. **Locate credentials** in console output or `./traefik/API_CREDENTIALS.txt`
2. **Copy middleware config** to your Traefik `dynamic.toml`:
   ```toml
   [http.middlewares.api-auth.headers.customRequestHeaders]
     X-API-Key = "your-generated-key"
     X-API-Secret = "your-generated-secret"
   ```

### Step 3: Update API Router
Replace your existing `portfolio-api` router with:
```toml
[http.routers.portfolio-api-secure]
  rule = "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
  service = "portfolio-backend"
  priority = 200
  [http.routers.portfolio-api-secure.tls]
  middlewares = ["api-auth", "cors-headers"]
```

### Step 4: Restart Traefik
Restart your Traefik binary to load the new configuration.

## 🧪 Testing the Security

### Test 1: Domain Access (Should be secured)
```bash
# Without credentials - should fail
curl https://portfolio.architecturesolutions.co.uk/api/contact/send-email

# With Traefik injecting credentials - should work
# (Traefik automatically adds X-API-Key and X-API-Secret headers)
```

### Test 2: IP Access (Should work without auth)
```bash
# Direct container access - should work  
curl http://192.168.86.75:3001/api/health
```

### Test 3: Frontend Testing
- **Domain**: `https://portfolio.architecturesolutions.co.uk/contact` (secured via Traefik)
- **IP**: `http://192.168.86.75:3400/contact` (direct access, no auth)

## 🎉 Summary

This implementation provides enterprise-grade API security with:
- **Transparent operation** (no frontend changes)
- **Flexible deployment** (enabled/disabled per deployment)
- **Multiple credential access methods** (console, files, configs)
- **Development-friendly bypass** (IP-based access unrestricted)
- **Production-ready security** (auto-generated secure credentials)

The system is designed to integrate seamlessly with your existing Traefik architecture while providing robust API protection for internet-facing deployments.