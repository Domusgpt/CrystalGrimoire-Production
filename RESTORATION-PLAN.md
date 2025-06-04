# Crystal Grimoire - Exact Restoration Plan

## 🎯 Step-by-Step Restoration Instructions

### Phase 1: Logo & Visual Fixes (HIGH PRIORITY)

#### 1A. Find & Replace Main Logo
- **Source**: Look for "Crystal of the Day" widget in Alpha code
- **Location**: `/mnt/c/Users/millz/Desktop/CrystalGrimoire-WORKING-BACKUP/crystal_grimoire_flutter/lib/`
- **Search for**: Files containing "Crystal of the Day" or amethyst references
- **Task**: Extract amethyst icon and replace spinning "Crystal Grimoire" text logo
- **Target**: `lib/screens/unified_home_screen.dart` - replace logo implementation

#### 1B. Marketplace Horizontal Placement
- **Current**: Marketplace button placement is wrong
- **Requirement**: Horizontal strip BETWEEN grid items with heavy shimmer effects
- **Reference**: User's "WHERE MARKET PLACE GOES.png" annotations

### Phase 2: Restore Alpha Features (CORE FUNCTIONALITY)

#### 2A. Moon Ritual Planner
- **Source**: `/mnt/c/Users/millz/Desktop/CrystalGrimoire-WORKING-BACKUP/crystal_grimoire_flutter/lib/screens/`
- **Find**: `moon_ritual_planner.dart` (or similar moon/ritual files)
- **Copy to**: `lib/screens/moon_ritual_planner.dart`
- **Integration**: Must use user's owned crystals from Collection
- **Gate**: Pro subscription required

#### 2B. Crystal Energy Healing
- **Source**: Look for `crystal_energy_healing.dart` or `healing_screen.dart` in Alpha
- **Copy to**: `lib/screens/crystal_healing_screen.dart`
- **Integration**: Filter recommendations to user's actual stone collection
- **Gate**: Pro subscription required

#### 2C. Sound Bath
- **Source**: Alpha's `sound_bath_screen.dart` with working AudioPlayer
- **Current**: Beta0.2 has broken placeholder at `lib/screens/sound_bath_screen.dart`
- **Task**: Replace broken code with working Alpha version
- **Assets**: Copy audio files from Alpha's `assets/audio/sound_bath/`
- **Gate**: Pro subscription required

#### 2D. Journal as Pro Feature
- **Current**: `lib/screens/journal_screen.dart` exists but may be limited
- **Task**: Make it Pro-only and integrate with Collection storage
- **Data**: Store entries in Collection system, not separate storage
- **Context**: Journal mood should influence next-day suggestions

### Phase 3: Real LLM Integration (NO MORE MOCKS)

#### 3A. Replace Mock Services
- **Current**: Beta0.2 may have demo/mock LLM responses
- **Source**: Alpha's working AI service integrations
- **APIs**: OpenAI, Anthropic Claude, Google Gemini
- **Tiers**: Free=Gemini, Premium=GPT-4, Pro=Claude
- **Context**: ALL prompts must include user's stones and birth chart

#### 3B. Personalized Prompt Building
- **Requirement**: Every LLM call includes:
  - User's birth chart (sun/moon/ascendant signs)
  - Owned crystal collection (names and properties)
  - Recent journal mood
  - Current moon phase
  - Subscription tier
- **Implementation**: Create `LLMPromptBuilder` service
- **No Generic**: Never send blank/generic prompts

### Phase 4: System Integration (CRITICAL)

#### 4A. Shared Data Models
- **UserProfile**: Birth chart, subscription, preferences
- **CollectionEntry**: User's owned stones with metadata
- **JournalEntry**: Mood tracking linked to crystals/astrology
- **All Features**: Must reference same data, no isolated copies

#### 4B. Cross-Feature Integration Examples
- Journal anxiety → suggest calming crystals from collection
- Moon ritual completed → create journal entry + update recommendations
- Healing session → only show owned crystals, log usage
- Guidance → include recent journal mood in prompt context

### Phase 5: Backend Infrastructure (PRODUCTION READY)

#### 5A. Real Services Setup
- **Firebase**: Authentication, Firestore, Cloud Functions
- **Stripe**: Payment processing for subscriptions
- **Horoscope API**: Free astrology service integration
- **Error Handling**: Comprehensive, not just console.log

#### 5B. Subscription Gates
- **Free**: Basic features only (5 IDs/day, 5 crystals max)
- **Pro**: Moon Ritual, Crystal Healing, Sound Bath, advanced AI
- **Implementation**: Check subscription before showing Pro features
- **UI**: Show "Upgrade to Pro" dialogs for locked features

## 📁 File Locations Reference

### Source (Alpha - Working)
```
/mnt/c/Users/millz/Desktop/CrystalGrimoire-WORKING-BACKUP/
├── crystal_grimoire_flutter/lib/
│   ├── screens/ (moon ritual, healing, etc.)
│   ├── services/ (working AI services)
│   └── widgets/ (crystal of the day widget)
└── assets/ (sound bath audio files)
```

### Target (Beta0.2 - Current Work)
```
/mnt/c/Users/millz/Desktop/CrystalGrimoireBeta0.2/
├── lib/screens/ (restore Alpha features here)
├── lib/services/ (fix LLM integration)
└── assets/ (copy Alpha audio/images)
```

### Demo Archive (Preserve Current Work)
```
/mnt/c/Users/millz/Desktop/CrystalGrimoireBeta0.2-Demo/
└── (current demo implementation saved here)
```

## ✅ Success Validation

### User Experience Test
1. User sets birth chart → affects ALL feature recommendations
2. User adds crystal to collection → appears in healing/ritual suggestions
3. User journals mood → influences next-day guidance
4. Pro features locked for free users, unlocked for paid
5. No mock/demo responses anywhere

### Technical Validation
- All LLM prompts include user context
- All features use shared data models
- No isolated feature silos
- Real payment processing works
- App feels like unified platform, not separate tools

---

**NEXT IMMEDIATE STEPS:**
1. Find amethyst icon in Alpha "Crystal of the Day" widget
2. Replace spinning logo in `unified_home_screen.dart`
3. Copy working Alpha features to Beta0.2
4. Replace any mock LLM services with real integrations