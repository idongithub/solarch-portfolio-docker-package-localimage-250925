# Requirements.txt Dependency Conflict - Fix Options

## 🚨 **Problem Identified**
```
ERROR: Cannot install h11==0.16.0 and httpx because these package versions have conflicting dependencies.
- h11==0.16.0 (existing)
- httpcore depends on h11<0.15 (required by httpx)
```

## ✅ **Solution Applied (Recommended)**

### **Fixed Versions:**
```txt
# Changed:
h11==0.14.0          # Was: h11==0.16.0 (downgraded for compatibility)
httpx==0.25.0        # Added: Latest compatible version
slowapi==0.1.9       # Added: For rate limiting
bleach==6.0.0        # Added: For input sanitization
```

### **Compatibility Matrix:**
| Package | Version | Compatible With |
|---------|---------|-----------------|
| **h11** | 0.14.0 | httpcore < 0.15 ✅ |
| **httpx** | 0.25.0 | h11 0.14.0 ✅ |
| **uvicorn** | 0.24.0 | h11 >= 0.8 ✅ |
| **fastapi** | 0.104.1 | All versions ✅ |

## 🔄 **Alternative Solutions (If Needed)**

### **Option 1: Minimal Security (No CAPTCHA)**
If you want to deploy without CAPTCHA features temporarily:

```bash
# Remove these from requirements.txt:
# httpx==0.25.0
# bleach==6.0.0

# Keep:
slowapi==0.1.9       # Rate limiting only
h11==0.16.0         # Can revert to original version
```

### **Option 2: Latest Versions (More Aggressive)**
Update more packages to latest compatible versions:

```txt
# Major updates:
h11==0.14.0
httpcore==0.18.0     # Latest compatible
httpx==0.25.0        # Latest
uvicorn==0.24.0      # Keep current
fastapi==0.104.1     # Keep current (stable)
```

### **Option 3: Conservative Update**
Minimal changes with older but stable versions:

```txt
h11==0.13.0          # More conservative downgrade
httpx==0.24.1        # Slightly older but stable
slowapi==0.1.8       # Previous version
bleach==5.0.1        # Previous major version
```

## 🧪 **Testing Your Fix**

### **Quick Test:**
```bash
cd /app && python3 test-requirements-compatibility.py
```

### **Manual Verification:**
```bash
# In Docker container during build:
pip install -r requirements.txt --dry-run
```

### **Import Test:**
```python
# Test key imports:
import fastapi
import uvicorn  
import slowapi
import httpx
import bleach
import h11
print("All imports successful!")
```

## 📋 **Common Dependency Conflicts**

### **h11 Conflicts:**
- **h11 >= 0.15:** Not compatible with older httpcore
- **h11 < 0.13:** Not compatible with newer uvicorn
- **Sweet Spot:** h11 0.13.x - 0.14.x

### **httpx Conflicts:**
- **httpx >= 0.25:** Requires newer httpcore
- **httpx < 0.24:** Missing some features
- **Recommended:** httpx 0.24.x - 0.25.x

### **FastAPI Ecosystem:**
- **FastAPI 0.104.x:** Stable with current dependencies
- **Uvicorn 0.24.x:** Current stable version
- **Pydantic 2.5.x:** Compatible with FastAPI 0.104.x

## 🚀 **Deployment Commands (Updated)**

### **Full Security Deployment:**
```bash
./scripts/deploy-with-params.sh \
  --domain portfolio \
  --http-port 3400 --https-port 3443 --backend-port 3001 \
  --smtp-server smtp.ionos.co.uk --smtp-port 465 --smtp-use-ssl true \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password "YourSMTPPassword" \
  --from-email kamal.singh@architecturesolutions.co.uk \
  --to-email kamal.singh@architecturesolutions.co.uk \
  --recaptcha-site-key "6LeXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" \
  --recaptcha-secret-key "6LeXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" \
  --mongo-password "securepass123" \
  --grafana-password "admin123" \
  --enable-api-auth
```

### **Basic Deployment (Rate Limiting Only):**
```bash
./scripts/deploy-with-params.sh \
  --domain portfolio \
  --http-port 3400 --https-port 3443 --backend-port 3001 \
  --smtp-server smtp.ionos.co.uk --smtp-port 465 --smtp-use-ssl true \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password "YourSMTPPassword" \
  --mongo-password "securepass123" \
  --grafana-password "admin123"
```

## 📊 **Security Features Status**

### **✅ Active (After Fix):**
- **Rate Limiting:** 5 requests/minute per IP (slowapi)
- **Input Validation:** Enhanced Pydantic models
- **Security Logging:** IP tracking and attempt logging

### **🔄 Pending (Need CAPTCHA Keys):**
- **reCAPTCHA v3:** Bot protection with confidence scoring
- **Input Sanitization:** XSS prevention (bleach)
- **CAPTCHA Logging:** Bot detection analytics

### **🎯 Expected Results:**
- ✅ **Deployment Success:** No dependency conflicts
- ✅ **Rate Limiting Active:** Prevents spam/DDoS
- ✅ **Email Functionality:** Working with enhanced validation
- ⏳ **CAPTCHA Ready:** Will activate when keys provided

## 🔧 **Troubleshooting**

### **If Build Still Fails:**
1. **Clear Docker cache:**
   ```bash
   docker system prune -f
   docker builder prune -f
   ```

2. **Check specific package:**
   ```bash
   pip install httpx==0.25.0 --dry-run
   ```

3. **Test individual packages:**
   ```bash
   pip install h11==0.14.0 httpx==0.25.0 uvicorn==0.24.0
   ```

### **If Import Errors:**
1. **Verify Python version:** Requirements built for Python 3.9+
2. **Check platform:** Some packages have platform-specific builds
3. **Clear pip cache:** `pip cache purge`

## ✅ **Success Indicators**

After successful deployment, you should see:
- ✅ **Backend starts:** No import or dependency errors
- ✅ **API accessible:** `/api/health` returns 200
- ✅ **Rate limiting works:** Submit >5 forms/minute → 429 error
- ✅ **Contact form:** Basic validation and spam detection active
- ✅ **Logs show:** Security middleware and rate limiter active

**🎉 You're now ready to deploy with enhanced security features!**