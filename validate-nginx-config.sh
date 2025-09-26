#!/bin/bash

# Nginx Configuration Validator
# Checks for common nginx configuration issues

set -e

CONFIG_FILE="${1:-nginx-simple.conf}"
ERRORS=0

print_status() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
    ERRORS=$((ERRORS + 1))
}

print_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

echo "🔍 Validating Nginx Configuration: $CONFIG_FILE"
echo "============================================"

# Check if file exists
if [ ! -f "$CONFIG_FILE" ]; then
    print_error "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

print_success "Configuration file exists"

# Check for syntax issues
print_status "Checking basic syntax..."

# Check for missing semicolons
if grep -n '[^;{}]$' "$CONFIG_FILE" | grep -v '^\s*#' | grep -v '^\s*$' | grep -v '{$' | grep -v '}$'; then
    print_warning "Potential missing semicolons detected"
fi

# Check for balanced braces
OPEN_BRACES=$(grep -o '{' "$CONFIG_FILE" | wc -l)
CLOSE_BRACES=$(grep -o '}' "$CONFIG_FILE" | wc -l)

if [ "$OPEN_BRACES" -eq "$CLOSE_BRACES" ]; then
    print_success "Braces are balanced ($OPEN_BRACES pairs)"
else
    print_error "Unbalanced braces: $OPEN_BRACES opening, $CLOSE_BRACES closing"
fi

# Check for required directives
print_status "Checking required directives..."

if grep -q "server {" "$CONFIG_FILE"; then
    print_success "Server block found"
else
    print_error "No server block found"
fi

if grep -q "listen " "$CONFIG_FILE"; then
    print_success "Listen directive found"
else
    print_error "No listen directive found"
fi

if grep -q "server_name " "$CONFIG_FILE"; then
    print_success "Server name directive found"
else
    print_warning "No server_name directive found"
fi

# Check for common issues
print_status "Checking for common issues..."

# Check for limit_req_zone in correct context
if grep -A5 -B5 "limit_req_zone" "$CONFIG_FILE" | grep -q "location"; then
    print_error "limit_req_zone directive found inside location block (should be in http context)"
fi

# Check for upstream configuration
if grep -q "upstream " "$CONFIG_FILE"; then
    print_success "Upstream configuration found"
    
    # Check if upstream is used in proxy_pass
    if grep -q "proxy_pass http://backend" "$CONFIG_FILE"; then
        print_success "Upstream properly referenced in proxy_pass"
    else
        print_warning "Upstream defined but not used in proxy_pass"
    fi
fi

# Check proxy settings
if grep -q "proxy_pass" "$CONFIG_FILE"; then
    print_success "Proxy configuration found"
    
    # Check for essential proxy headers
    if grep -q "proxy_set_header Host" "$CONFIG_FILE"; then
        print_success "Host header forwarding configured"
    else
        print_warning "Missing Host header forwarding"
    fi
    
    if grep -q "proxy_set_header X-Forwarded-For" "$CONFIG_FILE"; then
        print_success "X-Forwarded-For header configured"
    else
        print_warning "Missing X-Forwarded-For header"
    fi
fi

# Check for security headers
print_status "Checking security configuration..."

SECURITY_HEADERS=("X-Frame-Options" "X-Content-Type-Options" "X-XSS-Protection")
for header in "${SECURITY_HEADERS[@]}"; do
    if grep -q "$header" "$CONFIG_FILE"; then
        print_success "$header configured"
    else
        print_warning "$header not configured"
    fi
done

# Check for SSL configuration (if present)
if grep -q "ssl_certificate" "$CONFIG_FILE"; then
    print_status "SSL configuration detected"
    
    if grep -q "ssl_certificate_key" "$CONFIG_FILE"; then
        print_success "SSL certificate and key configured"
    else
        print_error "SSL certificate configured but key missing"
    fi
fi

# Check for gzip configuration
if grep -q "gzip on" "$CONFIG_FILE"; then
    print_success "Gzip compression enabled"
else
    print_warning "Gzip compression not enabled"
fi

# Final result
echo ""
echo "============================================"
if [ $ERRORS -eq 0 ]; then
    print_success "✅ Configuration validation passed!"
    print_status "No critical errors found. Configuration should work with nginx."
    exit 0
else
    print_error "❌ Configuration validation failed!"
    print_error "$ERRORS critical error(s) found. Please fix before using."
    exit 1
fi