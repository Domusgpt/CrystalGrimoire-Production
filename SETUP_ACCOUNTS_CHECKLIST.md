# 🔧 REQUIRED ACCOUNTS & API SETUP CHECKLIST

## 🚨 CRITICAL ACCOUNTS NEEDED IMMEDIATELY

### 1. 🔥 FIREBASE SETUP
**Status:** ❌ REQUIRED - No Firebase account configured

**Steps to Complete:**
- [ ] **Create Firebase Project:** Go to [console.firebase.google.com](https://console.firebase.google.com)
- [ ] **Project Name:** "crystal-grimoire-production" 
- [ ] **Enable Authentication:**
  - Email/Password ✅
  - Google Sign-In ✅  
  - Apple Sign-In ✅
  - Anonymous ✅
- [ ] **Setup Firestore Database:**
  - Production mode
  - Multi-region (nam5 - us-central/us-east)
- [ ] **Configure Web App:**
  - App nickname: "Crystal Grimoire Web"
  - Download `firebase-config.js`
  - Update `lib/firebase_options.dart`
- [ ] **Setup Cloud Functions:**
  - Node.js runtime
  - Payment webhook handling
  - Daily usage reset functions

**Required Environment Variables:**
```bash
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=crystal-grimoire-production.firebaseapp.com
FIREBASE_PROJECT_ID=crystal-grimoire-production
FIREBASE_STORAGE_BUCKET=crystal-grimoire-production.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
```

---

### 2. 💳 STRIPE PAYMENT SETUP
**Status:** ❌ REQUIRED - No Stripe account configured

**Steps to Complete:**
- [ ] **Create Stripe Account:** [dashboard.stripe.com](https://dashboard.stripe.com)
- [ ] **Business Details:**
  - Business name: "Crystal Grimoire LLC" (or your entity)
  - Business type: Software/Digital Services
  - Website: https://domusgpt.github.io/CrystalGrimoireBeta2/
- [ ] **Create Products:**
  ```javascript
  Premium Monthly:
  - Name: "Crystal Grimoire Premium"
  - Price: $9.99 USD monthly recurring
  - Features: 30 IDs/day, unlimited collection, marketplace selling
  
  Pro Monthly:  
  - Name: "Crystal Grimoire Pro"
  - Price: $19.99 USD monthly recurring
  - Features: Unlimited IDs, priority marketplace, advanced AI
  ```
- [ ] **Configure Webhooks:**
  - Endpoint: `https://your-backend.com/stripe/webhook`
  - Events: `payment_intent.succeeded`, `customer.subscription.updated`, `invoice.payment_succeeded`
- [ ] **Get API Keys:**
  - Publishable key (starts with `pk_`)
  - Secret key (starts with `sk_`)
  - Webhook signing secret (starts with `whsec_`)

**Required Environment Variables:**
```bash
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...  
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PREMIUM_PRICE_ID=price_...
STRIPE_PRO_PRICE_ID=price_...
```

---

### 3. 🌟 HOROSCOPE API SETUP
**Status:** ❌ REQUIRED - No astrology API configured

**Recommended API Options:**

#### **Option A: RapidAPI Horoscope (Recommended)**
- [ ] **Sign up:** [rapidapi.com](https://rapidapi.com)
- [ ] **Subscribe to:** "Horoscope Astrology" API
- [ ] **Plan:** Basic ($9.99/month) - 10k requests
- [ ] **Get API Key:** X-RapidAPI-Key header

#### **Option B: AstrologyAPI.com (Alternative)**  
- [ ] **Sign up:** [astrologyapi.com](https://astrologyapi.com)
- [ ] **Plan:** Basic ($19/month) - 5k requests
- [ ] **Features:** Daily horoscope, moon phases, planetary positions

#### **Option C: Horoscope.com API (Backup)**
- [ ] **Contact:** [horoscope.com/api](https://horoscope.com/api)
- [ ] **Custom pricing** for commercial use

**Required Environment Variables:**
```bash
HOROSCOPE_API_KEY=your_rapidapi_key
HOROSCOPE_API_URL=https://horoscope-astrology.p.rapidapi.com
HOROSCOPE_API_HOST=horoscope-astrology.p.rapidapi.com
```

---

### 4. 🤖 LLM API SETUP
**Status:** ❌ BROKEN - Current backend LLM not working

**LLM Provider Options:**

#### **Option A: OpenAI (Recommended for Quality)**
- [ ] **Create Account:** [platform.openai.com](https://platform.openai.com)
- [ ] **Add Payment Method:** Credit card for API usage
- [ ] **Generate API Key:** Organization and project keys
- [ ] **Set Usage Limits:** $100/month budget recommended
- [ ] **Models Needed:**
  - Free Tier: `gpt-3.5-turbo` ($0.002/1k tokens)
  - Premium Tier: `gpt-4-turbo` ($0.03/1k tokens)  
  - Pro Tier: `gpt-4-32k` ($0.12/1k tokens)

#### **Option B: Anthropic Claude (Alternative)**
- [ ] **Create Account:** [console.anthropic.com](https://console.anthropic.com)
- [ ] **Get API Key:** For Claude access
- [ ] **Models Available:**
  - Free Tier: `claude-haiku` (cheapest)
  - Premium Tier: `claude-sonnet` (balanced)
  - Pro Tier: `claude-opus` (most capable)

#### **Option C: Google Gemini (Budget Option)**
- [ ] **Create Project:** [console.cloud.google.com](https://console.cloud.google.com)
- [ ] **Enable Gemini API:** In APIs & Services
- [ ] **Create Service Account:** Download JSON key
- [ ] **Models:**
  - Free Tier: `gemini-pro` (free tier available)
  - Premium/Pro: `gemini-pro-vision` (for image analysis)

**Required Environment Variables:**
```bash
# OpenAI
OPENAI_API_KEY=sk-...
OPENAI_ORG_ID=org-...

# Or Anthropic  
ANTHROPIC_API_KEY=sk-ant-...

# Or Google
GOOGLE_AI_API_KEY=AIza...
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
```

---

### 5. 📧 EMAIL SERVICE SETUP
**Status:** ⚠️ OPTIONAL - For user notifications

**Recommended: SendGrid (Firebase Functions compatible)**
- [ ] **Create Account:** [sendgrid.com](https://sendgrid.com)
- [ ] **Verify Domain:** For professional email sending
- [ ] **Create API Key:** With send permissions
- [ ] **Design Templates:** Welcome, payment confirmation, daily insights

**Environment Variables:**
```bash
SENDGRID_API_KEY=SG....
FROM_EMAIL=noreply@crystalgrimoire.com
```

---

### 6. 📊 ANALYTICS SETUP  
**Status:** ⚠️ OPTIONAL - For user tracking

**Google Analytics 4 (Free)**
- [ ] **Create GA4 Property:** [analytics.google.com](https://analytics.google.com)
- [ ] **Get Measurement ID:** G-XXXXXXXXXX
- [ ] **Configure Events:** Sign-ups, subscriptions, crystal IDs
- [ ] **Link to Firebase:** For unified user tracking

**Environment Variables:**
```bash
GA_MEASUREMENT_ID=G-XXXXXXXXXX
```

---

## 🔧 BACKEND DEPLOYMENT REQUIREMENTS

### **Current Backend Status:** ❌ BROKEN
**Location:** `/backend/enhanced_backend.py`
**Issues:** LLM integration not working, missing API keys

### **Required Backend Updates:**
- [ ] **Fix LLM Integration:** Update with working API keys
- [ ] **Add Horoscope Service:** Integrate astrology API
- [ ] **Stripe Webhooks:** Handle payment events
- [ ] **Firebase Admin:** Server-side Firebase integration
- [ ] **Rate Limiting:** Implement tier-based usage limits
- [ ] **Error Handling:** Robust fallbacks for API failures

### **Deployment Platform Options:**

#### **Option A: Render.com (Current)**
- [ ] **Update Environment Variables:** Add all new API keys
- [ ] **Update `requirements.txt`:** Add new dependencies
- [ ] **Configure Health Checks:** Ensure proper monitoring

#### **Option B: Google Cloud Run (Recommended)**
- [ ] **Create GCP Project:** Link with Firebase
- [ ] **Build Container:** Docker deployment
- [ ] **Set Environment Variables:** All API keys
- [ ] **Configure Scaling:** Auto-scale based on usage

#### **Option C: Vercel Functions (Serverless)**
- [ ] **Create Vercel Account:** Link GitHub repo
- [ ] **Configure Functions:** Split into microservices
- [ ] **Set Environment Variables:** Per function config

---

## 💰 COST ESTIMATES

### **Monthly API Costs (1000 active users):**
```bash
Firebase (Spark Plan): $0 (free tier)
Stripe Processing: 2.9% + $0.30 per transaction
Horoscope API: $9.99/month (RapidAPI Basic)
OpenAI LLM: ~$50-100/month (based on usage)
SendGrid Email: $0 (free tier up to 100 emails/day)
Google Analytics: $0 (free)

Total Estimated: $60-110/month + payment processing fees
```

### **Revenue Break-Even Analysis:**
```bash
Monthly Costs: ~$100
Premium Subscriptions Needed: 11 users ($9.99 each)
Pro Subscriptions Needed: 5 users ($19.99 each)
Marketplace Commission (5%): Additional revenue stream
```

---

## 🚀 SETUP PRIORITY ORDER

### **Phase 1: Foundation (This Week)**
1. ✅ **Firebase Setup** - Authentication and Firestore
2. ✅ **Stripe Setup** - Payment processing
3. ✅ **LLM API** - Choose and configure provider
4. ✅ **Basic Backend Fix** - Get LLM working

### **Phase 2: Enhancement (Next Week)**  
1. ✅ **Horoscope API** - Astrology integration
2. ✅ **Advanced LLM Prompts** - All system prompts
3. ✅ **Tier-based Access** - Premium feature gating
4. ✅ **Frontend Integration** - Connect all services

### **Phase 3: Production (Week 3)**
1. ✅ **Email Service** - User notifications
2. ✅ **Analytics** - Usage tracking
3. ✅ **Monitoring** - Error tracking and alerts
4. ✅ **Performance** - Optimization and scaling

---

## 📝 ACCOUNT CREDENTIALS STORAGE

**SECURITY NOTE:** Store all API keys securely in:
- [ ] **Development:** `.env` files (git-ignored)
- [ ] **Production:** Environment variables on deployment platform
- [ ] **Backup:** Secure password manager (1Password, Bitwarden)

**Never commit API keys to Git repository!**

---

**🔮 Complete this setup checklist to unlock Crystal Grimoire's full mystical potential with working backend services and premium AI features! ✨**