#!/bin/bash
# Crystal Grimoire Beta0.2 - Quick Start Setup

echo "✨ Crystal Grimoire Beta0.2 - Quick Start Setup ✨"
echo "================================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if .env exists
if [ ! -f ../.env ]; then
    echo "📝 Creating .env file from template..."
    cp ../.env.template ../.env
    echo -e "${GREEN}✅ Created .env file${NC}"
    echo -e "${YELLOW}⚠️  Please edit .env and add your API keys${NC}"
else
    echo -e "${GREEN}✅ .env file already exists${NC}"
fi

# Check Flutter installation
echo ""
echo "🔍 Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    echo -e "${GREEN}✅ Flutter is installed${NC}"
    flutter --version
else
    echo -e "${RED}❌ Flutter is not installed${NC}"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Install Flutter dependencies
echo ""
echo "📦 Installing Flutter dependencies..."
cd .. && flutter pub get

# Check Python installation
echo ""
echo "🐍 Checking Python installation..."
if command -v python3 &> /dev/null; then
    echo -e "${GREEN}✅ Python 3 is installed${NC}"
    python3 --version
else
    echo -e "${RED}❌ Python 3 is not installed${NC}"
    echo "Please install Python 3.8 or higher"
    exit 1
fi

# Set up Python virtual environment
echo ""
echo "🔧 Setting up Python virtual environment..."
cd backend
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}✅ Created virtual environment${NC}"
fi

# Activate venv and install dependencies
source venv/bin/activate
pip install -r requirements.txt
echo -e "${GREEN}✅ Installed Python dependencies${NC}"

# Create necessary directories
echo ""
echo "📁 Creating directory structure..."
mkdir -p ../logs
mkdir -p ../temp
mkdir -p ../backups

# Initialize Git repository
echo ""
echo "🔄 Initializing Git repository..."
cd ..
if [ ! -d ".git" ]; then
    git init
    git add .
    git commit -m "Initial commit - Crystal Grimoire Beta0.2"
    echo -e "${GREEN}✅ Git repository initialized${NC}"
else
    echo -e "${GREEN}✅ Git repository already exists${NC}"
fi

# Create .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
    cat > .gitignore << 'EOF'
# Environment variables
.env
.env.local
.env.*.local

# Firebase
firebase-credentials.json
.firebase/
firebase-debug.log

# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/
*.iml
*.ipr
*.iws
.idea/

# Python
backend/venv/
backend/__pycache__/
*.py[cod]
*$py.class
*.so
.Python

# Logs
logs/
*.log

# OS
.DS_Store
Thumbs.db

# Editor
.vscode/
*.swp
*.swo

# Temporary files
temp/
*.tmp

# Secrets
*.pem
*.key
*.cert
EOF
    echo -e "${GREEN}✅ Created .gitignore${NC}"
fi

echo ""
echo "🚀 Quick Start Complete!"
echo "======================="
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. 🔑 Add your API keys to .env file:"
echo "   ${YELLOW}nano .env${NC}"
echo ""
echo "2. 🔥 Set up Firebase (if not done):"
echo "   ${YELLOW}./setup-firebase.sh${NC}"
echo ""
echo "3. 💳 Configure Stripe in the Stripe Dashboard"
echo "   See: ${YELLOW}docs/STRIPE_SETUP_GUIDE.md${NC}"
echo ""
echo "4. 🤖 Set up at least one LLM provider"
echo "   See: ${YELLOW}docs/LLM_API_SETUP_GUIDE.md${NC}"
echo ""
echo "5. 🏃 Run the development servers:"
echo ""
echo "   Backend:"
echo "   ${YELLOW}cd backend && source venv/bin/activate && python unified_backend.py${NC}"
echo ""
echo "   Frontend:"
echo "   ${YELLOW}flutter run -d web-server --web-port 3000${NC}"
echo ""
echo "6. 🌐 Open in browser:"
echo "   ${YELLOW}http://localhost:3000${NC}"
echo ""
echo -e "${GREEN}✨ Happy crystal gazing! ✨${NC}"