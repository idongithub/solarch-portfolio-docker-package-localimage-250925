#!/usr/bin/env python3
"""
Test script to verify requirements.txt compatibility
This helps identify dependency conflicts before deployment
"""

import subprocess
import sys
import tempfile
import os

def test_requirements_compatibility():
    """Test if requirements.txt has compatible dependencies"""
    print("🧪 Testing requirements.txt compatibility...")
    print("=" * 50)
    
    requirements_path = "/app/backend/requirements.txt"
    
    try:
        # Create a temporary virtual environment
        with tempfile.TemporaryDirectory() as temp_dir:
            venv_path = os.path.join(temp_dir, "test_venv")
            
            print("📦 Creating temporary virtual environment...")
            subprocess.run([
                sys.executable, "-m", "venv", venv_path
            ], check=True, capture_output=True)
            
            # Get pip path in virtual environment
            if os.name == 'nt':  # Windows
                pip_path = os.path.join(venv_path, "Scripts", "pip")
            else:  # Unix/Linux
                pip_path = os.path.join(venv_path, "bin", "pip")
            
            print("🔄 Installing requirements in test environment...")
            result = subprocess.run([
                pip_path, "install", "-r", requirements_path
            ], capture_output=True, text=True, timeout=300)
            
            if result.returncode == 0:
                print("✅ SUCCESS: All dependencies are compatible!")
                print("\n📊 Installation Summary:")
                
                # Test import of key packages
                python_path = os.path.join(venv_path, "bin", "python") if os.name != 'nt' else os.path.join(venv_path, "Scripts", "python")
                
                test_imports = [
                    "fastapi",
                    "uvicorn", 
                    "slowapi",
                    "httpx",
                    "bleach",
                    "h11"
                ]
                
                for package in test_imports:
                    try:
                        import_result = subprocess.run([
                            python_path, "-c", f"import {package}; print(f'{package}: OK')"
                        ], capture_output=True, text=True, timeout=10)
                        
                        if import_result.returncode == 0:
                            print(f"  ✅ {package}: Importable")
                        else:
                            print(f"  ❌ {package}: Import failed")
                    except subprocess.TimeoutExpired:
                        print(f"  ⚠️  {package}: Import timeout")
                
                return True
            else:
                print("❌ FAILURE: Dependency conflicts detected!")
                print("\n🔍 Error Details:")
                print(result.stderr)
                
                # Look for specific conflicts
                if "conflicting dependencies" in result.stderr.lower():
                    print("\n💡 Suggested Fix:")
                    print("1. Update conflicting package versions")
                    print("2. Use pip-tools to resolve dependencies")
                    print("3. Check for version incompatibilities")
                
                return False
                
    except subprocess.TimeoutExpired:
        print("⏰ TIMEOUT: Installation took too long (>5 minutes)")
        return False
    except Exception as e:
        print(f"🚨 ERROR: {e}")
        return False

def check_specific_conflicts():
    """Check for known problematic dependency patterns"""
    print("\n🔍 Checking for known conflicts...")
    
    with open("/app/backend/requirements.txt", "r") as f:
        requirements = f.read()
    
    conflicts = []
    
    # Known conflict patterns
    if "h11==0.16.0" in requirements and "httpx" in requirements:
        conflicts.append("h11 0.16.0 conflicts with httpx dependencies")
    
    if "pydantic==2." in requirements and "fastapi==" in requirements:
        # Check FastAPI version compatibility with Pydantic v2
        pass
    
    if conflicts:
        print("⚠️  Known conflicts detected:")
        for conflict in conflicts:
            print(f"  - {conflict}")
        return False
    else:
        print("✅ No known conflicts detected")
        return True

def show_key_versions():
    """Show versions of key packages"""
    print("\n📋 Key Package Versions:")
    
    key_packages = [
        "fastapi", "uvicorn", "h11", "httpx", "slowapi", 
        "bleach", "pydantic", "typing-extensions"
    ]
    
    with open("/app/backend/requirements.txt", "r") as f:
        requirements = f.read()
    
    for package in key_packages:
        for line in requirements.split('\n'):
            if line.startswith(f"{package}=="):
                version = line.split('==')[1]
                print(f"  📦 {package}: {version}")
                break

if __name__ == "__main__":
    print("🔧 Requirements.txt Compatibility Checker")
    print("=" * 50)
    
    # Show current versions
    show_key_versions()
    
    # Check known conflicts
    no_known_conflicts = check_specific_conflicts()
    
    if no_known_conflicts:
        # Test actual installation
        success = test_requirements_compatibility()
        
        if success:
            print("\n🎉 All tests passed! Requirements are compatible.")
            print("✅ Safe to proceed with deployment")
            sys.exit(0)
        else:
            print("\n❌ Compatibility test failed")
            print("🚨 Fix conflicts before deployment")
            sys.exit(1)
    else:
        print("\n❌ Known conflicts detected - skipping installation test")
        sys.exit(1)