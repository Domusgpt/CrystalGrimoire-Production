# Crystal Grimoire - Unified Integration Context for ClaudeCode

## 🚨 CRITICAL SESSION CONTINUITY INSTRUCTIONS

### Current Project Status
- **Active Directory**: `/mnt/c/Users/millz/Desktop/CrystalGrimoireBeta0.2/`
- **Project State**: Transitioning from demo implementation to fully functional integrated system
- **Original Working Code**: Located at `/mnt/c/Users/millz/Desktop/CrystalGrimoire-WORKING-BACKUP/`
- **User Requirements**: Restore FULL functionality from Alpha, integrate all systems, NO demos or shortcuts

### NEVER DO THESE THINGS (Critical Anti-Patterns)
1. **NO MOCK/DEMO IMPLEMENTATIONS**: User explicitly criticized creating "non working demo" - all features must be fully functional
2. **NO SIMPLIFIED VERSIONS**: Do not create simplified, demo, or workaround versions unless explicitly requested
3. **NO ISOLATED FEATURES**: Every feature must integrate with the shared data models and cross-reference other systems
4. **NO SHORTCUTS**: Build production-ready code with complete error handling and real API integrations
5. **NO GENERIC RESPONSES**: All LLM prompts must include user's personal context (stones, birth chart, mood history)

## 🎯 Core Integration Philosophy

### Unified System Vision
Crystal Grimoire is a **unified metaphysical experience platform** where:
- Every feature knows about and integrates with every other relevant feature
- User's personal data (birth chart, crystal collection, journal history) informs ALL interactions
- LLM responses are deeply personalized using the user's complete spiritual profile
- Features create synergistic workflows (ritual → journal entry → healing suggestion)

### Key Integration Points
1. **Crystal Collection** ↔ All features use user's actual owned stones for recommendations
2. **User Profile** ↔ Birth chart data influences all astrological guidance and suggestions  
3. **Journal System** ↔ Mood tracking influences next-day recommendations across all features
4. **Moon Rituals** ↔ Scheduled rituals influence healing and guidance suggestions
5. **LLM Guidance** ↔ Every prompt includes user's stones, birth chart, and recent activity

## 📊 Core Data Models (Single Source of Truth)

### UserProfile (Primary Identity)
```dart
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
  
  // Must provide complete context for LLM prompts
  Map<String, dynamic> getSpiritualContext();
}
```

### CollectionEntry (User's Stones)
```dart
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
  String acquisitionSource;
}
```

### JournalEntry (Mood & Context Tracking)
```dart
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
```

### Subscription Tiers
- **Free**: 5 IDs/day, 5 crystals max, basic features only
- **Premium**: 30 IDs/day, unlimited crystals, marketplace access ($9.99/month)
- **Pro**: Unlimited IDs, advanced AI, Moon Rituals, Crystal Healing, Sound Bath ($19.99/month)
- **Founders**: Lifetime access, exclusive features (limited edition)

## 🔄 Feature Integration Requirements

### 1. Personalized LLM Prompt Engineering
**CRITICAL**: Every LLM interaction must include user context:

```dart
String buildGuidancePrompt(UserProfile profile, String query) {
  return """
USER CONTEXT:
- Astrological Profile: ${profile.birthChart.getSummary()}
- Owned Crystals: ${profile.collection.getActiveStones()}
- Recent Mood: ${profile.getRecentJournalMood()}
- Current Moon Phase: ${MoonPhaseCalculator.getCurrentPhase()}
- Subscription Tier: ${profile.tier}

RECENT ACTIVITY:
- Last Journal Entry: ${profile.getLastJournalSummary()}
- Recent Rituals: ${profile.getRecentRituals()}
- Crystal Usage Patterns: ${profile.getCrystalUsagePatterns()}

USER QUERY: ${query}

Generate personalized guidance using their specific stones and spiritual profile.
""";
}
```

### 2. Cross-Feature Data Flow Examples

#### Journal → Other Features
```dart
// When user journals anxiety, trigger healing suggestions
if (journalEntry.emotionalState == "anxious") {
  scheduleHealingSuggestion(
    crystals: collection.getCrystalsByPurpose("calming"),
    timing: "tomorrow_morning"
  );
}
```

#### Moon Ritual → Collection Integration
```dart
// Show ritual suggestions using owned crystals
MoonRitualSuggestion generateRitualSuggestion() {
  String currentPhase = MoonPhaseCalculator.getCurrentPhase();
  List<String> phaseAppropriateCrystals = getMoonPhaseCrystals(currentPhase);
  List<String> ownedPhaseCrystals = collection.filterOwned(phaseAppropriateCrystals);
  
  return MoonRitualSuggestion(
    phase: currentPhase,
    recommendedCrystals: ownedPhaseCrystals,
    personalizedIntention: generateIntention(userProfile.spiritualPreferences),
  );
}
```

