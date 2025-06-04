# Crystal Grimoire Beta0.2 - Unified Metaphysical Experience Platform

## 🔮 Project Vision & Architecture

Crystal Grimoire Beta0.2 is a **unified metaphysical experience platform** that seamlessly integrates crystals, astrology, healing modalities, and journaling into one cohesive spiritual toolkit. Every feature interconnects through shared user data to create deeply personalized experiences.

### 🎯 Core Philosophy
- **Unified Experience**: All features speak the same language through shared data models
- **Deep Personalization**: LLM prompts enriched with user's birth chart, crystal collection, and mood history
- **Synergistic Interactions**: Features reinforce each other (Moon Ritual → Journal Entry → Healing Suggestion)
- **Production Quality**: NO shortcuts, demos, or simplified versions - only complete, robust implementations

## 📍 Current Status & Critical Priorities

**Phase:** Complete system refactoring with unified architecture
**Live URL:** https://domusgpt.github.io/CrystalGrimoireBeta2/
**Framework:** Flutter 3.10+ with Firebase backend integration

### 🚨 IMMEDIATE CRITICAL TASKS

#### 1. Visual Redesign Implementation (Week 1)
- **Teal/Red Gem Logo**: Replace "Crystal Grimoire" text with custom gem logo (exact asset from user screenshots)
- **Marketplace Horizontal Placement**: Add marketplace button BETWEEN grid squares with heavy shimmer effects
- **Crystal of the Day Enhancement**: Bigger, more dynamic with sparkle effects
- **Daily Usage Counter**: Move INTO Crystal ID widget, remove separate usage card

#### 2. Backend Infrastructure (Week 1-2)
- **Fix Broken LLM Integration**: OpenAI/Claude/Gemini API implementation
- **Firebase Setup**: Authentication, Firestore, Cloud Functions
- **Stripe Integration**: Payment processing for premium tiers
- **Horoscope API**: Daily astrology data integration

#### 3. Unified System Implementation (Week 2-3)
- **Shared Data Models**: UserProfile, CrystalCollection, JournalEntry, MoonRitualRecord
- **Cross-Feature Integration**: Features that reference each other's data
- **Personalized LLM Prompts**: Context-aware AI responses

## 🏗 Unified System Architecture

### Core Data Models (Single Source of Truth)

```dart
// Central user profile with astrological and personal data
class UserProfile {
  String id;
  String name;
  DateTime birthDate;
  TimeOfDay birthTime;
  String birthLocation;
  double latitude;
  double longitude;
  BirthChart birthChart;
  SubscriptionTier tier;
  Map<String, dynamic> spiritualPreferences;
  Map<String, int> monthlyUsage;
  
  // Personalization context for LLM prompts
  Map<String, dynamic> getSpiritualContext();
}

// Crystal collection with metadata and usage tracking
class CollectionEntry {
  String id;
  String crystalName;
  String crystalType;
  DateTime dateAcquired;
  String personalNotes;
  String intentions;
  List<String> metaphysicalProperties;
  List<String> chakraAssociations;
  int usageCount;
  DateTime lastUsed;
  String acquisitionSource; // marketplace, personal, etc.
}

// Journal entries with mood tracking and context
class JournalEntry {
  String id;
  DateTime timestamp;
  String content;
  List<String> moodTags;
  String emotionalState;
  List<String> associatedCrystals;
  String moonPhase;
  String astrologicalContext;
  String ritualContext;
}

// Moon ritual tracking for astrological integration
class MoonRitualRecord {
  String id;
  DateTime date;
  String moonPhase;
  String astrologicalContext;
  List<String> crystalsUsed;
  String ritualType;
  String intentions;
  String outcomeNotes;
  double completionRating;
}

// Healing session logs for wellness tracking
class HealingSessionLog {
  String id;
  DateTime date;
  String healingMethod;
  List<String> crystalsUsed;
  Duration sessionDuration;
  String chakraFocus;
  String emotionalState;
  String feedback;
  double effectivenessRating;
}
```

