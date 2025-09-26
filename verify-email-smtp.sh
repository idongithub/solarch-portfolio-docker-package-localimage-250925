#!/bin/bash

# Email and SMTP Verification Script for Kamal Singh Portfolio
# Tests various SMTP connection types and configurations

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${1}%s${NC}\n" "$2"
}

# Function to show usage
show_usage() {
    cat << EOF
${GREEN}SMTP Email Verification Script${NC}

Usage: $0 [TEST_TYPE] [OPTIONS]

${BLUE}Available Test Types:${NC}
  gmail-tls        - Test Gmail with TLS (port 587)
  gmail-ssl        - Test Gmail with SSL (port 465)
  outlook-tls      - Test Outlook with TLS (port 587)
  outlook-ssl      - Test Outlook with SSL (port 465)
  custom           - Test custom SMTP server
  all              - Test all common configurations
  docker-test      - Test via Docker backend container

${BLUE}Required Environment Variables:${NC}
  SMTP_USERNAME    - Your email username
  SMTP_PASSWORD    - Your email password or app password
  FROM_EMAIL       - Sender email address
  TO_EMAIL         - Recipient email (default: kamal.singh@architecturesolutions.co.uk)

${BLUE}Optional Environment Variables:${NC}
  SMTP_SERVER      - Custom SMTP server hostname
  SMTP_PORT        - Custom SMTP port
  SMTP_USE_TLS     - Use TLS (true/false)
  SMTP_USE_SSL     - Use SSL (true/false)
  SMTP_STARTTLS    - Use STARTTLS (true/false)

${BLUE}Examples:${NC}
  # Test Gmail with TLS
  SMTP_USERNAME=myemail@gmail.com SMTP_PASSWORD=myapppass FROM_EMAIL=myemail@gmail.com $0 gmail-tls
  
  # Test custom SMTP server
  SMTP_SERVER=mail.example.com SMTP_PORT=587 SMTP_USERNAME=user FROM_EMAIL=user@example.com $0 custom
  
  # Test via Docker backend
  SMTP_USERNAME=myemail@gmail.com SMTP_PASSWORD=mypass FROM_EMAIL=myemail@gmail.com $0 docker-test

EOF
}

# Function to validate required variables
validate_variables() {
    if [[ -z "$SMTP_USERNAME" ]]; then
        print_color $RED "Error: SMTP_USERNAME is required"
        exit 1
    fi
    
    if [[ -z "$SMTP_PASSWORD" ]]; then
        print_color $RED "Error: SMTP_PASSWORD is required"
        exit 1
    fi
    
    if [[ -z "$FROM_EMAIL" ]]; then
        print_color $RED "Error: FROM_EMAIL is required"
        exit 1
    fi
}

# Function to create test email payload
create_test_payload() {
    cat << EOF
{
    "name": "SMTP Test User",
    "email": "${FROM_EMAIL}",
    "subject": "SMTP Configuration Test - $(date)",
    "message": "This is a test email to verify SMTP configuration.\n\nTest Details:\n- SMTP Server: ${SMTP_SERVER}\n- SMTP Port: ${SMTP_PORT}\n- TLS: ${SMTP_USE_TLS}\n- SSL: ${SMTP_USE_SSL}\n- STARTTLS: ${SMTP_STARTTLS}\n- Test Time: $(date)\n\nIf you receive this email, the SMTP configuration is working correctly."
}
EOF
}

