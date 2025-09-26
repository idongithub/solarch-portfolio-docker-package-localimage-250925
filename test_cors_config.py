#!/usr/bin/env python3
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv('/app/backend/.env')

cors_origins = os.environ.get('CORS_ORIGINS', 'not found')
print(f"CORS_ORIGINS from environment: {cors_origins}")

# Split and check
if cors_origins != 'not found':
    origins_list = cors_origins.split(',')
    print(f"Origins list: {origins_list}")
    
    test_origin = "https://portfolio.architecturesolutions.co.uk"
    if test_origin in origins_list:
        print(f"✅ {test_origin} is in CORS origins")
    else:
        print(f"❌ {test_origin} is NOT in CORS origins")
else:
    print("❌ CORS_ORIGINS environment variable not found")