### Subscription Tier System

```dart
enum SubscriptionTier {
  free,      // 5 IDs/day, 5 crystals max, basic features
  premium,   // 30 IDs/day, unlimited crystals, marketplace selling ($9.99/month)
  pro,       // Unlimited IDs, marketplace priority, advanced AI ($19.99/month)
  founders   // Lifetime access, exclusive features (limited edition)
}
```

## 🔄 Feature Interconnections & Data Flow

### 1. **Journal ↔ Astrology & Crystals**
```dart
// When creating journal entry, include contextual data
JournalEntry entry = JournalEntry(
  content: userInput,
  moonPhase: MoonPhaseCalculator.getCurrentPhase(),
  astrologicalContext: userProfile.birthChart.getCurrentTransits(),
  associatedCrystals: getRecentlyUsedCrystals(),
);

// Mood analysis influences next-day suggestions
if (entry.emotionalState == "anxious") {
  scheduleHealingSuggestion(
    crystals: collection.getCrystalsByPurpose("calming"),
    timing: "tomorrow_morning"
  );
}
```

### 2. **Healing ↔ Collection & Guidance**
```dart
// Healing prompts filter to owned crystals
List<CollectionEntry> availableCrystals = collectionService
  .getCrystalsByChakra(selectedChakra)
  .where((crystal) => crystal.isOwned)
  .toList();

// LLM prompt includes personal context
String healingPrompt = """
User Profile: ${userProfile.getSpiritualContext()}
Available Crystals: ${availableCrystals.map((c) => c.crystalName).join(', ')}
Recent Mood: ${getRecentJournalMood()}
Current Transit: ${birthChart.getCurrentTransits()}

Generate a personalized healing session using their owned crystals.
""";
```

### 3. **Moon Ritual ↔ All Modules**
```dart
// Moon ritual suggestions based on user data
MoonRitualSuggestion generateRitualSuggestion() {
  String currentPhase = MoonPhaseCalculator.getCurrentPhase();
  List<String> phaseAppropriateCrystals = getMoonPhaseCrystals(currentPhase);
  List<String> ownedPhaseCrystals = collection.filterOwned(phaseAppropriateCrystals);
  
  return MoonRitualSuggestion(
    phase: currentPhase,
    recommendedCrystals: ownedPhaseCrystals,
    personalizedIntention: generateIntention(userProfile.spiritualPreferences),
    followUpJournalPrompt: generateJournalPrompt(currentPhase, userProfile.birthChart),
  );
}
```

### 4. **Marketplace ↔ Collection & Community**
```dart
// Marketplace listings show compatibility with user's collection
class MarketplaceListing {
  String crystalType;
  double price;
  String sellerTier;
  
  // Show compatibility with user's spiritual profile
  double getCompatibilityScore(UserProfile profile) {
    return calculateAstrologicalCompatibility(crystalType, profile.birthChart);
  }
  
  // Suggest collection synergies
  List<String> getSynergyWith(CrystalCollection collection) {
    return collection.findSynergisticCrystals(crystalType);
  }
}
```

## 🤖 Personalized LLM Integration

### Context-Rich Prompt Engineering

```dart
class LLMPromptBuilder {
  static String buildGuidancePrompt(UserProfile profile, String query) {
    String context = """
USER CONTEXT:
- Name: ${profile.name}
- Astrological Profile: ${profile.birthChart.getSummary()}
- Owned Crystals: ${profile.collection.getActiveStones()}
- Recent Mood: ${profile.getRecentJournalMood()}
- Current Moon Phase: ${MoonPhaseCalculator.getCurrentPhase()}
- Subscription Tier: ${profile.tier}
- Spiritual Preferences: ${profile.spiritualPreferences}

RECENT ACTIVITY:
- Last Journal Entry: ${profile.getLastJournalSummary()}
- Recent Rituals: ${profile.getRecentRituals()}
- Crystal Usage Patterns: ${profile.getCrystalUsagePatterns()}

USER QUERY: ${query}

GUIDANCE REQUIREMENTS:
- Reference their specific crystals and astrological profile
- Suggest activities they can actually do with owned items
- Connect to their recent emotional state and spiritual journey
- Provide actionable next steps within their subscription tier
""";
    return context;
  }
}
```

