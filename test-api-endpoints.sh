#!/bin/bash

# API Endpoint Testing Script for Kamal Singh Portfolio
# Tests all available API endpoints and shows browser-accessible URLs

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default backend URL
BACKEND_URL="${BACKEND_URL:-http://localhost:8001}"

# Function to print colored output
print_color() {
    printf "${1}%s${NC}\n" "$2"
}

# Function to print section headers
print_header() {
    echo ""
    print_color $CYAN "============================================"
    print_color $CYAN "$1"
    print_color $CYAN "============================================"
}

# Function to test GET endpoint
test_get_endpoint() {
    local endpoint="$1"
    local description="$2"
    local full_url="${BACKEND_URL}${endpoint}"
    
    print_color $YELLOW "\n🔍 Testing: $description"
    print_color $BLUE "URL: $full_url"
    print_color $BLUE "Browser: You can open this URL directly in your browser"
    
    echo -n "Response: "
    
    # Test with curl and show response
    if response=$(curl -s -w "\n%{http_code}" "$full_url" 2>/dev/null); then
        http_code=$(echo "$response" | tail -n1)
        response_body=$(echo "$response" | head -n -1)
        
        if [ "$http_code" = "200" ]; then
            print_color $GREEN "✅ SUCCESS (HTTP $http_code)"
            echo "$response_body" | jq '.' 2>/dev/null || echo "$response_body"
        else
            print_color $RED "❌ FAILED (HTTP $http_code)"
            echo "$response_body"
        fi
    else
        print_color $RED "❌ CONNECTION FAILED"
        echo "Cannot connect to backend server at $full_url"
    fi
}

# Function to test POST endpoint
test_post_endpoint() {
    local endpoint="$1"
    local description="$2"
    local data="$3"
    local full_url="${BACKEND_URL}${endpoint}"
    
    print_color $YELLOW "\n📤 Testing: $description"
    print_color $BLUE "URL: $full_url"
    print_color $BLUE "Method: POST (cannot test directly in browser)"
    print_color $CYAN "Data: $data"
    
    echo -n "Response: "
    
    # Test with curl and show response
    if response=$(curl -s -w "\n%{http_code}" -X POST \
                      -H "Content-Type: application/json" \
                      -d "$data" \
                      "$full_url" 2>/dev/null); then
        http_code=$(echo "$response" | tail -n1)
        response_body=$(echo "$response" | head -n -1)
        
        if [ "$http_code" = "200" ]; then
            print_color $GREEN "✅ SUCCESS (HTTP $http_code)"
            echo "$response_body" | jq '.' 2>/dev/null || echo "$response_body"
        else
            print_color $RED "❌ FAILED (HTTP $http_code)"
            echo "$response_body"
        fi
    else
        print_color $RED "❌ CONNECTION FAILED"
        echo "Cannot connect to backend server at $full_url"
    fi
}

# Function to check if backend is running
check_backend_status() {
    print_header "Backend Server Status Check"
    
    if curl -s --connect-timeout 5 "$BACKEND_URL/" >/dev/null 2>&1; then
        print_color $GREEN "✅ Backend server is running at $BACKEND_URL"
    else
        print_color $RED "❌ Backend server is not accessible at $BACKEND_URL"
        print_color $YELLOW "💡 Make sure the backend server is running:"
        print_color $YELLOW "   cd /app/backend && python server.py"
        print_color $YELLOW "   or check if it's running on a different port"
        echo ""
        exit 1
    fi
}