# Function to test SMTP configuration via Python
test_smtp_python() {
    local server=$1
    local port=$2
    local use_tls=$3
    local use_ssl=$4
    local starttls=$5
    
    print_color $BLUE "Testing SMTP: $server:$port (TLS:$use_tls SSL:$use_ssl STARTTLS:$starttls)"
    
    python3 << EOF
import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
import sys

def test_smtp():
    try:
        # SMTP Configuration
        smtp_server = "$server"
        smtp_port = int("$port")
        username = os.environ.get("SMTP_USERNAME")
        password = os.environ.get("SMTP_PASSWORD")
        from_email = os.environ.get("FROM_EMAIL")
        to_email = os.environ.get("TO_EMAIL", "kamal.singh@architecturesolutions.co.uk")
        use_tls = "$use_tls".lower() == "true"
        use_ssl = "$use_ssl".lower() == "true"
        starttls = "$starttls".lower() == "true"
        
        # Create message
        message = MIMEMultipart()
        message["From"] = from_email
        message["To"] = to_email
        message["Subject"] = f"SMTP Test - {smtp_server}:{smtp_port}"
        
        body = f"""
This is a test email to verify SMTP configuration.

Configuration Details:
- SMTP Server: {smtp_server}
- SMTP Port: {smtp_port}
- Use TLS: {use_tls}
- Use SSL: {use_ssl}
- STARTTLS: {starttls}
- From: {from_email}
- To: {to_email}
- Test Time: $(date)

If you receive this email, the SMTP configuration is working correctly!
        """
        
        message.attach(MIMEText(body, "plain"))
        
        # Connect to server
        if use_ssl:
            print(f"Connecting with SSL to {smtp_server}:{smtp_port}")
            context = ssl.create_default_context()
            server = smtplib.SMTP_SSL(smtp_server, smtp_port, context=context)
        else:
            print(f"Connecting to {smtp_server}:{smtp_port}")
            server = smtplib.SMTP(smtp_server, smtp_port)
            
        server.set_debuglevel(1)
        
        if starttls and not use_ssl:
            print("Starting TLS...")
            context = ssl.create_default_context()
            server.starttls(context=context)
        
        # Login
        print(f"Logging in as {username}")
        server.login(username, password)
        
        # Send email
        print(f"Sending test email from {from_email} to {to_email}")
        text = message.as_string()
        server.sendmail(from_email, to_email, text)
        
        server.quit()
        print("✅ SMTP test successful! Email sent.")
        
    except Exception as e:
        print(f"❌ SMTP test failed: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    test_smtp()
EOF
}

# Function to test via Docker backend
test_docker_backend() {
    print_color $BLUE "Testing SMTP via Docker backend container..."
    
    # Check if backend container is running
    if ! docker ps | grep -q "portfolio-backend"; then
        print_color $YELLOW "Backend container not running. Starting it..."
        
        # Ensure network exists
        docker network create portfolio-network 2>/dev/null || true
        
        # Start MongoDB if not running
        if ! docker ps | grep -q "portfolio-mongodb"; then
            print_color $YELLOW "Starting MongoDB container..."
            docker run -d \
                --name portfolio-mongodb \
                --network portfolio-network \
                -e MONGO_INITDB_ROOT_USERNAME=admin \
                -e MONGO_INITDB_ROOT_PASSWORD=admin123 \
                mongo:6.0-alpine --quiet
            sleep 5
        fi
        
        # Start backend container
        docker run -d \
            --name portfolio-backend-test \
            --network portfolio-network \
            -p 8001:8001 \
            -e MONGO_URL=mongodb://portfolio-mongodb:27017/portfolio \
            -e SMTP_SERVER=${SMTP_SERVER:-smtp.gmail.com} \
            -e SMTP_PORT=${SMTP_PORT:-587} \
            -e SMTP_USE_TLS=${SMTP_USE_TLS:-true} \
            -e SMTP_USE_SSL=${SMTP_USE_SSL:-false} \
            -e SMTP_STARTTLS=${SMTP_STARTTLS:-true} \
            -e SMTP_USERNAME=${SMTP_USERNAME} \
            -e SMTP_PASSWORD=${SMTP_PASSWORD} \
            -e FROM_EMAIL=${FROM_EMAIL} \
            -e TO_EMAIL=${TO_EMAIL:-kamal.singh@architecturesolutions.co.uk} \
            kamal-portfolio:backend
            
        sleep 10
    fi
    
    # Test the contact form endpoint
    print_color $BLUE "Sending test email via backend API..."
    
    local payload=$(create_test_payload)
    local response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "$payload" \
        http://localhost:8001/api/contact)
    
    if echo "$response" | grep -q "success"; then
        print_color $GREEN "✅ Docker backend SMTP test successful!"
        echo "Response: $response"
    else
        print_color $RED "❌ Docker backend SMTP test failed!"
        echo "Response: $response"
        
        # Show container logs
        print_color $YELLOW "Backend container logs:"
        docker logs --tail 20 portfolio-backend-test
    fi
}

# Test configurations
test_gmail_tls() {
    export SMTP_SERVER="smtp.gmail.com"
    export SMTP_PORT="587"
    export SMTP_USE_TLS="true"
    export SMTP_USE_SSL="false" 
    export SMTP_STARTTLS="true"
    test_smtp_python $SMTP_SERVER $SMTP_PORT $SMTP_USE_TLS $SMTP_USE_SSL $SMTP_STARTTLS
}

test_gmail_ssl() {
    export SMTP_SERVER="smtp.gmail.com"
    export SMTP_PORT="465"
    export SMTP_USE_TLS="false"
    export SMTP_USE_SSL="true"
    export SMTP_STARTTLS="false"
    test_smtp_python $SMTP_SERVER $SMTP_PORT $SMTP_USE_TLS $SMTP_USE_SSL $SMTP_STARTTLS
}

test_outlook_tls() {
    export SMTP_SERVER="smtp-mail.outlook.com"
    export SMTP_PORT="587"
    export SMTP_USE_TLS="true"
    export SMTP_USE_SSL="false"
    export SMTP_STARTTLS="true"
    test_smtp_python $SMTP_SERVER $SMTP_PORT $SMTP_USE_TLS $SMTP_USE_SSL $SMTP_STARTTLS
}

test_outlook_ssl() {
    export SMTP_SERVER="smtp-mail.outlook.com"
    export SMTP_PORT="465"
    export SMTP_USE_TLS="false"
    export SMTP_USE_SSL="true"
    export SMTP_STARTTLS="false"
    test_smtp_python $SMTP_SERVER $SMTP_PORT $SMTP_USE_TLS $SMTP_USE_SSL $SMTP_STARTTLS
}

test_custom() {
    if [[ -z "$SMTP_SERVER" ]]; then
        print_color $RED "Error: SMTP_SERVER is required for custom test"
        exit 1
    fi
    
    test_smtp_python \
        ${SMTP_SERVER} \
        ${SMTP_PORT:-587} \
        ${SMTP_USE_TLS:-true} \
        ${SMTP_USE_SSL:-false} \
        ${SMTP_STARTTLS:-true}
}

test_all() {
    print_color $BLUE "Testing all common SMTP configurations..."
    
    print_color $YELLOW "\n=== Testing Gmail TLS ==="
    test_gmail_tls || true
    
    print_color $YELLOW "\n=== Testing Gmail SSL ==="
    test_gmail_ssl || true
    
    print_color $YELLOW "\n=== Testing Outlook TLS ==="
    test_outlook_tls || true
    
    print_color $YELLOW "\n=== Testing Outlook SSL ==="
    test_outlook_ssl || true
    
    print_color $GREEN "\nAll SMTP tests completed!"
}

# Function to clean up test containers
cleanup() {
    print_color $BLUE "Cleaning up test containers..."
    docker rm -f portfolio-backend-test portfolio-mongodb-test 2>/dev/null || true
}

# Main script logic
case "${1:-help}" in
    gmail-tls)
        validate_variables
        test_gmail_tls
        ;;
    gmail-ssl)
        validate_variables
        test_gmail_ssl
        ;;
    outlook-tls)
        validate_variables
        test_outlook_tls
        ;;
    outlook-ssl)
        validate_variables
        test_outlook_ssl
        ;;
    custom)
        validate_variables
        test_custom
        ;;
    all)
        validate_variables
        test_all
        ;;
    docker-test)
        validate_variables
        test_docker_backend
        ;;
    clean)
        cleanup
        print_color $GREEN "Cleanup completed"
        ;;
    help|--help|-h|*)
        show_usage
        ;;
esac