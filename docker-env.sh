#!/bin/bash
# Environment variables for Docker Compose
# Source this file before running docker-compose commands

export HTTP_PORT=3400
export HTTPS_PORT=3443  
export BACKEND_PORT=3001
export MONGO_PORT=37037
export MONGO_USERNAME=admin
export MONGO_PASSWORD=securepass123
export MONGO_EXPRESS_PORT=3081
export MONGO_EXPRESS_USERNAME=admin
export MONGO_EXPRESS_PASSWORD=admin123
export REDIS_PASSWORD=redispass123
export GRAFANA_PORT=3030
export GRAFANA_PASSWORD=adminpass123
export LOKI_PORT=3300
export PROMETHEUS_PORT=3091
export SMTP_SERVER=smtp.ionos.co.uk
export SMTP_USERNAME=kamal.singh@architecturesolutions.co.uk
export SMTP_PASSWORD=NewPass6
export FROM_EMAIL=kamal.singh@architecturesolutions.co.uk
export TO_EMAIL=kamal.singh@architecturesolutions.co.uk
export SECRET_KEY=your-secret-key-here
export SSL_CERT_PATH=./ssl

echo "✅ Environment variables set for Docker Compose"