#### Healing → Collection & Astrology
```dart
// Filter healing suggestions to user's actual stones and chart
List<CollectionEntry> availableCrystals = collectionService
  .getCrystalsByChakra(selectedChakra)
  .where((crystal) => crystal.isOwned)
  .toList();

String healingPrompt = """
User Profile: ${userProfile.getSpiritualContext()}
Available Crystals: ${availableCrystals.map((c) => c.crystalName).join(', ')}
Current Transit: ${birthChart.getCurrentTransits()}
Generate healing session using their owned crystals.
""";
```

## 🏗 Required System Components

### Backend Services (Must Be Real, Not Mock)
1. **Firebase Integration**: Authentication, Firestore, Cloud Functions
2. **Stripe Payment Processing**: Real subscription management
3. **Multi-LLM Service**: OpenAI GPT-4, Anthropic Claude, Google Gemini with tier-based access
4. **Horoscope API**: Free astrology service or LLM-generated from birth data
5. **Real Database**: Persistent storage for all user data

### Frontend Features (All Must Be Restored from Alpha)
1. **Moon Ritual Planner**: Complete calendar integration with owned crystal suggestions
2. **Crystal Energy Healing**: Chakra-based sessions using user's stones
3. **Sound Bath**: Full audio playback with user's meditation history
4. **Spiritual Journal**: Mood tracking that influences other features
5. **Marketplace**: Buy/sell crystals with payment processing

### Visual Design Specifications
1. **Logo**: Replace spinning text with amethyst icon from Crystal of the Day widget
2. **Marketplace Placement**: Horizontal strip between grid items with shimmer effects
3. **Daily Usage**: Integrate into Crystal ID widget, remove separate card
4. **Mystical Animations**: Consistent throughout all screens

## 🔧 Implementation Strategy

### Phase 1: Restore Alpha Functionality
1. Copy original working screens from `/mnt/c/Users/millz/Desktop/CrystalGrimoire-WORKING-BACKUP/`
2. Update imports and dependencies for current architecture
3. Restore Pro features behind subscription gates
4. Fix logo placement with amethyst icon

### Phase 2: Integration Layer
1. Implement shared data models
2. Create context-aware LLM prompt builders
3. Add cross-feature data flow
4. Integrate horoscope API or LLM generation

### Phase 3: Backend Infrastructure
1. Set up real Firebase/Stripe integration
2. Deploy production LLM services
3. Implement marketplace payment processing
4. Add comprehensive error handling

## 🧪 Testing Integration Points

### User Journey Testing
1. **Complete Flow**: User checks horoscope → journals mood → gets crystal healing suggestion → performs moon ritual → all data interconnected
2. **Personalization**: Every feature references user's actual stones and birth chart
3. **Subscription Gates**: Pro features properly locked and unlocked
4. **Data Persistence**: All user data survives app restarts and sessions

### Context Validation
```dart
// Test that every LLM prompt includes user context
void testPromptPersonalization() {
  String prompt = buildGuidancePrompt(testUser, "How should I prepare for tonight?");
  assert(prompt.contains(testUser.birthChart.sunSign));
  assert(prompt.contains(testUser.collection.favoriteStone));
  assert(prompt.contains(testUser.recentMood));
}
```

## 📁 File Structure & Locations

### Current Working Directories
- **Beta0.2 (Current)**: `/mnt/c/Users/millz/Desktop/CrystalGrimoireBeta0.2/`
- **Alpha Backup (Source)**: `/mnt/c/Users/millz/Desktop/CrystalGrimoire-WORKING-BACKUP/`
- **Demo Archive**: `/mnt/c/Users/millz/Desktop/CrystalGrimoireBeta0.2-Demo/`

### Key Files to Preserve/Reference
- **Original Home Screen**: `CrystalGrimoire-WORKING-BACKUP/crystal_grimoire_flutter/lib/screens/home_screen.dart`
- **Original LLM Service**: Look for working AI service implementations in backup
- **Original Collection Logic**: Existing collection management code
- **User Profile Models**: Current subscription and storage services

## 🎯 Success Criteria

### User Experience
- User enters birth data once, it influences ALL features
- User adds crystals to collection, they appear in ALL recommendations
- User journals mood, it affects next-day suggestions across ALL features
- Every interaction feels personal and interconnected

### Technical Requirements
- No mock data or demo implementations
- All features use shared data models
- LLM prompts always include user context
- Pro features properly gated behind subscriptions
- Real payment processing and user accounts

---

## 🚨 REMEMBER: This is a unified spiritual platform, not a collection of separate features. Every line of code should serve the user's holistic metaphysical journey through interconnected experiences.