### Tier-Based AI Features

```dart
class AIResponseGenerator {
  static Future<String> generateResponse(String prompt, SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return openAIService.generate(prompt, model: "gpt-3.5-turbo");
      case SubscriptionTier.premium:
        return openAIService.generate(prompt, model: "gpt-4-turbo");
      case SubscriptionTier.pro:
        return claudeService.generate(prompt, model: "claude-opus");
      case SubscriptionTier.founders:
        return multiModelConsensus([openAI, claude, gemini], prompt);
    }
  }
}
```

## 🎨 Visual Design Implementation

### Teal/Red Gem Logo Specifications

```dart
class TealRedGemLogo extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: rotationController.value * 2 * pi,
          child: CustomPaint(
            size: Size(120, 120),
            painter: GemLogoPainter(),
          ),
        );
      },
    );
  }
}

class GemLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Main gem body - teal/red split design
    final leftHalfPaint = Paint()
      ..color = Color(0xFF20B2AA) // Teal
      ..style = PaintingStyle.fill;
    
    final rightHalfPaint = Paint()
      ..color = Color(0xFFFF4500) // Red-orange
      ..style = PaintingStyle.fill;
    
    // Draw exact gem design from user screenshot
    // Implementation matches user's specific teal/red split style
  }
}
```

### Marketplace Horizontal Placement

```dart
// Add marketplace button between grid squares with shimmer effects
Widget buildMarketplaceStrip() {
  return Container(
    height: 80,
    width: double.infinity,
    margin: EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFFFFD700), // Gold
          Color(0xFFE0115F), // Ruby
          Color(0xFF50C878), // Emerald
          Color(0xFF0F52BA), // Sapphire
        ],
      ),
      borderRadius: BorderRadius.circular(40),
      boxShadow: [
        BoxShadow(
          color: Colors.purple.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ],
    ),
    child: ShimmerButton(
      text: "✨ Crystal Marketplace ✨",
      onTap: () => Navigator.push(context, 
        MaterialPageRoute(builder: (_) => MarketplaceScreen())),
    ),
  );
}
```

## 🔧 Backend Infrastructure Requirements

### Required API Integrations

#### 1. Firebase Configuration
```yaml
# Environment Variables Required
FIREBASE_API_KEY: your_api_key
FIREBASE_AUTH_DOMAIN: crystal-grimoire-production.firebaseapp.com
FIREBASE_PROJECT_ID: crystal-grimoire-production
FIREBASE_STORAGE_BUCKET: crystal-grimoire-production.appspot.com
```

#### 2. Payment Processing (Stripe)
```yaml
STRIPE_PUBLISHABLE_KEY: pk_live_...
STRIPE_SECRET_KEY: sk_live_...
STRIPE_WEBHOOK_SECRET: whsec_...
STRIPE_PREMIUM_PRICE_ID: price_premium_monthly
STRIPE_PRO_PRICE_ID: price_pro_monthly
```

#### 3. Horoscope API Integration
```yaml
HOROSCOPE_API_KEY: your_rapidapi_key
HOROSCOPE_API_URL: https://horoscope-astrology.p.rapidapi.com
```

#### 4. LLM Services
```yaml
# Primary: OpenAI
OPENAI_API_KEY: sk-...
# Backup: Anthropic Claude
ANTHROPIC_API_KEY: sk-ant-...
# Budget: Google Gemini
GOOGLE_AI_API_KEY: AIza...
```

### Backend Service Architecture

