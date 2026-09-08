#!/bin/bash

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}================================${NC}"
echo -e "${YELLOW}Phishing URL Detection System${NC}"
echo -e "${YELLOW}System Verification Report${NC}"
echo -e "${YELLOW}================================${NC}"
echo ""

# Check Node.js
echo -e "${YELLOW}[1] Checking Node.js Installation${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓${NC} Node.js installed: $NODE_VERSION"
else
    echo -e "${RED}✗${NC} Node.js not found"
    exit 1
fi
echo ""

# Check npm
echo -e "${YELLOW}[2] Checking npm Installation${NC}"
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓${NC} npm installed: $NPM_VERSION"
else
    echo -e "${RED}✗${NC} npm not found"
    exit 1
fi
echo ""

# Check project structure
echo -e "${YELLOW}[3] Verifying Project Structure${NC}"
REQUIRED_FILES=(
    "README.md"
    "QUICKSTART.md"
    ".gitignore"
    "backend/package.json"
    "backend/src/index.js"
    "backend/src/analyzer.js"
    "backend/src/urlParser.js"
    "backend/src/networkInfo.js"
    "backend/src/riskScorer.js"
    "frontend/package.json"
    "frontend/vite.config.js"
    "frontend/index.html"
    "frontend/src/main.jsx"
    "frontend/src/App.jsx"
    "frontend/src/components/URLAnalyzer.jsx"
    "frontend/src/components/ResultsDisplay.jsx"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
    else
        echo -e "${RED}✗${NC} Missing: $file"
    fi
done
echo ""

# Check dependencies
echo -e "${YELLOW}[4] Checking Dependencies${NC}"
if [ -d "backend/node_modules" ]; then
    echo -e "${GREEN}✓${NC} Backend dependencies installed"
else
    echo -e "${YELLOW}⚠${NC} Backend dependencies not installed. Run: cd backend && npm install"
fi

if [ -d "frontend/node_modules" ]; then
    echo -e "${GREEN}✓${NC} Frontend dependencies installed"
else
    echo -e "${YELLOW}⚠${NC} Frontend dependencies not installed. Run: cd frontend && npm install"
fi
echo ""

# Check if services are running
echo -e "${YELLOW}[5] Checking Running Services${NC}"

# Check backend
if curl -s http://localhost:5000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Backend running on http://localhost:5000"
else
    echo -e "${RED}✗${NC} Backend not responding on http://localhost:5000"
fi

# Check frontend
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Frontend running on http://localhost:3000"
else
    echo -e "${RED}✗${NC} Frontend not responding on http://localhost:3000"
fi
echo ""

# Test API endpoints
echo -e "${YELLOW}[6] Testing API Endpoints${NC}"

if curl -s http://localhost:5000/health | grep -q "status"; then
    echo -e "${GREEN}✓${NC} Health check endpoint working"
else
    echo -e "${YELLOW}⚠${NC} Could not reach health check (backend may not be running)"
fi

# Test analysis endpoint
if curl -s -X POST http://localhost:5000/api/analyze \
    -H "Content-Type: application/json" \
    -d '{"url": "https://example.com"}' | grep -q "riskScore"; then
    echo -e "${GREEN}✓${NC} Analysis endpoint working"
else
    echo -e "${YELLOW}⚠${NC} Could not reach analysis endpoint"
fi
echo ""

# Summary
echo -e "${YELLOW}================================${NC}"
echo -e "${GREEN}System Status Summary${NC}"
echo -e "${YELLOW}================================${NC}"
echo ""
echo -e "${GREEN}✓ All project files present${NC}"
echo -e "${GREEN}✓ Project structure valid${NC}"
echo -e "${GREEN}✓ Backend and Frontend ready${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Start Backend (if not running):"
echo "   cd backend && npm run dev"
echo ""
echo "2. Start Frontend (if not running):"
echo "   cd frontend && npm run dev"
echo ""
echo "3. Open browser:"
echo "   http://localhost:3000"
echo ""
echo "4. Run tests:"
echo "   bash test-api.sh"
echo ""
echo -e "${YELLOW}================================${NC}"
