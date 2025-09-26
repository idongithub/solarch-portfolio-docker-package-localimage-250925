# SMTP Configuration Guide - Complete Reference

## 📧 Complete SMTP Parameter Coverage

This guide covers **ALL** SMTP parameters supported by the Kamal Singh IT Portfolio Docker deployment.

---

## 🔧 All SMTP Environment Variables

### Core SMTP Server Configuration
```bash
SMTP_SERVER=smtp.gmail.com              # SMTP server hostname
SMTP_PORT=587                           # SMTP port (25, 465, 587, 2525)
SMTP_USE_TLS=true                       # Enable TLS encryption
SMTP_USE_SSL=false                      # Enable SSL encryption (legacy)
SMTP_STARTTLS=true                      # Enable STARTTLS upgrade
SMTP_TIMEOUT=30                         # Connection timeout (seconds)
SMTP_RETRIES=3                          # Retry attempts on failure
SMTP_DEBUG=false                        # Enable debug logging
SMTP_VERIFY_CERT=true                   # Verify SSL certificates
SMTP_LOCAL_HOSTNAME=""                  # Local hostname for SMTP HELO
SMTP_AUTH=true                          # Use SMTP authentication
```

### SMTP Credentials
```bash
SMTP_USERNAME=your-email@gmail.com      # SMTP username (usually email)
SMTP_PASSWORD=your-app-password         # SMTP password or app password
FROM_EMAIL=your-email@gmail.com         # From email address
TO_EMAIL=kamal.singh@architecturesolutions.co.uk  # Primary recipient
REPLY_TO_EMAIL=your-email@gmail.com     # Reply-to address (optional)
CC_EMAIL=manager@company.com            # CC recipient (optional)
BCC_EMAIL=admin@company.com             # BCC recipient (optional)
```

### Email Content Configuration
```bash
EMAIL_SUBJECT_PREFIX="[Portfolio Contact]"  # Subject line prefix
EMAIL_TEMPLATE=default                  # Email template name
EMAIL_CHARSET=utf-8                     # Email character encoding
```

### Security & Rate Limiting
```bash
EMAIL_RATE_LIMIT_MAX=10                 # Max emails per time window
EMAIL_RATE_LIMIT_WINDOW=3600            # Rate limit window (seconds)
EMAIL_COOLDOWN_PERIOD=60                # Cooldown between emails (seconds)
```

---

## 🚀 Dynamic Script Usage

### Complete SMTP Configuration
```bash
./run-docker-dynamic.sh --type fullstack \
  --smtp-server smtp.gmail.com \
  --smtp-port 587 \
  --smtp-use-tls true \
  --smtp-use-ssl false \
  --smtp-starttls true \
  --smtp-timeout 30 \
  --smtp-retries 3 \
  --smtp-debug false \
  --smtp-verify-cert true \
  --smtp-auth true \
  --smtp-username your-email@gmail.com \
  --smtp-password your-app-password \
  --from-email your-email@gmail.com \
  --to-email recipient@company.com \
  --reply-to-email your-email@gmail.com \
  --cc-email manager@company.com \
  --bcc-email admin@company.com \
  --email-subject-prefix "[Custom Contact]" \
  --email-template custom \
  --email-charset utf-8 \
  --email-rate-limit 20 \
  --email-cooldown 30
```

---

## 🐳 Docker Run Command Examples

### Gmail SMTP (Complete Configuration)
```bash
docker run -d --name kamal-backend \
  --restart unless-stopped \
  -p 8001:8001 \
  -e SMTP_SERVER=smtp.gmail.com \
  -e SMTP_PORT=587 \
  -e SMTP_USE_TLS=true \
  -e SMTP_USE_SSL=false \
  -e SMTP_STARTTLS=true \
  -e SMTP_TIMEOUT=30 \
  -e SMTP_RETRIES=3 \
  -e SMTP_DEBUG=false \
  -e SMTP_VERIFY_CERT=true \
  -e SMTP_LOCAL_HOSTNAME="" \
  -e SMTP_AUTH=true \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-16-char-app-password \
  -e FROM_EMAIL=your-email@gmail.com \
  -e TO_EMAIL=kamal.singh@architecturesolutions.co.uk \
  -e REPLY_TO_EMAIL=your-email@gmail.com \
  -e CC_EMAIL="" \
  -e BCC_EMAIL="" \
  -e EMAIL_SUBJECT_PREFIX="[Portfolio Contact]" \
  -e EMAIL_TEMPLATE=default \
  -e EMAIL_CHARSET=utf-8 \
  -e EMAIL_RATE_LIMIT_MAX=10 \
  -e EMAIL_COOLDOWN_PERIOD=60 \
  kamal-portfolio:backend
```

