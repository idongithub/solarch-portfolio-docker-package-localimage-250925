#!/usr/bin/env python3
"""
CORS Configuration Testing Suite - IP-based Origins Issue
Focused testing for the specific CORS issue reported by user:
- ✅ Domain works: https://portfolio.architecturesolutions.co.uk (emails send successfully)
- ❌ IP HTTP fails: http://192.168.86.75:3400 (CORS error)  
- ❌ IP HTTPS fails: https://192.168.86.75:3443 (CORS error)

Tests:
1. Current backend CORS origins configuration
2. CORS preflight OPTIONS requests from IP-based origins
3. Backend accessibility from different ports/origins
4. Verify if backend is running on the correct ports for IP access
"""

import requests
import json
import sys
import os
import subprocess
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
load_dotenv('/app/frontend/.env')
load_dotenv('/app/backend/.env')

print("CORS CONFIGURATION TESTING - IP-based Origins Issue")
print("=" * 80)
print("Testing CORS configuration specifically for IP-based origins that are failing")
print("User Report:")
print("✅ Domain works: https://portfolio.architecturesolutions.co.uk")
print("❌ IP HTTP fails: http://192.168.86.75:3400 (CORS error)")
print("❌ IP HTTPS fails: https://192.168.86.75:3443 (CORS error)")
print("=" * 80)

def test_backend_cors_configuration():
    """Test backend .env CORS configuration"""
    print("\n1. Testing Backend CORS Configuration...")
    
    try:
        env_path = "/app/backend/.env"
        if not os.path.exists(env_path):
            print("❌ Backend .env file not found")
            return False
            
        with open(env_path, 'r') as f:
            env_content = f.read()
            
        # Extract CORS_ORIGINS line
        cors_line = None
        for line in env_content.split('\n'):
            if line.startswith('CORS_ORIGINS='):
                cors_line = line
                break
                
        if cors_line:
            cors_origins = cors_line.replace('CORS_ORIGINS=', '').split(',')
            print(f"   Found CORS_ORIGINS configuration:")
            for i, origin in enumerate(cors_origins, 1):
                print(f"   {i}. {origin.strip()}")
                
            # Check for required origins
            required_origins = [
                "https://portfolio.architecturesolutions.co.uk",
                "http://192.168.86.75:3400", 
                "https://192.168.86.75:3443"
            ]
            
            found_origins = []
            for req_origin in required_origins:
                if any(req_origin in origin.strip() for origin in cors_origins):
                    found_origins.append(req_origin)
                    
            print(f"\n   Required origins found: {len(found_origins)}/{len(required_origins)}")
            for origin in found_origins:
                print(f"   ✅ {origin}")
                
            missing_origins = [o for o in required_origins if o not in found_origins]
            for origin in missing_origins:
                print(f"   ❌ {origin} - MISSING")
                
            if len(found_origins) == len(required_origins):
                print("✅ Backend CORS configuration PASSED - All required origins present")
                return True
            else:
                print("❌ Backend CORS configuration FAILED - Missing required origins")
                return False
        else:
            print("❌ CORS_ORIGINS not found in backend .env")
            return False
            
    except Exception as e:
        print(f"❌ Backend CORS configuration test FAILED: {e}")
        return False

