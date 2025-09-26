#!/bin/bash

# Script to create local media files and replace remote URLs
# Creates placeholder images for the Kamal Singh Portfolio

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

FRONTEND_DIR="/app/frontend"
IMAGES_DIR="$FRONTEND_DIR/public/images"

echo -e "${BLUE}🎨 Creating Local Media Files for Kamal Singh Portfolio${NC}"
echo "===================================================="

# Check if ImageMagick is available for creating actual images
if command -v convert &> /dev/null; then
    echo -e "${GREEN}✅ ImageMagick found - creating actual placeholder images${NC}"
    USE_IMAGEMAGICK=true
else
    echo -e "${YELLOW}⚠️ ImageMagick not found - creating SVG placeholders instead${NC}"
    echo -e "${BLUE}💡 To install ImageMagick: sudo apt-get install imagemagick${NC}"
    USE_IMAGEMAGICK=false
fi

# Function to create placeholder image
create_placeholder() {
    local filename=$1
    local width=$2
    local height=$3
    local title=$4
    local color=$5
    local output_path="$IMAGES_DIR/$filename"
    
    # Ensure directory exists
    mkdir -p "$(dirname "$output_path")"
    
    if $USE_IMAGEMAGICK; then
        # Create actual image with ImageMagick
        convert -size ${width}x${height} \
            -background "$color" \
            -fill white \
            -gravity center \
            -font Arial \
            -pointsize $((width/20)) \
            label:"$title" \
            "$output_path"
    else
        # Create SVG placeholder
        local svg_path="${output_path%.*}.svg"
        cat > "$svg_path" << EOF
<svg width="$width" height="$height" xmlns="http://www.w3.org/2000/svg">
    <rect width="100%" height="100%" fill="$color"/>
    <text x="50%" y="50%" font-family="Arial, sans-serif" font-size="${width/20}" 
          fill="white" text-anchor="middle" dominant-baseline="middle">$title</text>
</svg>
EOF
        echo -e "${BLUE}Created SVG: $svg_path${NC}"
    fi
}

echo -e "${BLUE}📁 Creating image directories...${NC}"
mkdir -p "$IMAGES_DIR"/{hero,about,skills,experience,projects,testimonials,contact,icons}

echo -e "${BLUE}🖼️ Creating placeholder images...${NC}"

# Hero section images
create_placeholder "hero/digital-tech-bg.jpg" 1920 1080 "Digital Technology Background" "#1e3a8a"

# About section images  
create_placeholder "about/professional-portrait.jpg" 800 800 "Professional Portrait" "#374151"

# Skills section images
create_placeholder "skills/tech-pattern.jpg" 1200 800 "Technology Patterns" "#0891b2"

# Experience section images
create_placeholder "experience/corporate-building.jpg" 1200 800 "Corporate Environment" "#475569"

# Projects section images
create_placeholder "projects/innovation-tech.jpg" 1200 800 "Innovation Technology" "#7c3aed"
create_placeholder "projects/digital-portal.jpg" 600 400 "Digital Portal" "#1e40af"
create_placeholder "projects/ciam-security.jpg" 600 400 "CIAM Security" "#dc2626"
create_placeholder "projects/cloud-migration.jpg" 600 400 "Cloud Migration" "#059669"
create_placeholder "projects/gaming-platform.jpg" 600 400 "Gaming Platform" "#ea580c"
create_placeholder "projects/commerce-platform.jpg" 600 400 "Commerce Platform" "#7c2d12"

# Testimonials images
create_placeholder "testimonials/testimonial-1.jpg" 400 300 "Professional 1" "#64748b"
create_placeholder "testimonials/testimonial-2.jpg" 400 300 "Professional 2" "#6b7280"  
create_placeholder "testimonials/testimonial-3.jpg" 400 300 "Professional 3" "#71717a"
create_placeholder "testimonials/testimonial-4.jpg" 400 300 "Professional 4" "#78716c"
create_placeholder "testimonials/testimonial-5.jpg" 400 300 "Professional 5" "#737373"
create_placeholder "testimonials/testimonial-6.jpg" 400 300 "Professional 6" "#6b7280"

# Contact section images
create_placeholder "contact/contact-bg.jpg" 1200 800 "Contact Innovation" "#5b21b6"

echo -e "${GREEN}✅ All placeholder images created${NC}"

echo -e "${BLUE}📋 Media files created:${NC}"
find "$IMAGES_DIR" -type f \( -name "*.jpg" -o -name "*.svg" \) | sort

echo -e "${GREEN}🎉 Local media creation completed!${NC}"
echo -e "${BLUE}💡 Next step: Update mock.js to use local paths${NC}"