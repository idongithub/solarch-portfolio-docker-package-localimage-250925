#!/bin/bash

# Script to generate C4 diagrams for Kamal Singh Portfolio
# Converts PlantUML files to PNG images

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

DOCS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$DOCS_DIR/images"

echo -e "${BLUE}🎨 Generating C4 Diagrams for Kamal Singh Portfolio${NC}"
echo "=================================================="

# Check if PlantUML is available
if ! command -v plantuml &> /dev/null; then
    echo -e "${YELLOW}⚠️ PlantUML not found. Installing...${NC}"
    
    # Try to install PlantUML
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y plantuml
    elif command -v brew &> /dev/null; then
        brew install plantuml
    elif command -v java &> /dev/null; then
        echo -e "${YELLOW}Downloading PlantUML JAR...${NC}"
        curl -L http://sourceforge.net/projects/plantuml/files/plantuml.jar/download -o plantuml.jar
        alias plantuml='java -jar plantuml.jar'
    else
        echo -e "${RED}❌ Cannot install PlantUML. Please install manually:${NC}"
        echo "   • Ubuntu/Debian: sudo apt-get install plantuml"
        echo "   • macOS: brew install plantuml"
        echo "   • Or visit: https://plantuml.com/download"
        exit 1
    fi
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# List of diagrams to generate
DIAGRAMS=(
    "c4-context-diagram.puml:System Context Diagram"
    "c4-container-diagram.puml:Container Diagram"
    "c4-component-backend.puml:Backend Component Diagram"
    "c4-component-frontend.puml:Frontend Component Diagram"
    "c4-deployment-diagram.puml:Deployment Diagram"
    "c4-data-flow-diagram.puml:Data Flow Diagram"
    "c4-technology-stack.puml:Technology Stack Diagram"
)

echo -e "${BLUE}📊 Generating diagrams...${NC}"
echo ""

# Generate each diagram
for diagram_info in "${DIAGRAMS[@]}"; do
    IFS=':' read -r file_name description <<< "$diagram_info"
    
    if [ -f "$DOCS_DIR/$file_name" ]; then
        echo -e "${YELLOW}🔄 Generating: $description${NC}"
        
        # Generate PNG
        plantuml -tpng "$DOCS_DIR/$file_name" -o "$OUTPUT_DIR" || {
            echo -e "${RED}❌ Failed to generate $file_name${NC}"
            continue
        }
        
        # Generate SVG (vector format)
        plantuml -tsvg "$DOCS_DIR/$file_name" -o "$OUTPUT_DIR" || {
            echo -e "${YELLOW}⚠️ SVG generation failed for $file_name${NC}"
        }
        
        echo -e "${GREEN}✅ Generated: $description${NC}"
    else
        echo -e "${RED}❌ File not found: $file_name${NC}"
    fi
done

echo ""
echo -e "${GREEN}🎉 Diagram generation completed!${NC}"
echo ""
echo -e "${BLUE}📁 Generated files in: $OUTPUT_DIR${NC}"
ls -la "$OUTPUT_DIR" 2>/dev/null || echo "No files generated"

echo ""
echo -e "${BLUE}🌐 Online Rendering Options:${NC}"
echo "1. PlantUML Online: http://www.plantuml.com/plantuml/uml/"
echo "2. GitHub: Renders .puml files automatically in README"
echo "3. VS Code: Install PlantUML extension, press Alt+D"

echo ""
echo -e "${BLUE}📖 Diagram Descriptions:${NC}"
echo "• Context: High-level system overview with external actors"
echo "• Container: Main application containers and technologies"  
echo "• Components: Detailed internal component structure"
echo "• Deployment: Infrastructure and deployment options"
echo "• Data Flow: Contact form processing workflow"
echo "• Technology: Complete technology stack relationships"

echo ""
echo -e "${GREEN}📊 Architecture documentation is ready!${NC}"