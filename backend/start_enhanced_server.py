#!/usr/bin/env python3

# Startup script for enhanced Kamal Singh Portfolio backend
# This script starts the enhanced server with email functionality

import os
import sys
import subprocess
from pathlib import Path

def main():
    # Set the current directory to the backend directory
    backend_dir = Path(__file__).parent
    os.chdir(backend_dir)
    
    print("🚀 Starting Kamal Singh Portfolio Enhanced Backend...")
    print("====================================================")
    
    # Check if .env file exists
    if not Path('.env').exists():
        print("❌ .env file not found")
        print("💡 Please create .env file from .env.production.example")
        sys.exit(1)
    
    # Check if enhanced_server.py exists
    if not Path('enhanced_server.py').exists():
        print("❌ enhanced_server.py not found")
        print("💡 Using original server.py instead")
        server_module = "server:app"
    else:
        print("✅ Using enhanced server with email functionality")
        server_module = "enhanced_server:app"
    
    # Check if virtual environment is activated
    if not os.environ.get('VIRTUAL_ENV'):
        print("⚠️ Virtual environment not detected")
        print("💡 Recommend activating virtual environment: source venv/bin/activate")
    
    # Start the server
    try:
        print(f"🔧 Starting {server_module}...")
        print("📍 Backend will be available at: http://localhost:8001")
        print("📚 API Documentation: http://localhost:8001/docs")
        print("Press Ctrl+C to stop the server")
        print("")
        
        # Run uvicorn with the appropriate server
        subprocess.run([
            sys.executable, "-m", "uvicorn", 
            server_module,
            "--host", "0.0.0.0",
            "--port", "8001", 
            "--reload"
        ])
        
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except FileNotFoundError:
        print("❌ uvicorn not found. Please install requirements:")
        print("pip install -r requirements.txt")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error starting server: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()