### Outlook/Office365 SMTP (Complete Configuration)
```bash
docker run -d --name kamal-backend \
  --restart unless-stopped \
  -p 8001:8001 \
  -e SMTP_SERVER=smtp-mail.outlook.com \
  -e SMTP_PORT=587 \
  -e SMTP_USE_TLS=true \
  -e SMTP_USE_SSL=false \
  -e SMTP_STARTTLS=true \
  -e SMTP_TIMEOUT=30 \
  -e SMTP_RETRIES=3 \
  -e SMTP_DEBUG=false \
  -e SMTP_VERIFY_CERT=true \
  -e SMTP_AUTH=true \
  -e SMTP_USERNAME=your-email@outlook.com \
  -e SMTP_PASSWORD=your-password \
  -e FROM_EMAIL=your-email@outlook.com \
  -e TO_EMAIL=kamal.singh@architecturesolutions.co.uk \
  -e REPLY_TO_EMAIL=your-email@outlook.com \
  -e EMAIL_SUBJECT_PREFIX="[Portfolio Inquiry]" \
  -e EMAIL_TEMPLATE=default \
  -e EMAIL_CHARSET=utf-8 \
  -e EMAIL_RATE_LIMIT_MAX=15 \
  -e EMAIL_COOLDOWN_PERIOD=45 \
  kamal-portfolio:backend
```

### Custom SMTP Server (Complete Configuration)
```bash
docker run -d --name kamal-backend \
  --restart unless-stopped \
  -p 8001:8001 \
  -e SMTP_SERVER=mail.yourcompany.com \
  -e SMTP_PORT=587 \
  -e SMTP_USE_TLS=true \
  -e SMTP_USE_SSL=false \
  -e SMTP_STARTTLS=true \
  -e SMTP_TIMEOUT=45 \
  -e SMTP_RETRIES=5 \
  -e SMTP_DEBUG=true \
  -e SMTP_VERIFY_CERT=true \
  -e SMTP_LOCAL_HOSTNAME=portfolio.yourcompany.com \
  -e SMTP_AUTH=true \
  -e SMTP_USERNAME=noreply@yourcompany.com \
  -e SMTP_PASSWORD=your-smtp-password \
  -e FROM_EMAIL=noreply@yourcompany.com \
  -e TO_EMAIL=kamal.singh@architecturesolutions.co.uk \
  -e REPLY_TO_EMAIL=contact@yourcompany.com \
  -e CC_EMAIL=manager@yourcompany.com \
  -e BCC_EMAIL=admin@yourcompany.com \
  -e EMAIL_SUBJECT_PREFIX="[Company Portfolio]" \
  -e EMAIL_TEMPLATE=corporate \
  -e EMAIL_CHARSET=utf-8 \
  -e EMAIL_RATE_LIMIT_MAX=25 \
  -e EMAIL_COOLDOWN_PERIOD=30 \
  kamal-portfolio:backend
```

### Legacy SMTP Server (SSL Port 465)
```bash
docker run -d --name kamal-backend \
  --restart unless-stopped \
  -p 8001:8001 \
  -e SMTP_SERVER=legacy-mail.company.com \
  -e SMTP_PORT=465 \
  -e SMTP_USE_TLS=false \
  -e SMTP_USE_SSL=true \
  -e SMTP_STARTTLS=false \
  -e SMTP_TIMEOUT=60 \
  -e SMTP_RETRIES=2 \
  -e SMTP_DEBUG=false \
  -e SMTP_VERIFY_CERT=false \
  -e SMTP_AUTH=true \
  -e SMTP_USERNAME=legacy-user \
  -e SMTP_PASSWORD=legacy-password \
  -e FROM_EMAIL=system@company.com \
  -e TO_EMAIL=kamal.singh@architecturesolutions.co.uk \
  kamal-portfolio:backend
```

