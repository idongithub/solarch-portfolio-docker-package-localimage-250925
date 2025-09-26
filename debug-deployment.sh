#!/bin/bash
# Debug deployment environment setup

echo "🔍 Debugging Frontend Environment Configuration"
echo "==============================================="

echo "📁 Current frontend .env file:"
if [ -f "/app/frontend/.env" ]; then
    cat /app/frontend/.env
else
    echo "❌ No .env file found"
fi

echo ""
echo "🌐 Expected Configuration:"
echo "REACT_APP_BACKEND_URL: Domain URL (if domain deployment)"
echo "REACT_APP_KONG_HOST: IP for Kong proxy"
echo "REACT_APP_KONG_PORT: Kong port (8443)"  
echo "REACT_APP_BACKEND_URL_HTTP: Direct backend for HTTP"
echo "REACT_APP_RECAPTCHA_SITE_KEY: reCAPTCHA key"

echo ""
echo "🧪 Quick Frontend Environment Test:"
echo "HOST_IP=$(hostname -I | awk '{print $1}')"
echo "KONG_HOST=\${KONG_HOST:-\$(hostname -I | awk '{print $1}')}"
echo "KONG_PORT=\${KONG_PORT:-8443}"

HOST_IP=$(hostname -I | awk '{print $1}')
echo "Detected Host IP: $HOST_IP"