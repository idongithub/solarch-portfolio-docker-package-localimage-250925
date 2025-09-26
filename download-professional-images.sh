#!/bin/bash

# Professional Image Download Script for Corporate Portfolio
# Downloads high-quality corporate and technology images to replace SVG placeholders

echo "Starting professional image download..."

# Create image directories
cd /app/frontend/public/images

# BATCH 1: Corporate & Technology Images from First Request
echo "Downloading corporate and technology images..."

# Hero background - Modern glass building
curl -s "https://images.unsplash.com/photo-1547321568-f2e8dbaa32d1" -o hero/digital-tech-bg.jpg

# Experience section - Corporate building 
curl -s "https://images.unsplash.com/photo-1704423846283-f92ff6badea3" -o experience/corporate-building.jpg

# About section - Professional building architecture
curl -s "https://images.unsplash.com/photo-1521003216094-1413580c4e6d" -o about/professional-portrait.jpg

# Skills section - Modern corporate building
curl -s "https://images.unsplash.com/photo-1609349002260-b3efafcc3fcf" -o skills/tech-pattern.jpg

# Projects main background - Digital innovation/VR
curl -s "https://images.unsplash.com/photo-1530825894095-9c184b068fcb" -o projects/innovation-tech.jpg

# Individual project images
curl -s "https://images.pexels.com/photos/11158027/pexels-photo-11158027.jpeg" -o projects/digital-portal.jpg
curl -s "https://images.pexels.com/photos/418285/pexels-photo-418285.jpeg" -o projects/ciam-security.jpg
curl -s "https://images.pexels.com/photos/8728559/pexels-photo-8728559.jpeg" -o projects/cloud-migration.jpg

# BATCH 2: Professional Portraits & Additional Images from Second Request
echo "Downloading professional portraits and office images..."

# Testimonial professional portraits
curl -s "https://images.unsplash.com/photo-1544717297-fa95b6ee9643?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NDk1NzZ8MHwxfHNlYXJjaHwxfHxwcm9mZXNzaW9uYWwlMjBidXNpbmVzcyUyMHBvcnRyYWl0c3xlbnwwfHx8Ymx1ZXwxNzU3NzU5NjA3fDA&ixlib=rb-4.1.0&q=85" -o testimonials/testimonial-1.jpg

curl -s "https://images.unsplash.com/photo-1649768996403-455e21e6e4ec?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NDk1NzZ8MHwxfHNlYXJjaHwyfHxwcm9mZXNzaW9uYWwlMjBidXNpbmVzcyUyMHBvcnRyYWl0c3xlbnwwfHx8Ymx1ZXwxNzU3NzU5NjA3fDA&ixlib=rb-4.1.0&q=85" -o testimonials/testimonial-2.jpg

curl -s "https://images.unsplash.com/photo-1589386417686-0d34b5903d23?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NDk1NzZ8MHwxfHNlYXJjaHwzfHxwcm9mZXNzaW9uYWwlMjBidXNpbmVzcyUyMHBvcnRyYWl0c3xlbnwwfHx8Ymx1ZXwxNzU3NzU5NjA3fDA&ixlib=rb-4.1.0&q=85" -o testimonials/testimonial-3.jpg

curl -s "https://images.pexels.com/photos/7277960/pexels-photo-7277960.jpeg" -o testimonials/testimonial-4.jpg

# Additional testimonial images (reusing some for variety)
curl -s "https://images.unsplash.com/photo-1544717297-fa95b6ee9643?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NDk1NzZ8MHwxfHNlYXJjaHwxfHxwcm9mZXNzaW9uYWwlMjBidXNpbmVzcyUyMHBvcnRyYWl0c3xlbnwwfHx8Ymx1ZXwxNzU3NzU5NjA3fDA&ixlib=rb-4.1.0&q=85" -o testimonials/testimonial-5.jpg

curl -s "https://images.unsplash.com/photo-1649768996403-455e21e6e4ec?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NDk1NzZ8MHwxfHNlYXJjaHwyfHxwcm9mZXNzaW9uYWwlMjBidXNpbmVzcyUyMHBvcnRyYWl0c3xlbnwwfHx8Ymx1ZXwxNzU3NzU5NjA3fDA&ixlib=rb-4.1.0&q=85" -o testimonials/testimonial-6.jpg

# Contact section - Corporate office meeting
curl -s "https://images.unsplash.com/photo-1637665662134-db459c1bbb46?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NDk1NzZ8MHwxfHNlYXJjaHwxfHxjb3Jwb3JhdGUlMjBvZmZpY2UlMjBtZWV0aW5nfGVufDB8fHxibHVlfDE3NTc3NTk2MTN8MA&ixlib=rb-4.1.0&q=85" -o contact/contact-bg.jpg

# Additional project images
curl -s "https://images.unsplash.com/photo-1662098963427-fe6b7724d998?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NDk1NzZ8MHwxfHNlYXJjaHwzfHxjb3Jwb3JhdGUlMjBvZmZpY2UlMjBtZWV0aW5nfGVufDB8fHxibHVlfDE3NTc3NTk2MTN8MA&ixlib=rb-4.1.0&q=85" -o projects/gaming-platform.jpg

curl -s "https://images.unsplash.com/photo-1512686096451-a15c19314d59?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NDQ2NDN8MHwxfHNlYXJjaHwxfHx0ZWNobm9sb2d5JTIwd29ya3NwYWNlfGVufDB8fHxibHVlfDE3NTc3NTk2MTh8MA&ixlib=rb-4.1.0&q=85" -o projects/commerce-platform.jpg

echo "Download complete! Verifying downloaded images..."

# Verify downloads
echo "Image verification:"
find . -name "*.jpg" -type f -exec echo "✓ {}" \; | sort

echo "Professional image download complete!"
echo "Ready to update mock.js with new image paths..."