```python
# Enhanced backend with unified data flow
class UnifiedBackendService:
    def __init__(self):
        self.llm_service = LLMService()
        self.astrology_service = AstrologyService()
        self.firebase_service = FirebaseService()
        self.stripe_service = StripeService()
        
    async def get_personalized_guidance(self, user_id: str, query: str):
        # Fetch complete user context
        user_profile = await self.firebase_service.get_user_profile(user_id)
        crystal_collection = await self.firebase_service.get_user_collection(user_id)
        recent_journals = await self.firebase_service.get_recent_journals(user_id, limit=5)
        
        # Build enriched prompt
        context = self.build_user_context(user_profile, crystal_collection, recent_journals)
        enriched_prompt = f"{context}\n\nUser Query: {query}"
        
        # Generate tier-appropriate response
        response = await self.llm_service.generate_response(
            prompt=enriched_prompt,
            tier=user_profile.subscription_tier
        )
        
        return response
```

## 📱 Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
- [ ] **Firebase Setup**: Authentication, Firestore, Cloud Functions
- [ ] **Stripe Integration**: Payment processing and webhooks
- [ ] **LLM API Fix**: Working AI backend with tier-based access
- [ ] **Visual Redesign**: Teal/red gem logo, marketplace placement

### Phase 2: Unified System (Weeks 3-4)
- [ ] **Data Model Implementation**: Shared models across all features
- [ ] **Cross-Feature Integration**: Features that reference each other
- [ ] **Personalized LLM Prompts**: Context-aware AI responses
- [ ] **Horoscope API Integration**: Daily astrology data

### Phase 3: Advanced Features (Weeks 5-6)
- [ ] **Marketplace Functionality**: Buy/sell with payment processing
- [ ] **Advanced Analytics**: User behavior and preference learning
- [ ] **Social Features**: Community and sharing capabilities
- [ ] **Premium Content**: Tier-exclusive features and content

### Phase 4: Optimization (Weeks 7-8)
- [ ] **Performance Optimization**: Load times and responsiveness
- [ ] **Mobile Responsive**: Perfect mobile experience
- [ ] **Testing & QA**: Comprehensive feature testing
- [ ] **Launch Preparation**: Production deployment

## 🛡 Security & Privacy

### Data Protection
```dart
class PrivacyManager {
  // Encrypt sensitive user data
  static String encryptBirthData(BirthChart chart) {
    return AESEncryption.encrypt(chart.toJson(), userSpecificKey);
  }
  
  // Anonymize data for analytics
  static Map<String, dynamic> anonymizeUserData(UserProfile profile) {
    return {
      'zodiac_sign': profile.birthChart.sunSign,
      'crystal_count': profile.collection.length,
      'subscription_tier': profile.tier.toString(),
      // No personal identifiers
    };
  }
}
```

### Subscription Security
```dart
class SubscriptionValidator {
  static bool validateAccess(UserProfile user, String feature) {
    switch (feature) {
      case 'unlimited_crystals':
        return user.tier != SubscriptionTier.free;
      case 'marketplace_selling':
        return [SubscriptionTier.premium, SubscriptionTier.pro, SubscriptionTier.founders]
          .contains(user.tier);
      case 'advanced_ai':
        return [SubscriptionTier.pro, SubscriptionTier.founders]
          .contains(user.tier);
      default:
        return true; // Basic features available to all
    }
  }
}
```

## 📊 Success Metrics & Analytics

### Key Performance Indicators
- **User Engagement**: Average session duration (target: 8+ minutes)
- **Feature Adoption**: Cross-feature usage rate (target: 60%+)
- **Conversion Rate**: Free to premium upgrade (target: 15%+)
- **Retention**: 30-day active user retention (target: 40%+)
- **Revenue**: Monthly recurring revenue growth (target: 20%+ MoM)

