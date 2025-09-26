#!/bin/sh

# Docker entrypoint script for Kamal Singh Portfolio Frontend
# Handles runtime environment variable injection for dual captcha system

set -e

echo "Starting Kamal Singh Portfolio Frontend with dual captcha support..."

# Create runtime config file with all environment variables
cat > /usr/share/nginx/html/runtime-config.js << EOF
window.ENV = {
  REACT_APP_BACKEND_URL: "${REACT_APP_BACKEND_URL:-http://localhost:8001}",
  REACT_APP_KONG_HOST: "${REACT_APP_KONG_HOST:-192.168.86.75}",
  REACT_APP_KONG_PORT: "${REACT_APP_KONG_PORT:-8443}",
  REACT_APP_BACKEND_URL_HTTP: "${REACT_APP_BACKEND_URL_HTTP:-http://192.168.86.75:3001}",
  REACT_APP_RECAPTCHA_SITE_KEY: "${REACT_APP_RECAPTCHA_SITE_KEY:-}",
  NODE_ENV: "${NODE_ENV:-production}"
};
EOF

echo "Runtime configuration created:"
cat /usr/share/nginx/html/runtime-config.js

# Inject runtime config into index.html
if [ -f /usr/share/nginx/html/index.html ]; then
  # Add runtime config script before closing head tag
  sed -i 's|</head>|<script src="/runtime-config.js"></script></head>|g' /usr/share/nginx/html/index.html
  echo "Runtime config injected into index.html"
fi

echo "Frontend startup complete - Kong configuration ready"

# Start nginx
exec "$@"