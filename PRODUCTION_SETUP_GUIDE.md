# 🔮 Crystal Grimoire Beta0.2 - Complete Production Setup Guide

## ✅ COMPLETED: Gemini AI Integration
- **Status**: ACTIVE with real API key
- **API Key**: AIzaSyC__1EHCjv9pCRJzQoRQiKVxTfaPMXFXAs  
- **Usage**: Free tier users get Gemini Pro responses
- **Limits**: 15 requests/minute, 1M tokens/minute (generous for free)

---

## 🔥 REQUIRED PRODUCTION SERVICES SETUP

### 1. 🔐 Firebase Authentication & Database
**WHY**: User accounts, data persistence, real-time sync

#### Setup Steps:
1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Create New Project**: 
   - Project name: `crystal-grimoire-production`
   - Enable Google Analytics: YES
3. **Enable Authentication**:
   - Go to Authentication > Sign-in method
   - Enable: Email/Password, Google, Apple (optional)
4. **Create Firestore Database**:
   - Go to Firestore Database > Create database
   - Start in production mode
   - Choose region: us-central1
5. **Get Configuration**:
   - Go to Project Settings > General
   - Add web app: "Crystal Grimoire"
   - Copy the config object

#### Configuration Object Needed:
```javascript
const firebaseConfig = {
  apiKey: "your-api-key",
  authDomain: "crystal-grimoire-production.firebaseapp.com",
  projectId: "crystal-grimoire-production", 
  storageBucket: "crystal-grimoire-production.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcd1234"
};
```

#### Security Rules for Firestore:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Crystal collections are user-private
    match /users/{userId}/crystals/{crystalId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Journal entries are user-private
    match /users/{userId}/journal/{entryId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Marketplace listings are public read, owner write
    match /marketplace/{listingId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == resource.data.sellerId;
    }
  }
}
```

---

### 2. 💳 Stripe Payment Processing
**WHY**: Premium subscriptions, marketplace transactions

#### Setup Steps:
1. **Create Stripe Account**: https://dashboard.stripe.com/register
2. **Get API Keys**:
   - Go to Developers > API keys
   - Copy Publishable key (pk_test_... or pk_live_...)
   - Copy Secret key (sk_test_... or sk_live_...)
3. **Create Products**:
   - Go to Products > Add product
   - Create: Premium ($9.99/month), Pro ($19.99/month), Founders ($199 one-time)
4. **Set up Webhooks**:
   - Go to Developers > Webhooks
   - Add endpoint: `https://your-domain.com/stripe-webhook`
   - Select events: `customer.subscription.created`, `customer.subscription.updated`, `invoice.payment_succeeded`

#### Required Stripe Products:
```json
{
  "premium_monthly": {
    "name": "Crystal Grimoire Premium",
    "price": 999,
    "interval": "month",
    "features": ["30 IDs/day", "Unlimited crystals", "Marketplace selling"]
  },
  "pro_monthly": {
    "name": "Crystal Grimoire Pro", 
    "price": 1999,
    "interval": "month",
    "features": ["Unlimited IDs", "Advanced AI", "Priority support"]
  },
  "founders_lifetime": {
    "name": "Crystal Grimoire Founders",
    "price": 19900,
    "interval": null,
    "features": ["Lifetime access", "All features", "Exclusive content"]
  }
}
```

---

### 3. 🌟 Horoscope API Integration
**WHY**: Daily astrology, birth chart calculations

#### Recommended API: AstrologyAPI
1. **Sign up**: https://rapidapi.com/astro-seek/api/horoscope-astrology
2. **Subscribe to Free Plan**: 100 requests/month free
3. **Get API Key**: Copy X-RapidAPI-Key from dashboard

#### Alternative: Aztro API
1. **URL**: https://aztro.sameerkumar.website/
2. **Free**: No key required, unlimited requests
3. **Limitation**: Daily horoscopes only, no birth charts

---

### 4. 📱 Progressive Web App (PWA) Setup
**WHY**: Mobile app experience, offline functionality

#### Files to Update:
1. **manifest.json**: App metadata
2. **sw.js**: Service worker for offline caching
3. **index.html**: PWA meta tags

#### PWA Configuration:
```json
{
  "name": "Crystal Grimoire",
  "short_name": "CrystalGrimoire", 
  "description": "Unified Metaphysical Experience Platform",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#1a1a2e",
  "theme_color": "#20b2aa",
  "icons": [
    {
      "src": "icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/icon-512.png", 
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

---

### 5. 🚀 Deployment & Hosting
**WHY**: Production hosting, SSL, CDN

#### Option A: Firebase Hosting (Recommended)
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
firebase deploy
```

#### Option B: Vercel
```bash
npm install -g vercel
vercel --prod
```

#### Option C: GitHub Pages (Current)
- Already configured in repository
- Auto-deploys on push to main branch

---

## 🔧 CONFIGURATION UPDATES NEEDED

### Update environment_config.dart with YOUR keys:

```dart
class EnvironmentConfig {
  // FIREBASE - Replace with your config
  static const String _firebaseApiKey = 'your-firebase-api-key';
  static const String _firebaseProjectId = 'crystal-grimoire-production';
  static const String _firebaseAuthDomain = 'crystal-grimoire-production.firebaseapp.com';
  
  // STRIPE - Replace with your keys
  static const String _stripePublishableKey = 'pk_test_your_publishable_key';
  static const String _stripeSecretKey = 'sk_test_your_secret_key';
  
  // HOROSCOPE API - Replace with your key
  static const String _horoscopeApiKey = 'your-rapidapi-key';
  
  // GEMINI AI - Already configured ✅
  static const String _geminiApiKey = 'AIzaSyC__1EHCjv9pCRJzQoRQiKVxTfaPMXFXAs';
}
```

---

## 🧪 TESTING CHECKLIST

### After each service setup:

#### ✅ Firebase
- [ ] User can register/login
- [ ] Crystal data persists between sessions
- [ ] Journal entries save to Firestore
- [ ] Real-time updates work

#### ✅ Stripe  
- [ ] Payment form loads correctly
- [ ] Test payments process (use 4242424242424242)
- [ ] Subscription status updates correctly
- [ ] Webhook events are received

#### ✅ Horoscope API
- [ ] Daily horoscope loads
- [ ] Birth chart calculation works
- [ ] Astrological data displays correctly

#### ✅ Gemini AI (Already Working)
- [ ] Metaphysical guidance generates responses
- [ ] Crystal healing suggestions use owned crystals
- [ ] Moon ritual recommendations are personalized

---

## 📋 PRIORITY ORDER

1. **FIREBASE FIRST** - User accounts and data persistence
2. **STRIPE SECOND** - Revenue generation through subscriptions  
3. **HOROSCOPE THIRD** - Enhanced astrological features
4. **PWA FOURTH** - Mobile optimization
5. **DEPLOYMENT LAST** - Production hosting

---

## 🆘 SUPPORT RESOURCES

- **Firebase**: https://firebase.google.com/docs
- **Stripe**: https://stripe.com/docs
- **Flutter Web**: https://docs.flutter.dev/platform-integration/web
- **PWA**: https://web.dev/progressive-web-apps/

---

**Next Step: Give me your Firebase config object and I'll integrate it immediately. No placeholders, no shortcuts - real production setup only.**