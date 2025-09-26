#!/bin/bash

# IT-Specific Professional Image Download Script
# Downloads high-quality IT and technology images for IT Portfolio Architect

echo "Starting IT-specific professional image download..."

# Create backup of current images
cd /app/frontend/public/images
mkdir -p backup_corporate_images
cp -r * backup_corporate_images/ 2>/dev/null || true

echo "Downloading IT and technology-specific images..."

# BATCH 1: Software Development & IT Professional Images
echo "Downloading software development and IT professional images..."

# Hero background - Code on monitor with blue lighting (perfect for IT Portfolio Architect)
curl -s "https://images.unsplash.com/photo-1607799279861-4dd421887fb3?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NTY2NzZ8MHwxfHNlYXJjaHwxfHxzb2Z0d2FyZSUyMGRldmVsb3BtZW50fGVufDB8fHxibHVlfDE3NTc3NjA5NzN8MA&ixlib=rb-4.1.0&q=85" -o hero/digital-tech-bg.jpg

# About section - IT Professional brainstorming
curl -s "https://images.unsplash.com/photo-1606588984221-7ab3e2bb038a?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NDQ2NDF8MHwxfHNlYXJjaHwyfHxpbmZvcm1hdGlvbiUyMHRlY2hub2xvZ3klMjBwcm9mZXNzaW9uYWx8ZW58MHx8fGJsdWV8MTc1Nzc2MDk1N3ww&ixlib=rb-4.1.0&q=85" -o about/professional-portrait.jpg

# Skills section - Code on laptop screen
curl -s "https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NTY2NzZ8MHwxfHNlYXJjaHwyfHxzb2Z0d2FyZSUyMGRldmVsb3BtZW50fGVufDB8fHxibHVlfDE3NTc3NjA5NzN8MA&ixlib=rb-4.1.0&q=85" -o skills/tech-pattern.jpg

# Experience section - Server room with blue lighting
curl -s "https://images.unsplash.com/photo-1569660424259-87e64a80f6fc" -o experience/corporate-building.jpg

# BATCH 2: Data Center & IT Infrastructure Images
echo "Downloading data center and IT infrastructure images..."

# Projects main background - Digital architecture visualization
curl -s "https://images.unsplash.com/photo-1655665436887-ba6f4aef4eb0" -o projects/innovation-tech.jpg

# Individual project images with IT focus
curl -s "https://images.unsplash.com/photo-1591439657848-9f4b9ce436b9?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NTY2NzZ8MHwxfHNlYXJjaHwzfHxzb2Z0d2FyZSUyMGRldmVsb3BtZW50fGVufDB8fHxibHVlfDE3NTc3NjA5NzN8MA&ixlib=rb-4.1.0&q=85" -o projects/digital-portal.jpg

curl -s "https://images.unsplash.com/photo-1616506436028-1980ead3ebe7?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NTY2Njl8MHwxfHNlYXJjaHwzfHxzZXJ2ZXIlMjByb29tfGVufDB8fHxibHVlfDE3NTc3NjA5Njd8MA&ixlib=rb-4.1.0&q=85" -o projects/ciam-security.jpg

curl -s "https://images.unsplash.com/photo-1664526937033-fe2c11f1be25" -o projects/cloud-migration.jpg

curl -s "https://images.unsplash.com/photo-1576272531110-2a342fe22342?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NTY2NzZ8MHwxfHNlYXJjaHw0fHxzb2Z0d2FyZSUyMGRldmVsb3BtZW50fGVufDB8fHxibHVlfDE3NTc3NjA5NzN8MA&ixlib=rb-4.1.0&q=85" -o projects/gaming-platform.jpg

curl -s "https://images.unsplash.com/photo-1600132806370-bf17e65e942f?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NDk1ODB8MHwxfHNlYXJjaHwxfHxjbG91ZCUyMGNvbXB1dGluZ3xlbnwwfHx8Ymx1ZXwxNzU3NzYwOTc5fDA&ixlib=rb-4.1.0&q=85" -o projects/commerce-platform.jpg

# BATCH 3: IT Professional Portraits for Testimonials  
echo "Downloading IT professional portraits for testimonials..."

# Generate variety for testimonials using available IT professional images
curl -s "https://images.unsplash.com/photo-1606588984221-7ab3e2bb038a?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NDQ2NDF8MHwxfHNlYXJjaHwyfHxpbmZvcm1hdGlvbiUyMHRlY2hub2xvZ3klMjBwcm9mZXNzaW9uYWx8ZW58MHx8fGJsdWV8MTc1Nzc2MDk1N3ww&ixlib=rb-4.1.0&q=85" -o testimonials/testimonial-1.jpg

curl -s "https://images.pexels.com/photos/5475750/pexels-photo-5475750.jpeg" -o testimonials/testimonial-2.jpg

curl -s "https://images.pexels.com/photos/8728559/pexels-photo-8728559.jpeg" -o testimonials/testimonial-3.jpg

curl -s "https://images.pexels.com/photos/7789851/pexels-photo-7789851.jpeg" -o testimonials/testimonial-4.jpg

curl -s "https://images.pexels.com/photos/16053029/pexels-photo-16053029.jpeg" -o testimonials/testimonial-5.jpg

curl -s "https://images.pexels.com/photos/190448/pexels-photo-190448.jpeg" -o testimonials/testimonial-6.jpg

# Contact section - IT infrastructure/network concept
curl -s "https://images.unsplash.com/photo-1664526937033-fe2c11f1be25" -o contact/contact-bg.jpg

echo "Download complete! Verifying IT-specific images..."

# Verify downloads
echo "IT Image verification:"
find . -name "*.jpg" -type f -exec echo "✓ {}" \; | sort

echo "IT-specific professional image download complete!"
echo "Images now focus on: software development, data centers, IT infrastructure, enterprise architecture, and IT professionals"