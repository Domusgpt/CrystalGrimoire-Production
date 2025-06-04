# 🔮 Crystal Grimoire Beta0.2 - Unified Metaphysical Experience Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com)
[![Stripe](https://img.shields.io/badge/Stripe-Integrated-green.svg)](https://stripe.com)
[![License](https://img.shields.io/badge/License-Private-red.svg)](LICENSE)

## ✨ Overview

Crystal Grimoire Beta0.2 is a **unified metaphysical experience platform** that seamlessly integrates:
- 💎 Crystal identification and collection management
- 🌙 Personalized astrology and horoscopes
- 🧘 Guided healing and meditation
- 📓 Spiritual journaling with mood tracking
- 🌟 Moon rituals and sacred practices
- 🤖 AI-powered personalized guidance
- 🛍️ Crystal marketplace with community features

Every feature interconnects through shared user data to create deeply personalized spiritual experiences.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/domusgpt/CrystalGrimoireBeta0.2.git
cd CrystalGrimoireBeta0.2

# Run the setup script
cd scripts && ./quick-start.sh

# Configure your API keys
nano .env

# Start the backend
cd backend && source venv/bin/activate && python unified_backend.py

# Start the frontend (new terminal)
flutter run -d web-server --web-port 3000
```

## 🏗️ Architecture

### Unified Data Models
- **UserProfile**: Central profile with birth chart and preferences
- **CrystalCollection**: Owned crystals with metadata and usage tracking
- **JournalEntry**: Mood tracking with astrological context
- **MoonRitualRecord**: Ritual practices linked to lunar cycles
- **HealingSessionLog**: Wellness tracking with crystal usage

### Feature Interconnections
```
🧑 User Profile ←→ 💎 Crystal Collection
    ↓                    ↓
🌙 Birth Chart      🧘 Healing Sessions
    ↓                    ↓
📅 Daily Horoscope  📓 Journal Entries
    ↓                    ↓
🤖 Personalized AI Guidance ← All Features Feed Into This
```

## 💳 Subscription Tiers

| Feature | Free | Premium ($9.99/mo) | Pro ($19.99/mo) | Founders ($199) |
|---------|------|-------------------|-----------------|-----------------|
| Daily Crystal IDs | 5 | 30 | Unlimited | Unlimited |
| Collection Size | 5 crystals | Unlimited | Unlimited | Unlimited |
| AI Model | Gemini | GPT-4 | Claude Opus | All Models |
| Marketplace | Browse only | Buy & Sell | Priority | Exclusive |
| Horoscopes | Daily | All types | Personalized | Deep Insights |
| Support | Community | Email | Priority | Direct |

## 🔧 Setup Requirements

### 1. Firebase Setup
```bash
# Run the Firebase setup script
./scripts/setup-firebase.sh

# Enable in Firebase Console:
- Authentication (Email, Google, Anonymous)
- Firestore Database
- Cloud Functions
```

### 2. Stripe Configuration
- Create account at [dashboard.stripe.com](https://dashboard.stripe.com)
- Add subscription products
- Configure webhooks
- See `docs/STRIPE_SETUP_GUIDE.md`

### 3. LLM API Setup
Choose one or more providers:
- **OpenAI**: Best quality/cost ratio
- **Anthropic**: Premium experience
- **Google Gemini**: Budget option
- See `docs/LLM_API_SETUP_GUIDE.md`

### 4. Environment Variables
Copy `.env.template` to `.env` and add your keys:
```env
FIREBASE_API_KEY=your_key
STRIPE_SECRET_KEY=sk_test_...
OPENAI_API_KEY=sk-...
# ... etc
```

## 📱 Key Features

### 🔮 Crystal Identification
- AI-powered identification from photos
- Detailed metaphysical properties
- Chakra associations
- Personalized recommendations based on your zodiac

### 🌙 Astrology Integration
- Complete birth chart calculation
- Daily personalized horoscopes
- Crystal-zodiac compatibility
- Lunar cycle tracking

### 🧘 Healing & Meditation
- Guided crystal meditations
- Chakra balancing sessions
- Sound bath experiences
- Progress tracking

### 📓 Spiritual Journal
- Mood tracking with analysis
- Crystal usage logging
- Ritual documentation
- AI-powered insights

### 🛍️ Crystal Marketplace
- Buy/sell crystals
- Seller verification
- Secure payments via Stripe
- Community ratings

## 🛠️ Development

### Tech Stack
- **Frontend**: Flutter 3.10+ (Web)
- **Backend**: FastAPI (Python)
- **Database**: Firebase Firestore
- **Auth**: Firebase Authentication
- **Payments**: Stripe
- **AI**: OpenAI, Anthropic, Google
- **Hosting**: GitHub Pages + Cloud Run

### Project Structure
```
CrystalGrimoireBeta0.2/
├── lib/                    # Flutter app code
│   ├── models/            # Shared data models
│   ├── services/          # API and business logic
│   ├── screens/           # UI screens
│   └── widgets/           # Reusable components
├── backend/               # Python FastAPI backend
│   ├── unified_backend.py # Main API server
│   └── requirements.txt   # Python dependencies
├── scripts/               # Setup and deployment
├── docs/                  # Documentation
└── web/                   # Web deployment files
```

### Running Tests
```bash
# Flutter tests
flutter test

# Backend tests
cd backend && pytest

# Integration tests
flutter drive --target=test_driver/app.dart
```

## 🚀 Deployment

### Frontend (GitHub Pages)
```bash
flutter build web --release --base-href="/CrystalGrimoireBeta0.2/"
git add . && git commit -m "Deploy" && git push
```

### Backend (Cloud Run)
```bash
cd backend
gcloud run deploy crystal-grimoire-api \
  --source . \
  --region us-central1 \
  --allow-unauthenticated
```

## 📊 Monitoring & Analytics

- **Firebase Analytics**: User behavior tracking
- **Stripe Dashboard**: Revenue and subscription metrics
- **Cloud Logging**: Backend error monitoring
- **Performance Monitoring**: Load times and API latency

## 🤝 Contributing

This is a private repository. If you have access:

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request
5. Wait for review

## 📞 Support

- **Documentation**: See `/docs` folder
- **Issues**: GitHub Issues
- **Email**: support@crystalgrimoire.com
- **Discord**: [Join our community](#)

## 📜 License

Private and Proprietary. All rights reserved.

---

**🔮 Remember: This is a unified spiritual experience platform, not just an app. Every feature should enhance the user's metaphysical journey. ✨**