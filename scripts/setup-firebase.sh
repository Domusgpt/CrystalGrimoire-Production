#!/bin/bash
# Crystal Grimoire Beta0.2 - Firebase Setup Script

echo "🔥 Crystal Grimoire Firebase Setup"
echo "================================="
echo ""
echo "This script will guide you through setting up Firebase for Crystal Grimoire."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command_exists node; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js first.${NC}"
    exit 1
fi

if ! command_exists npm; then
    echo -e "${RED}❌ npm is not installed. Please install npm first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"
echo ""

# Install Firebase CLI if not already installed
if ! command_exists firebase; then
    echo "📦 Installing Firebase CLI..."
    npm install -g firebase-tools
else
    echo -e "${GREEN}✅ Firebase CLI already installed${NC}"
fi

echo ""
echo "🔐 Firebase Authentication"
echo "========================="
echo "You'll now be redirected to your browser to log in to Firebase."
echo "Press Enter to continue..."
read

firebase login

echo ""
echo "🏗️  Creating Firebase Project"
echo "==========================="
echo ""
echo "Enter a unique project ID for your Firebase project"
echo "(e.g., crystal-grimoire-prod-12345):"
read -p "Project ID: " PROJECT_ID

echo ""
echo "Enter a display name for your project:"
read -p "Project Name: " PROJECT_NAME

# Create Firebase project
firebase projects:create "$PROJECT_ID" --display-name "$PROJECT_NAME"

echo ""
echo "🔧 Configuring Firebase Services"
echo "==============================="

# Initialize Firebase in the project
firebase use "$PROJECT_ID"

# Create firebase.json configuration
cat > ../firebase.json << EOF
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  },
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "functions": {
    "source": "functions",
    "predeploy": [
      "npm --prefix \"\$RESOURCE_DIR\" run lint"
    ]
  }
}
EOF

# Create Firestore rules
cat > ../firestore.rules << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Usage subcollection
      match /usage/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Collection subcollection
      match /collection/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Journal subcollection
      match /journal/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Marketplace listings - public read, authenticated write
    match /marketplace/{listing} {
      allow read: if true;
      allow create: if request.auth != null && 
        request.resource.data.sellerId == request.auth.uid;
      allow update, delete: if request.auth != null && 
        resource.data.sellerId == request.auth.uid;
    }
    
    // Public crystal database
    match /crystals/{crystal} {
      allow read: if true;
      allow write: if false; // Admin only
    }
  }
}
EOF

# Create Firestore indexes
cat > ../firestore.indexes.json << EOF
{
  "indexes": [
    {
      "collectionGroup": "marketplace",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "crystalType",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "price",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "journal",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "timestamp",
          "order": "DESCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
EOF

echo ""
echo "🌐 Setting up Web App Configuration"
echo "==================================="
echo ""
echo "Now we'll create a web app configuration for your Flutter web app."
echo ""

# Register web app
firebase apps:create WEB "Crystal Grimoire Web"

echo ""
echo "📝 Generating Configuration Files"
echo "================================"

# Get the web app configuration
echo "Fetching your web app configuration..."
firebase apps:sdkconfig WEB > ../lib/firebase_config.js

echo ""
echo -e "${GREEN}✅ Firebase setup complete!${NC}"
echo ""
echo "📋 Next Steps:"
echo "============="
echo ""
echo "1. Enable Authentication providers in Firebase Console:"
echo "   - Go to: https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
echo "   - Enable: Email/Password, Google, Anonymous"
echo ""
echo "2. Enable Firestore Database:"
echo "   - Go to: https://console.firebase.google.com/project/$PROJECT_ID/firestore"
echo "   - Click 'Create Database'"
echo "   - Choose 'Production mode'"
echo "   - Select location: nam5 (United States)"
echo ""
echo "3. Set up Cloud Functions (for webhooks):"
echo "   - Run: cd functions && npm install"
echo "   - Deploy: firebase deploy --only functions"
echo ""
echo "4. Update your .env file with Firebase configuration"
echo ""
echo "5. Download service account key for backend:"
echo "   - Go to: https://console.firebase.google.com/project/$PROJECT_ID/settings/serviceaccounts/adminsdk"
echo "   - Generate new private key"
echo "   - Save as: backend/firebase-credentials.json"
echo ""
echo -e "${YELLOW}🔗 Firebase Console: https://console.firebase.google.com/project/$PROJECT_ID${NC}"