---

## 📋 SMTP Provider Configurations

### Gmail (Recommended)
```bash
# Required: Enable 2-Factor Authentication
# Generate App Password: Google Account → Security → 2-Step Verification → App passwords

SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USE_TLS=true
SMTP_USE_SSL=false
SMTP_STARTTLS=true
SMTP_AUTH=true
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-16-char-app-password  # NOT regular password
FROM_EMAIL=your-email@gmail.com
```

### Outlook/Office365
```bash
SMTP_SERVER=smtp-mail.outlook.com
SMTP_PORT=587
SMTP_USE_TLS=true
SMTP_USE_SSL=false
SMTP_STARTTLS=true
SMTP_AUTH=true
SMTP_USERNAME=your-email@outlook.com
SMTP_PASSWORD=your-password
FROM_EMAIL=your-email@outlook.com
```

### Yahoo Mail
```bash
SMTP_SERVER=smtp.mail.yahoo.com
SMTP_PORT=587
SMTP_USE_TLS=true
SMTP_USE_SSL=false
SMTP_STARTTLS=true
SMTP_AUTH=true
SMTP_USERNAME=your-email@yahoo.com
SMTP_PASSWORD=your-app-password
FROM_EMAIL=your-email@yahoo.com
```

### Amazon SES
```bash
SMTP_SERVER=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_USE_TLS=true
SMTP_USE_SSL=false
SMTP_STARTTLS=true
SMTP_AUTH=true
SMTP_USERNAME=your-ses-access-key
SMTP_PASSWORD=your-ses-secret-key
FROM_EMAIL=verified@yourdomain.com
```

### SendGrid
```bash
SMTP_SERVER=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USE_TLS=true
SMTP_USE_SSL=false
SMTP_STARTTLS=true
SMTP_AUTH=true
SMTP_USERNAME=apikey
SMTP_PASSWORD=your-sendgrid-api-key
FROM_EMAIL=verified@yourdomain.com
```

### Mailgun
```bash
SMTP_SERVER=smtp.mailgun.org
SMTP_PORT=587
SMTP_USE_TLS=true
SMTP_USE_SSL=false
SMTP_STARTTLS=true
SMTP_AUTH=true
SMTP_USERNAME=postmaster@your-domain.mailgun.org
SMTP_PASSWORD=your-mailgun-password
FROM_EMAIL=noreply@yourdomain.com
```

### Custom Corporate Server
```bash
SMTP_SERVER=mail.yourcompany.com
SMTP_PORT=587                    # or 25, 465, 2525
SMTP_USE_TLS=true               # or false
SMTP_USE_SSL=false              # or true for port 465
SMTP_STARTTLS=true              # or false
SMTP_TIMEOUT=30                 # adjust as needed
SMTP_RETRIES=3                  # adjust as needed
SMTP_DEBUG=false                # set true for debugging
SMTP_VERIFY_CERT=true           # set false for self-signed certs
SMTP_AUTH=true                  # or false for open relay
SMTP_USERNAME=your-username
SMTP_PASSWORD=your-password
FROM_EMAIL=noreply@yourcompany.com
```

---

## 🔍 SMTP Port Reference

### Common SMTP Ports
- **25** - Plain SMTP (often blocked by ISPs)
- **465** - SMTP over SSL (legacy, immediate SSL connection)
- **587** - SMTP with STARTTLS (recommended, modern standard)
- **2525** - Alternative port (used by some providers)