def test_cors_preflight_options_requests():
    """Test CORS preflight OPTIONS requests for IP-based origins"""
    print("\n2. Testing CORS Preflight OPTIONS Requests...")
    
    # Test different backend URLs to find which one is accessible
    backend_urls = [
        "https://portfolio.architecturesolutions.co.uk/api",
        "https://gateway-security.preview.emergentagent.com/api",
        "http://localhost:8001/api"
    ]
    
    # Origins to test (the failing ones from user report)
    test_origins = [
        "http://192.168.86.75:3400",
        "https://192.168.86.75:3443",
        "https://portfolio.architecturesolutions.co.uk"  # Working one for comparison
    ]
    
    working_backend = None
    
    # Find a working backend URL first
    for backend_url in backend_urls:
        try:
            print(f"   Testing backend accessibility: {backend_url}/health")
            response = requests.get(f"{backend_url}/health", timeout=10, verify=False)
            if response.status_code == 200:
                try:
                    data = response.json()
                    if data.get("status") == "healthy":
                        working_backend = backend_url
                        print(f"   ✅ Found working backend: {backend_url}")
                        break
                except:
                    pass
        except:
            pass
    
    if not working_backend:
        print("   ❌ No accessible backend found for CORS testing")
        return False
    
    print(f"\n   Testing CORS preflight OPTIONS requests against: {working_backend}")
    
    cors_results = {}
    
    for origin in test_origins:
        print(f"\n   Testing origin: {origin}")
        
        try:
            # Test preflight OPTIONS request
            options_headers = {
                'Origin': origin,
                'Access-Control-Request-Method': 'POST',
                'Access-Control-Request-Headers': 'Content-Type'
            }
            
            options_response = requests.options(f"{working_backend}/contact/send-email", 
                                              headers=options_headers, 
                                              timeout=10, 
                                              verify=False)
            
            print(f"      OPTIONS status: {options_response.status_code}")
            
            # Check CORS headers in OPTIONS response
            cors_origin = options_response.headers.get('Access-Control-Allow-Origin')
            cors_methods = options_response.headers.get('Access-Control-Allow-Methods')
            cors_headers = options_response.headers.get('Access-Control-Allow-Headers')
            cors_credentials = options_response.headers.get('Access-Control-Allow-Credentials')
            
            print(f"      Access-Control-Allow-Origin: {cors_origin}")
            print(f"      Access-Control-Allow-Methods: {cors_methods}")
            print(f"      Access-Control-Allow-Headers: {cors_headers}")
            print(f"      Access-Control-Allow-Credentials: {cors_credentials}")
            
            # Test actual GET request with Origin header
            get_headers = {'Origin': origin}
            get_response = requests.get(f"{working_backend}/health", 
                                      headers=get_headers, 
                                      timeout=10, 
                                      verify=False)
            
            print(f"      GET status: {get_response.status_code}")
            get_cors_origin = get_response.headers.get('Access-Control-Allow-Origin')
            print(f"      GET Access-Control-Allow-Origin: {get_cors_origin}")
            
            # Determine if CORS is working for this origin
            cors_working = (
                (cors_origin == origin or cors_origin == '*') and
                (get_cors_origin == origin or get_cors_origin == '*') and
                options_response.status_code in [200, 204] and
                get_response.status_code == 200
            )
            
            cors_results[origin] = {
                'working': cors_working,
                'options_status': options_response.status_code,
                'get_status': get_response.status_code,
                'cors_origin': cors_origin,
                'get_cors_origin': get_cors_origin
            }
            
            if cors_working:
                print(f"      ✅ CORS working for {origin}")
            else:
                print(f"      ❌ CORS failing for {origin}")
                
        except Exception as e:
            print(f"      ❌ Error testing {origin}: {e}")
            cors_results[origin] = {'working': False, 'error': str(e)}
    
    # Summary
    print(f"\n   CORS Test Results Summary:")
    working_origins = 0
    for origin, result in cors_results.items():
        if result.get('working', False):
            print(f"   ✅ {origin}: WORKING")
            working_origins += 1
        else:
            print(f"   ❌ {origin}: FAILING")
            if 'error' in result:
                print(f"      Error: {result['error']}")
    
    print(f"\n   Working origins: {working_origins}/{len(test_origins)}")
    
    # Check specifically for the failing IP origins
    ip_http_working = cors_results.get("http://192.168.86.75:3400", {}).get('working', False)
    ip_https_working = cors_results.get("https://192.168.86.75:3443", {}).get('working', False)
    domain_working = cors_results.get("https://portfolio.architecturesolutions.co.uk", {}).get('working', False)
    
    print(f"\n   Specific Issue Analysis:")
    print(f"   Domain (https://portfolio.architecturesolutions.co.uk): {'✅ WORKING' if domain_working else '❌ FAILING'}")
    print(f"   IP HTTP (http://192.168.86.75:3400): {'✅ WORKING' if ip_http_working else '❌ FAILING'}")
    print(f"   IP HTTPS (https://192.168.86.75:3443): {'✅ WORKING' if ip_https_working else '❌ FAILING'}")
    
    if ip_http_working and ip_https_working:
        print("✅ CORS preflight testing PASSED - IP origins working")
        return True
    elif domain_working and not (ip_http_working and ip_https_working):
        print("⚠️  CORS preflight testing PARTIAL - Domain works but IP origins failing")
        return False
    else:
        print("❌ CORS preflight testing FAILED - Multiple origins failing")
        return False

