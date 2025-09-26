#!/usr/bin/env python3
"""
Detailed reCAPTCHA Testing - Investigate the 500 error with reCAPTCHA tokens
"""

import requests
import json
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv('/app/frontend/.env')
load_dotenv('/app/backend/.env')

FRONTEND_BACKEND_URL = os.getenv('REACT_APP_BACKEND_URL', 'https://gateway-security.preview.emergentagent.com')
API_BASE_URL = f"{FRONTEND_BACKEND_URL}/api"

def test_recaptcha_with_different_tokens():
    """Test reCAPTCHA with different token formats"""
    print("Testing reCAPTCHA with different token formats...")
    
    test_cases = [
        ("Empty token", ""),
        ("Short invalid token", "invalid"),
        ("Long invalid token", "invalid_token_for_testing_purposes_long_format"),
        ("Valid format but fake token", "03AGdBq25SiWvhwjcJBgQSuO9iAOBhvSyRJaO9UoMRGsxQjzKv8FHJy7sJ2WjcJBgQSuO9iAOBhvSyRJaO9UoMRGsxQjzKv8FHJy7sJ2W")
    ]
    
    for test_name, token in test_cases:
        print(f"\n--- Testing: {test_name} ---")
        
        contact_data = {
            "name": "reCAPTCHA Test",
            "email": "test@example.com",
            "projectType": "Testing",
            "budget": "£10,000",
            "timeline": "1 month",
            "message": f"Testing {test_name}",
            "recaptcha_token": token
        }
        
        try:
            response = requests.post(f"{API_BASE_URL}/contact/send-email", 
                                   json=contact_data, 
                                   headers={"Content-Type": "application/json"},
                                   timeout=20)
            
            print(f"Status Code: {response.status_code}")
            
            if response.status_code == 500:
                print("❌ 500 Internal Server Error")
                try:
                    error_data = response.json()
                    print(f"Error: {error_data}")
                except:
                    print(f"Raw response: {response.text[:200]}")
            elif response.status_code == 400:
                try:
                    error_data = response.json()
                    print(f"✅ Proper validation error: {error_data}")
                except:
                    print(f"Raw response: {response.text[:200]}")
            elif response.status_code == 200:
                try:
                    success_data = response.json()
                    print(f"✅ Success: {success_data}")
                except:
                    print(f"Raw response: {response.text[:200]}")
            else:
                print(f"⚠️  Unexpected status: {response.status_code}")
                print(f"Response: {response.text[:200]}")
                
        except Exception as e:
            print(f"❌ Request failed: {e}")

def test_direct_recaptcha_verification():
    """Test direct reCAPTCHA verification with Google API"""
    print("\n\nTesting direct reCAPTCHA verification...")
    
    secret_key = os.getenv('RECAPTCHA_SECRET_KEY')
    print(f"Using secret key: {secret_key}")
    
    # Test with invalid token
    test_token = "invalid_token_for_testing"
    
    try:
        response = requests.post(
            'https://www.google.com/recaptcha/api/siteverify',
            data={
                'secret': secret_key,
                'response': test_token,
                'remoteip': '127.0.0.1'
            },
            timeout=10
        )
        
        print(f"Google API Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"Google API Response: {result}")
            
            success = result.get('success', False)
            errors = result.get('error-codes', [])
            
            print(f"Success: {success}")
            print(f"Error codes: {errors}")
            
            if 'invalid-input-response' in errors:
                print("✅ Expected 'invalid-input-response' error confirmed")
            else:
                print("⚠️  Different error than expected")
        else:
            print(f"❌ Google API error: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Direct verification failed: {e}")

if __name__ == "__main__":
    test_recaptcha_with_different_tokens()
    test_direct_recaptcha_verification()