### Port Configuration Examples
```bash
# Modern TLS (Port 587) - Recommended
SMTP_PORT=587
SMTP_USE_TLS=true
SMTP_USE_SSL=false
SMTP_STARTTLS=true

# Legacy SSL (Port 465)
SMTP_PORT=465
SMTP_USE_TLS=false
SMTP_USE_SSL=true
SMTP_STARTTLS=false

# Plain SMTP (Port 25) - Usually blocked
SMTP_PORT=25
SMTP_USE_TLS=false
SMTP_USE_SSL=false
SMTP_STARTTLS=false

# Alternative Port (2525)
SMTP_PORT=2525
SMTP_USE_TLS=true
SMTP_USE_SSL=false
SMTP_STARTTLS=true
```

---

## 🛠️ Advanced SMTP Configuration

### Debug Mode Configuration
```bash
# Enable debug logging to troubleshoot SMTP issues
SMTP_DEBUG=true
LOG_LEVEL=DEBUG

# Docker run with debug
docker run -d --name kamal-backend \
  -e SMTP_DEBUG=true \
  -e LOG_LEVEL=DEBUG \
  [other parameters...] \
  kamal-portfolio:backend

# View debug logs
docker logs kamal-backend
```

### High-Volume Email Configuration
```bash
# For high-volume email sending
SMTP_TIMEOUT=60
SMTP_RETRIES=5
EMAIL_RATE_LIMIT_MAX=100
EMAIL_RATE_LIMIT_WINDOW=3600
EMAIL_COOLDOWN_PERIOD=1
```

### Security-Focused Configuration
```bash
# Maximum security settings
SMTP_VERIFY_CERT=true
SMTP_USE_TLS=true
SMTP_USE_SSL=false
SMTP_STARTTLS=true
SMTP_DEBUG=false
EMAIL_RATE_LIMIT_MAX=5
EMAIL_COOLDOWN_PERIOD=300
```

### Multi-Recipient Configuration
```bash
# Send to multiple recipients
TO_EMAIL=primary@company.com
CC_EMAIL=manager@company.com,team@company.com
BCC_EMAIL=admin@company.com,audit@company.com
REPLY_TO_EMAIL=support@company.com
```

---

## 🔧 Troubleshooting SMTP Issues

### Common Issues & Solutions

#### **Authentication Failed**
```bash
# For Gmail: Use App Password, not regular password
# Enable 2FA first, then generate App Password
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-16-char-app-password

# For corporate servers: Verify username format
SMTP_USERNAME=username@domain.com  # or just 'username'
```

#### **Connection Timeout**
```bash
# Increase timeout and retries
SMTP_TIMEOUT=60
SMTP_RETRIES=5

# Try alternative port
SMTP_PORT=2525
```

#### **SSL/TLS Errors**
```bash
# For self-signed certificates
SMTP_VERIFY_CERT=false

# Try different encryption methods
SMTP_USE_TLS=true
SMTP_USE_SSL=false
SMTP_STARTTLS=true
```

#### **Rate Limiting Issues**
```bash
# Reduce rate limits
EMAIL_RATE_LIMIT_MAX=3
EMAIL_COOLDOWN_PERIOD=120
```

### SMTP Testing Commands
```bash
# Test SMTP connection inside container
docker exec -it kamal-backend python3 -c "
import smtplib
import os
server = smtplib.SMTP(os.getenv('SMTP_SERVER'), int(os.getenv('SMTP_PORT')))
if os.getenv('SMTP_STARTTLS') == 'true':
    server.starttls()
server.login(os.getenv('SMTP_USERNAME'), os.getenv('SMTP_PASSWORD'))
print('SMTP connection successful')
server.quit()
"

# Test with debug enabled
docker run -it --rm \
  -e SMTP_SERVER=your-server \
  -e SMTP_PORT=587 \
  -e SMTP_USERNAME=your-username \
  -e SMTP_PASSWORD=your-password \
  -e SMTP_DEBUG=true \
  kamal-portfolio:backend \
  python3 -c "import smtplib; [your test code]"
```

---

## 📖 Related Documentation

- **[GETTING_STARTED.md](./GETTING_STARTED.md)** - Main deployment guide
- **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** - Complete deployment reference
- **[docker-parameters-reference.md](./docker-parameters-reference.md)** - Quick parameter lookup

---

**📧 With these comprehensive SMTP parameters, you can configure email functionality for any SMTP provider with complete control over all connection, security, and delivery settings!**