def test_backend_accessibility_different_ports():
    """Test backend accessibility from different ports/origins"""
    print("\n3. Testing Backend Accessibility from Different Ports...")
    
    # Test different ways to access the backend
    backend_access_urls = [
        ("External Domain API", "https://portfolio.architecturesolutions.co.uk/api/health"),
        ("Preview Domain API", "https://gateway-security.preview.emergentagent.com/api/health"),
        ("Local Backend", "http://localhost:8001/api/health"),
        ("Local Backend (no /api)", "http://localhost:8001/health"),
        ("IP HTTP Frontend", "http://192.168.86.75:3400/api/health"),
        ("IP HTTPS Frontend", "https://192.168.86.75:3443/api/health")
    ]
    
    accessible_backends = []
    
    for name, url in backend_access_urls:
        try:
            print(f"   Testing {name}: {url}")
            response = requests.get(url, timeout=10, verify=False)
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    if data.get("status") == "healthy" and "timestamp" in data:
                        print(f"      ✅ ACCESSIBLE - Backend API responding")
                        accessible_backends.append((name, url))
                    else:
                        print(f"      ❌ ACCESSIBLE but invalid API response: {data}")
                except json.JSONDecodeError:
                    print(f"      ❌ ACCESSIBLE but non-JSON response (likely frontend HTML)")
                    print(f"         Response: {response.text[:100]}...")
            else:
                print(f"      ❌ NOT ACCESSIBLE - Status: {response.status_code}")
                
        except requests.exceptions.RequestException as e:
            print(f"      ❌ NOT ACCESSIBLE - Error: {e}")
    
    print(f"\n   Accessible backends: {len(accessible_backends)}")
    for name, url in accessible_backends:
        print(f"   ✅ {name}: {url}")
    
    if len(accessible_backends) > 0:
        print("✅ Backend accessibility testing PASSED - At least one backend accessible")
        return True
    else:
        print("❌ Backend accessibility testing FAILED - No backends accessible")
        return False