### Analytics Implementation
```dart
class AnalyticsTracker {
  static void trackFeatureInterconnection(String fromFeature, String toFeature) {
    FirebaseAnalytics.instance.logEvent(
      name: 'feature_flow',
      parameters: {
        'from_feature': fromFeature,
        'to_feature': toFeature,
        'user_tier': currentUser.tier.toString(),
        'session_time': getCurrentSessionDuration(),
      },
    );
  }
}
```

## 🚀 Deployment & DevOps

### GitHub Actions Workflow
```yaml
name: Deploy Crystal Grimoire Beta0.2
on:
  push:
    branches: [ main ]
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.x'
      - run: flutter build web --release --base-href="/CrystalGrimoireBeta2/"
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

### Environment Configuration
```dart
class EnvironmentConfig {
  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
  static const String firebaseProject = String.fromEnvironment('FIREBASE_PROJECT');
  static const String stripeKey = String.fromEnvironment('STRIPE_KEY');
  
  static Map<String, String> get config {
    return {
      'firebase_project': firebaseProject,
      'stripe_publishable_key': stripeKey,
      'api_base_url': isProduction 
        ? 'https://api.crystalgrimoire.com' 
        : 'http://localhost:8080',
    };
  }
}
```

## 📚 Development Guidelines

### Code Standards
- **No Shortcuts**: Production-quality code only, no demos or simplified versions
- **Unified Architecture**: All features must integrate through shared data models
- **User-Centric**: Every decision should enhance the user's spiritual journey
- **Performance First**: Optimize for mobile and web performance
- **Privacy Respected**: Encrypt sensitive data, anonymize analytics

### Testing Strategy
```dart
// Integration tests for cross-feature functionality
testWidgets('Journal entry influences healing suggestions', (tester) async {
  // Create journal entry with anxiety mood
  await createJournalEntry(mood: 'anxious');
  
  // Navigate to healing section
  await tester.tap(find.byKey(Key('healing_tab')));
  await tester.pumpAndSettle();
  
  // Verify calming crystals are suggested
  expect(find.text('amethyst'), findsOneWidget);
  expect(find.text('rose quartz'), findsOneWidget);
});
```

## 🔮 Future Vision

Crystal Grimoire Beta0.2 will be the **premier unified metaphysical platform** where:
- Every user receives deeply personalized guidance based on their complete spiritual profile
- Features seamlessly flow into each other, creating natural user journeys
- AI responses feel like talking to a knowledgeable spiritual mentor who knows your history
- The marketplace becomes a thriving community of crystal enthusiasts
- Premium features provide genuine value that users are excited to pay for

**This is not just an app - it's a comprehensive spiritual companion that grows and evolves with each user's journey.**

---

## 📁 Critical File Locations

### New Beta0.2 Structure
```
/lib/
├── models/              # Shared data models
│   ├── user_profile.dart
│   ├── collection_entry.dart
│   ├── journal_entry.dart
│   └── ritual_record.dart
├── services/            # Unified service layer
│   ├── firebase_service.dart
│   ├── llm_service.dart
│   ├── astrology_service.dart
│   └── marketplace_service.dart
├── screens/             # Feature screens
│   ├── unified_home_screen.dart
│   ├── personalized_guidance_screen.dart
│   ├── intelligent_collection_screen.dart
│   └── marketplace_screen.dart
├── widgets/             # Reusable components
│   ├── teal_red_gem_logo.dart
│   ├── marketplace_button.dart
│   └── personalized_widgets.dart
└── utils/               # Helper functions
    ├── prompt_builder.dart
    ├── astrology_calculator.dart
    └── personalization_engine.dart
```

### Reference Documents
- `/SETUP_ACCOUNTS_CHECKLIST.md` - Backend API setup requirements
- `/Changes for APP/suggestions for some chnsges.md` - Detailed Flutter implementation
- `/Changes for APP/Unified CrystalGrimoire System Design.md` - System architecture
- Screenshots in `/Changes for APP/` - Visual design references

---

**✨ Remember: This is a unified spiritual experience platform, not a collection of separate features. Every line of code should serve the user's holistic metaphysical journey. ✨**