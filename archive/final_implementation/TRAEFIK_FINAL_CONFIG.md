# 🔧 Final Traefik Configuration with CORS

## Current Status
✅ Backend API working: `https://portfolio.architecturesolutions.co.uk/api/health`
✅ Backend email working: Direct API test successful
✅ Frontend rebuilt with correct backend URL
❌ Frontend contact form still not working (JavaScript errors)

## Required Traefik Configuration

Add this to your `dynamic.toml` file:

```toml
# API Router (higher priority with CORS)
[http.routers.portfolio-api]
  rule = "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
  service = "portfolio-backend"
  priority = 200
  [http.routers.portfolio-api.tls]
  middlewares = ["cors-headers"]

# Frontend Router (lower priority)
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

# CORS Headers Middleware (CRITICAL for email form)
[http.middlewares.cors-headers.headers]
  accessControlAllowOriginList = [
    "https://portfolio.architecturesolutions.co.uk",
    "http://192.168.86.75:3400",
    "https://192.168.86.75:3443"
  ]
  accessControlAllowMethods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  accessControlAllowHeaders = [
    "Content-Type", 
    "Authorization", 
    "X-Requested-With",
    "Accept",
    "Origin"
  ]
  accessControlAllowCredentials = true
  accessControlMaxAge = 86400
  addVaryHeader = true
```

## Verification Tests

After updating Traefik configuration and restarting:

### 1. Test API with CORS headers:
```bash
curl -X OPTIONS https://portfolio.architecturesolutions.co.uk/api/contact/send-email \
  -H "Origin: https://portfolio.architecturesolutions.co.uk" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type"
```

### 2. Test actual email sending:
```bash
curl -X POST https://portfolio.architecturesolutions.co.uk/api/contact/send-email \
  -H "Content-Type: application/json" \
  -H "Origin: https://portfolio.architecturesolutions.co.uk" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "projectType": "Test Project", 
    "budget": "£10,000 - £25,000",
    "timeline": "1-2 months",
    "message": "Test message"
  }'
```

### 3. Test frontend access:
```bash
curl https://portfolio.architecturesolutions.co.uk/
```

## Expected Results

- **OPTIONS request**: Should return CORS headers
- **POST request**: Should return `{"success":true,"message":"Thank you for your message!..."}`
- **Frontend**: Should load without JavaScript errors

## Additional Debugging

If frontend still has issues, check browser console for:
1. **Network tab**: Verify API calls are going to correct URL
2. **Console tab**: Check for CORS errors
3. **Sources tab**: Verify `REACT_APP_BACKEND_URL` is set correctly

The key is adding the CORS middleware back to Traefik while maintaining the working API routing.