def test_cors_with_actual_contact_form():
    """Test CORS with actual contact form submission from IP origins"""
    print("\n4. Testing CORS with Actual Contact Form Submission...")
    
    # Find working backend
    backend_urls = [
        "https://portfolio.architecturesolutions.co.uk/api",
        "https://gateway-security.preview.emergentagent.com/api",
        "http://localhost:8001/api"
    ]
    
    working_backend = None
    for backend_url in backend_urls:
        try:
            response = requests.get(f"{backend_url}/health", timeout=5, verify=False)
            if response.status_code == 200:
                data = response.json()
                if data.get("status") == "healthy":
                    working_backend = backend_url
                    break
        except:
            continue
    
    if not working_backend:
        print("   ❌ No working backend found for contact form testing")
        return False
    
    print(f"   Testing contact form CORS against: {working_backend}")
    
    # Test contact form data
    contact_data = {
        "name": "CORS Test User",
        "email": "cors.test@architecturesolutions.co.uk",
        "projectType": "CORS Testing",
        "budget": "£10,000 - £25,000",
        "timeline": "1-2 months",
        "message": "Testing CORS functionality for IP-based frontend origins to ensure email functionality works from all frontend URLs."
    }
    
    # Test the failing IP origins specifically
    failing_origins = [
        "http://192.168.86.75:3400",
        "https://192.168.86.75:3443"
    ]
    
    working_origin = "https://portfolio.architecturesolutions.co.uk"
    
    print(f"\n   Testing working origin first: {working_origin}")
    try:
        headers = {
            'Origin': working_origin,
            'Content-Type': 'application/json'
        }
        
        response = requests.post(f"{working_backend}/contact/send-email", 
                               json=contact_data, 
                               headers=headers, 
                               timeout=15, 
                               verify=False)
        
        print(f"      Status: {response.status_code}")
        cors_header = response.headers.get('Access-Control-Allow-Origin')
        print(f"      CORS Header: {cors_header}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"      Response: {data.get('message', 'No message')}")
            print(f"      ✅ Working origin contact form: SUCCESS")
        else:
            print(f"      ❌ Working origin contact form: FAILED")
            
    except Exception as e:
        print(f"      ❌ Working origin error: {e}")
    
    # Test failing origins
    cors_issues = []
    
    for origin in failing_origins:
        print(f"\n   Testing failing origin: {origin}")
        try:
            headers = {
                'Origin': origin,
                'Content-Type': 'application/json'
            }
            
            # Test preflight first
            options_headers = {
                'Origin': origin,
                'Access-Control-Request-Method': 'POST',
                'Access-Control-Request-Headers': 'Content-Type'
            }
            
            options_response = requests.options(f"{working_backend}/contact/send-email", 
                                              headers=options_headers, 
                                              timeout=10, 
                                              verify=False)
            
            print(f"      Preflight status: {options_response.status_code}")
            preflight_cors = options_response.headers.get('Access-Control-Allow-Origin')
            print(f"      Preflight CORS: {preflight_cors}")
            
            # Test actual POST
            response = requests.post(f"{working_backend}/contact/send-email", 
                                   json=contact_data, 
                                   headers=headers, 
                                   timeout=15, 
                                   verify=False)
            
            print(f"      POST status: {response.status_code}")
            post_cors = response.headers.get('Access-Control-Allow-Origin')
            print(f"      POST CORS: {post_cors}")
            
            if response.status_code == 200 and (post_cors == origin or post_cors == '*'):
                print(f"      ✅ {origin}: CORS WORKING")
            else:
                print(f"      ❌ {origin}: CORS FAILING")
                cors_issues.append({
                    'origin': origin,
                    'preflight_status': options_response.status_code,
                    'preflight_cors': preflight_cors,
                    'post_status': response.status_code,
                    'post_cors': post_cors
                })
                
        except Exception as e:
            print(f"      ❌ {origin} error: {e}")
            cors_issues.append({
                'origin': origin,
                'error': str(e)
            })
    
    print(f"\n   CORS Issues Summary:")
    if len(cors_issues) == 0:
        print("   ✅ No CORS issues found - All IP origins working")
        return True
    else:
        print(f"   ❌ Found {len(cors_issues)} CORS issues:")
        for issue in cors_issues:
            origin = issue['origin']
            print(f"   - {origin}:")
            if 'error' in issue:
                print(f"     Error: {issue['error']}")
            else:
                print(f"     Preflight: {issue.get('preflight_status')} (CORS: {issue.get('preflight_cors')})")
                print(f"     POST: {issue.get('post_status')} (CORS: {issue.get('post_cors')})")
        return False

def test_backend_running_correct_ports():
    """Verify backend is running on correct ports for IP access"""
    print("\n5. Testing Backend Running on Correct Ports...")
    
    # Check if backend is running via supervisor
    try:
        result = subprocess.run(["sudo", "supervisorctl", "status", "backend"], 
                              capture_output=True, text=True, timeout=10)
        
        if "RUNNING" in result.stdout:
            print("   ✅ Backend service running via supervisor")
            
            # Extract PID if available
            if "pid" in result.stdout:
                pid_info = result.stdout.split("pid")[1].split(",")[0].strip()
                print(f"   Backend PID: {pid_info}")
        else:
            print("   ❌ Backend service not running via supervisor")
            print(f"   Status: {result.stdout}")
            
    except Exception as e:
        print(f"   ⚠️  Could not check supervisor status: {e}")
    
    # Check what ports are being used
    try:
        result = subprocess.run(["netstat", "-tlnp"], capture_output=True, text=True, timeout=10)
        
        if result.returncode == 0:
            netstat_output = result.stdout
            
            # Look for common backend ports
            backend_ports = ["8001", "3001", "8000"]
            found_ports = []
            
            for port in backend_ports:
                if f":{port}" in netstat_output:
                    found_ports.append(port)
                    print(f"   ✅ Port {port} is in use")
            
            if found_ports:
                print(f"   Found backend ports: {', '.join(found_ports)}")
            else:
                print("   ⚠️  No common backend ports found in netstat")
                
        else:
            print("   ⚠️  Could not run netstat to check ports")
            
    except Exception as e:
        print(f"   ⚠️  Could not check ports: {e}")
    
    # Test direct access to backend ports
    direct_urls = [
        "http://localhost:8001/health",
        "http://localhost:8001/api/health",
        "http://127.0.0.1:8001/health",
        "http://127.0.0.1:8001/api/health"
    ]
    
    working_direct = []
    
    for url in direct_urls:
        try:
            response = requests.get(url, timeout=5)
            if response.status_code == 200:
                data = response.json()
                if data.get("status") == "healthy":
                    working_direct.append(url)
                    print(f"   ✅ Direct access working: {url}")
        except:
            pass
    
    if working_direct:
        print(f"   ✅ Backend accessible directly on {len(working_direct)} URLs")
        return True
    else:
        print("   ❌ Backend not accessible directly on any tested ports")
        return False

def main():
    """Run CORS configuration tests focused on IP-based origins issue"""
    print("Starting CORS Configuration Testing...")
    
    tests = [
        ("Backend CORS Configuration", test_backend_cors_configuration),
        ("CORS Preflight OPTIONS Requests", test_cors_preflight_options_requests),
        ("Backend Accessibility Different Ports", test_backend_accessibility_different_ports),
        ("CORS with Actual Contact Form", test_cors_with_actual_contact_form),
        ("Backend Running Correct Ports", test_backend_running_correct_ports)
    ]
    
    passed_tests = 0
    total_tests = len(tests)
    failed_tests = []
    
    for test_name, test_func in tests:
        print(f"\n{'='*60}")
        try:
            if test_func():
                passed_tests += 1
                print(f"✅ {test_name}: PASSED")
            else:
                failed_tests.append(test_name)
                print(f"❌ {test_name}: FAILED")
        except Exception as e:
            print(f"❌ {test_name}: FAILED with exception: {e}")
            failed_tests.append(test_name)
    
    print(f"\n{'='*80}")
    print("CORS CONFIGURATION TEST RESULTS")
    print(f"{'='*80}")
    print(f"Total Tests: {total_tests}")
    print(f"Passed: {passed_tests}")
    print(f"Failed: {len(failed_tests)}")
    
    if failed_tests:
        print(f"\nFailed Tests:")
        for test in failed_tests:
            print(f"  - {test}")
    
    print(f"\n📊 CORS ISSUE ANALYSIS:")
    print(f"The user reported:")
    print(f"✅ Domain works: https://portfolio.architecturesolutions.co.uk")
    print(f"❌ IP HTTP fails: http://192.168.86.75:3400 (CORS error)")
    print(f"❌ IP HTTPS fails: https://192.168.86.75:3443 (CORS error)")
    print(f"\nThis testing suite specifically targets these CORS issues.")
    
    if passed_tests >= 3:  # At least 3 out of 5 tests should pass
        print("\n✅ CORS CONFIGURATION TESTING MOSTLY PASSED")
        print("Backend CORS configuration appears to be working correctly.")
        print("If IP origins are still failing, the issue may be in the frontend routing or external proxy configuration.")
        return True
    else:
        print("\n❌ CORS CONFIGURATION TESTING FAILED")
        print("Significant CORS configuration issues found that need attention.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)