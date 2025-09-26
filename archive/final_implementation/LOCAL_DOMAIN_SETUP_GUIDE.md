# Local Domain Setup Guide for reCAPTCHA Compatibility

## Problem
Google reCAPTCHA doesn't work with IP addresses (192.168.86.75:3400). It requires proper domain names.

## Solution: Local Domain Mapping

### 1. Configure Local Hosts File

Add these entries to your Ubuntu machine's `/etc/hosts` file:

```bash
sudo nano /etc/hosts

# Add these lines:
192.168.86.75  portfolio.local
192.168.86.75  portfolio-http.local  
192.168.86.75  portfolio-https.local
```

### 2. Update reCAPTCHA Site Configuration

In your Google reCAPTCHA admin panel (https://www.google.com/recaptcha/admin):
1. Go to your existing site key: `6LcgftMrAAAAAPJRuWA4mQgstPWYoIXoPM4PBjMM`
2. Add these domains to the allowed domains list:
   - `portfolio.local`
   - `portfolio-http.local`
   - `portfolio-https.local`
   - `localhost` (for development)

### 3. Access URLs After Setup

**Local HTTP Access:**
- URL: `http://portfolio-http.local:3400`
- Backend: Direct to `http://192.168.86.75:3001`
- reCAPTCHA: ✅ Works (domain-based)

**Local HTTPS Access:**
- URL: `https://portfolio-https.local:3443`  
- Backend: Via Kong `https://192.168.86.75:8443`
- reCAPTCHA: ✅ Works (domain-based)

**Domain Production Access:**
- URL: `https://portfolio.architecturesolutions.co.uk`
- Backend: Via Traefik
- reCAPTCHA: ✅ Already working

### 4. Deployment Command

Use the updated deployment script with local domain support:

```bash
./scripts/deploy-with-params.sh \
  --local-http-domain portfolio-http.local \
  --local-https-domain portfolio-https.local \
  --http-port 3400 \
  --https-port 3443 \
  --kong-host 192.168.86.75 \
  --kong-port 8443 \
  --smtp-server smtp.ionos.co.uk \
  --smtp-port 465 \
  --smtp-use-ssl true \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password "YourPassword" \
  --recaptcha-site-key "6LcgftMrAAAAAPJRuWA4mQgstPWYoIXoPM4PBjMM" \
  --recaptcha-secret-key "6LcgftMrAAAAANYLqKcqycaZrYzEhpVBmQNeacsm"
```

### 5. Benefits

✅ **reCAPTCHA works on local domains**
✅ **Kong routing preserved for HTTPS**  
✅ **No IP address limitations**
✅ **Production domain access unchanged**
✅ **Easy local development**

### 6. Alternative Quick Setup

If you don't want to modify `/etc/hosts`, you can use `curl` with host headers for testing:

```bash
# Test HTTP frontend
curl -H "Host: portfolio-http.local" http://192.168.86.75:3400

# Test HTTPS frontend  
curl -H "Host: portfolio-https.local" https://192.168.86.75:3443
```