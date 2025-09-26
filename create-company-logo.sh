#!/bin/bash

# Create professional IT solution provider company logo
# This will create an SVG logo that reflects IT architecture and solutions

echo "Creating professional IT solution provider logo..."

# Create logo directory
mkdir -p /app/frontend/public/images/logo

# Create a professional IT solution provider logo SVG
cat > /app/frontend/public/images/logo/company-logo.svg << 'EOF'
<svg width="120" height="40" viewBox="0 0 120 40" xmlns="http://www.w3.org/2000/svg">
  <!-- Background gradient circle -->
  <defs>
    <linearGradient id="logoGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#3B82F6;stop-opacity:1" />
      <stop offset="50%" style="stop-color:#1E40AF;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#1E3A8A;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="textGradient" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#F59E0B;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#D97706;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- Main logo circle with IT symbol -->
  <circle cx="20" cy="20" r="18" fill="url(#logoGradient)" stroke="#F59E0B" stroke-width="1.5"/>
  
  <!-- IT Architecture symbol - interconnected nodes -->
  <g transform="translate(20,20)">
    <!-- Central node -->
    <circle cx="0" cy="0" r="3" fill="#F59E0B"/>
    
    <!-- Connected nodes -->
    <circle cx="-8" cy="-6" r="2" fill="#60A5FA"/>
    <circle cx="8" cy="-6" r="2" fill="#60A5FA"/>
    <circle cx="-8" cy="6" r="2" fill="#60A5FA"/>
    <circle cx="8" cy="6" r="2" fill="#60A5FA"/>
    
    <!-- Connection lines -->
    <line x1="0" y1="0" x2="-8" y2="-6" stroke="#F59E0B" stroke-width="1.5" opacity="0.8"/>
    <line x1="0" y1="0" x2="8" y2="-6" stroke="#F59E0B" stroke-width="1.5" opacity="0.8"/>
    <line x1="0" y1="0" x2="-8" y2="6" stroke="#F59E0B" stroke-width="1.5" opacity="0.8"/>
    <line x1="0" y1="0" x2="8" y2="6" stroke="#F59E0B" stroke-width="1.5" opacity="0.8"/>
    
    <!-- Cross connections -->
    <line x1="-8" y1="-6" x2="8" y2="6" stroke="#60A5FA" stroke-width="1" opacity="0.6"/>
    <line x1="8" y1="-6" x2="-8" y2="6" stroke="#60A5FA" stroke-width="1" opacity="0.6"/>
  </g>
  
  <!-- Company text -->
  <text x="45" y="15" font-family="serif" font-size="11" font-weight="bold" fill="url(#textGradient)">
    ARCHSOL
  </text>
  <text x="45" y="28" font-family="serif" font-size="8" fill="#94A3B8">
    IT Solutions
  </text>
</svg>
EOF

echo "✓ Professional IT solution provider logo created at /app/frontend/public/images/logo/company-logo.svg"
echo "Logo features:"
echo "  - Professional network architecture symbol"
echo "  - Blue gradient background representing technology"
echo "  - Gold accents matching site color scheme"
echo "  - 'ARCHSOL IT Solutions' branding"
echo "  - Scalable SVG format for all screen sizes"