# Function to show browser instructions
show_browser_instructions() {
    print_header "Browser Testing Instructions"
    
    print_color $GREEN "📱 You can test these GET endpoints directly in your browser:"
    echo ""
    print_color $YELLOW "1. API Information:"
    echo "   $BACKEND_URL/"
    echo ""
    print_color $YELLOW "2. Simple Health Check:"
    echo "   $BACKEND_URL/api/"
    echo ""
    print_color $YELLOW "3. Extended Health Check:"
    echo "   $BACKEND_URL/api/health"
    echo ""
    print_color $YELLOW "4. Portfolio Statistics:"
    echo "   $BACKEND_URL/api/portfolio/stats"
    echo ""
    print_color $YELLOW "5. Skills and Expertise:"
    echo "   $BACKEND_URL/api/portfolio/skills"
    echo ""
    print_color $YELLOW "6. System Status (if MongoDB enabled):"
    echo "   $BACKEND_URL/api/status"
    echo ""
    print_color $BLUE "💡 Tip: Install a JSON formatter browser extension for better readability"
    print_color $BLUE "💡 Use F12 Developer Tools → Network tab to see detailed responses"
}

# Function to show interactive documentation
show_interactive_docs() {
    print_header "Interactive API Documentation"
    
    print_color $GREEN "📚 FastAPI provides automatic interactive documentation:"
    echo ""
    print_color $YELLOW "Swagger UI (recommended):"
    echo "   $BACKEND_URL/docs"
    echo ""
    print_color $YELLOW "ReDoc Documentation:"
    echo "   $BACKEND_URL/redoc"
    echo ""
    print_color $BLUE "💡 These provide a web interface to test all endpoints interactively"
}

# Main testing function
run_api_tests() {
    print_header "API Endpoint Testing Results"
    
    # Test GET endpoints (browser accessible)
    test_get_endpoint "/" "Root API Information"
    test_get_endpoint "/api/" "Basic API Health Check" 
    test_get_endpoint "/api/health" "Extended Health Check"
    test_get_endpoint "/api/portfolio/stats" "Portfolio Statistics"
    test_get_endpoint "/api/portfolio/skills" "Skills and Expertise"
    test_get_endpoint "/api/status" "System Status (MongoDB required)"
    
    # Test POST endpoints (curl only)
    print_color $CYAN "\n============================================"
    print_color $CYAN "POST Endpoints (curl/frontend only)"
    print_color $CYAN "============================================"
    
    # Contact form test
    contact_data='{
        "name": "API Test User",
        "email": "test@example.com",
        "projectType": "API Testing",
        "budget": "$1k-5k", 
        "timeline": "1 month",
        "message": "This is a test message from the API testing script to verify the contact form endpoint functionality."
    }'
    test_post_endpoint "/api/contact/send-email" "Contact Form Submission" "$contact_data"
    
    # Status creation test (if MongoDB enabled)
    status_data='{"client_name": "api-test-client"}'
    test_post_endpoint "/api/status" "Create Status Check (MongoDB required)" "$status_data"
}

# Show usage information
show_usage() {
    print_header "API Testing Script"
    
    print_color $GREEN "This script tests all available API endpoints for the Kamal Singh Portfolio backend."
    echo ""
    print_color $YELLOW "Usage:"
    echo "  $0 [test|browser|docs|help]"
    echo ""
    print_color $YELLOW "Commands:"
    echo "  test     - Run comprehensive API endpoint tests (default)"
    echo "  browser  - Show browser-accessible URLs"
    echo "  docs     - Show interactive documentation URLs"
    echo "  help     - Show this usage information"
    echo ""
    print_color $YELLOW "Environment Variables:"
    echo "  BACKEND_URL  - Backend server URL (default: http://localhost:8001)"
    echo ""
    print_color $YELLOW "Examples:"
    echo "  ./test-api-endpoints.sh test"
    echo "  BACKEND_URL=https://api.yourdomain.com ./test-api-endpoints.sh test"
    echo "  ./test-api-endpoints.sh browser"
}

# Main script logic
case "${1:-test}" in
    test)
        check_backend_status
        run_api_tests
        echo ""
        show_browser_instructions
        show_interactive_docs
        ;;
    browser)
        show_browser_instructions
        ;;
    docs)
        show_interactive_docs
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        show_usage
        ;;
esac

print_color $GREEN "\n🎉 API testing complete!"
print_color $BLUE "For detailed API documentation, see: /app/API_DOCUMENTATION.md"