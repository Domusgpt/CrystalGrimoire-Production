import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/crystal_collection.dart';
import '../models/birth_chart.dart';
import '../services/collection_service_v2.dart';
import '../services/astrology_service.dart';
import '../services/unified_ai_service.dart';
import '../services/storage_service.dart';
import '../config/theme.dart';
import '../config/mystical_theme.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/common/mystical_text_widgets.dart';
import '../widgets/animations/mystical_animations.dart';
import 'llm_lab_screen.dart';

class MetaphysicalGuidanceScreen extends StatefulWidget {
  const MetaphysicalGuidanceScreen({Key? key}) : super(key: key);

  @override
  State<MetaphysicalGuidanceScreen> createState() => _MetaphysicalGuidanceScreenState();
}

class _MetaphysicalGuidanceScreenState extends State<MetaphysicalGuidanceScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _parallaxController;
  late AnimationController _floatingController;
  
  String _selectedGuidanceType = 'daily';
  bool _isLoading = false;
  String? _currentGuidance;
  Map<String, dynamic>? _userProfile;
  final TextEditingController _queryController = TextEditingController();
  List<String> _selectedCrystals = [];
  int _dailyQueriesUsed = 0;
  int _dailyQueryLimit = 5; // For Pro tier

  final List<String> _guidanceTypes = [
    'daily',
    'crystal_selection',
    'chakra_balancing',
    'lunar_guidance',
    'manifestation',
    'healing_session',
    'spiritual_reading'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _parallaxController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _loadUserProfile();
    _loadQueryLimits();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _parallaxController.dispose();
    _floatingController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    // Build user profile from journal/collection data and birth chart
    final collectionService = context.read<CollectionServiceV2>();
    final collection = collectionService.collection;
    final stats = CollectionStats.fromCollection(collection, []);
    
    setState(() {
      _userProfile = {
        'collection_stats': stats.toAIContext(),
        'favorite_crystals': collection.where((e) => e.isFavorite).map((e) => e.crystal.name).toList(),
        'recent_crystals': collection.take(5).map((e) => {
          'name': e.crystal.name,
          'date_added': e.dateAdded.toIso8601String(),
          'chakras': e.crystal.chakras,
          'metaphysical_properties': e.crystal.metaphysicalProperties,
        }).toList(),
        'spiritual_preferences': {
          'meditation_crystals': collection.where((e) => e.primaryUses.contains('meditation')).length,
          'healing_crystals': collection.where((e) => e.primaryUses.contains('healing')).length,
          'protection_crystals': collection.where((e) => e.primaryUses.contains('protection')).length,
        }
      };
    });
  }

  Future<void> _loadQueryLimits() async {
    final queriesUsed = await StorageService.getDailyMetaphysicalQueries();
    final queryLimit = await StorageService.getMetaphysicalQueryLimit();
    
    setState(() {
      _dailyQueriesUsed = queriesUsed;
      _dailyQueryLimit = queryLimit == -1 ? 0 : queryLimit; // 0 means unlimited for display
    });
  }

  Future<void> _getPersonalizedGuidance() async {
    if (_isLoading || _userProfile == null) return;
    
    // Check if user can make queries
    final canQuery = await StorageService.canMakeMetaphysicalQuery();
    if (!canQuery) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _dailyQueryLimit == 0 
              ? 'Upgrade to Pro or Founders to access metaphysical guidance'
              : 'Daily query limit reached. Upgrade to Founders for unlimited access.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _currentGuidance = null;
    });

    try {
      // Get the AI service from context
      final aiService = context.read<UnifiedAIService>();
      
      // Build user query with context
      String userQuery = _queryController.text;
      if (_selectedCrystals.isNotEmpty) {
        userQuery += '\n\nFocus on these crystals from my collection: ${_selectedCrystals.join(', ')}';
      }
      
      // Additional context for the AI service
      final additionalContext = {
        'selected_crystals': _selectedCrystals,
        'guidance_focus': _selectedGuidanceType,
        'user_collection': _userProfile!['recent_crystals'],
        'spiritual_preferences': _userProfile!['spiritual_preferences'],
      };
      
      // Get personalized guidance using real LLM integration
      final guidance = await aiService.getPersonalizedGuidance(
        guidanceType: _selectedGuidanceType,
        userQuery: userQuery.isEmpty ? 'Please provide guidance for my spiritual journey today.' : userQuery,
        additionalContext: additionalContext,
      );

      // Track the query usage
      await StorageService.incrementMetaphysicalQueries();
      await _loadQueryLimits(); // Refresh the display

      setState(() {
        _currentGuidance = guidance;
      });
    } catch (e) {
      print('Guidance error: $e');
      setState(() {
        _currentGuidance = 'I apologize, beloved seeker. The cosmic energies are currently disrupted. Please try again in a moment.\n\nError: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildPersonalizedPrompt(String guidanceType) {
    final userStats = _userProfile!['collection_stats'] as Map<String, dynamic>;
    final favoriteCrystals = _userProfile!['favorite_crystals'] as List<dynamic>;
    final recentCrystals = _userProfile!['recent_crystals'] as List<dynamic>;
    
    String basePrompt = """You are the CrystalGrimoire Spiritual Advisor, providing deeply personalized metaphysical guidance. 

USER'S SPIRITUAL PROFILE:
- Crystal Collection: ${userStats['totalCrystals']} crystals
- Favorite Crystals: ${favoriteCrystals.join(', ')}
- Recent Additions: ${recentCrystals.map((c) => c['name']).join(', ')}
- Chakra Coverage: ${userStats['chakraCoverage']}
- Primary Purposes: ${userStats['primaryPurposes']}
- Collection Gaps: ${userStats['gaps']}

GUIDANCE REQUEST: """;

    switch (guidanceType) {
      case 'daily':
        return basePrompt + """Daily Spiritual Guidance
Provide personalized daily guidance incorporating their crystal collection and spiritual journey. Include:
- A crystal recommendation from their collection for today
- Specific meditation or intention-setting practice
- Astrological insights if relevant
- Personal affirmation based on their crystals""";
        
      case 'crystal_selection':
        return basePrompt + """Crystal Selection Guidance  
Based on their current collection and gaps, recommend:
- Which crystal from their collection to work with for a specific intention
- Crystals they should consider adding to balance their collection
- How to combine their existing crystals for maximum effect""";
        
      case 'chakra_balancing':
        return basePrompt + """Chakra Balancing Session
Create a personalized chakra balancing routine using their existing crystals:
- Identify which chakras need attention based on their collection
- Map their crystals to chakra healing
- Provide step-by-step balancing instructions""";
        
      case 'lunar_guidance':
        return basePrompt + """Lunar Cycle Guidance
Provide moon phase-specific guidance incorporating their crystals:
- How to work with their crystals during current moon phase
- Charging and cleansing rituals for their collection
- Manifestation practices aligned with lunar energy""";
        
      case 'manifestation':
        return basePrompt + """Manifestation Guidance
Create a personalized manifestation practice:
- Select crystals from their collection for manifestation work
- Design a crystal grid using their stones
- Provide specific affirmations and visualization techniques""";
        
      case 'healing_session':
        return basePrompt + """Healing Session Design
Design a healing session using their crystals:
- Identify healing crystals in their collection
- Create layouts for physical, emotional, or spiritual healing
- Provide step-by-step healing instructions""";
        
      case 'spiritual_reading':
        return basePrompt + """Spiritual Reading & Insights
Provide intuitive insights about their spiritual journey:
- Read the energy of their crystal collection
- Identify spiritual patterns and growth areas
- Offer guidance for their next steps on the path""";
        
      default:
        return basePrompt + "General spiritual guidance incorporating their unique crystal collection and spiritual journey.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Colors.purple.withOpacity(0.3),
              Colors.indigo.withOpacity(0.2),
              Colors.deepPurple.withOpacity(0.1),
              const Color(0xFF0F0F23),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildParallaxBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildGuidanceView(),
                        _buildToolsView(),
                        _buildInsightsView(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔮 Metaphysical Guidance',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Personalized spiritual wisdom & tools',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onLongPress: () async {
              // Dev feature: Long press to enable founders account
              final isFoundersEnabled = await StorageService.isFoundersAccountEnabled();
              
              if (!isFoundersEnabled) {
                await StorageService.enableFoundersAccount();
                await _loadQueryLimits();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 Founders Dev Account Enabled!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                await StorageService.disableFoundersAccount();
                await _loadQueryLimits();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Founders Account Disabled'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: Row(
              children: [
                // LLM Lab button for founders
                FutureBuilder<bool>(
                  future: StorageService.isFoundersAccountEnabled(),
                  builder: (context, snapshot) {
                    final isFounders = snapshot.data ?? false;
                    if (isFounders) {
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LLMLabScreen(),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.deepPurple, Colors.indigo],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.science, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'LAB',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                // Premium/Founders badge
                FutureBuilder<bool>(
                  future: StorageService.isFoundersAccountEnabled(),
                  builder: (context, snapshot) {
                    final isFounders = snapshot.data ?? false;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isFounders 
                            ? [const Color(0xFFFFD700), Colors.amber]
                            : [Colors.amber, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isFounders ? 'FOUNDERS' : 'PREMIUM',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.indigo],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        tabs: const [
          Tab(text: 'Guidance'),
          Tab(text: 'Tools'),
          Tab(text: 'Insights'),
        ],
      ),
    );
  }

  Widget _buildGuidanceView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MysticalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_fix_high, color: Colors.purple[300]),
                  const SizedBox(width: 8),
                  const Text(
                    'Personalized Guidance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Select the type of guidance you seek:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              _buildGuidanceTypeSelector(),
              const SizedBox(height: 20),
              
              // Query input field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: TextField(
                  controller: _queryController,
                  maxLength: 500,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ask your spiritual question or describe what guidance you seek...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    contentPadding: const EdgeInsets.all(16),
                    border: InputBorder.none,
                    counterStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Crystal selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.diamond, size: 16, color: Colors.purple[300]),
                      const SizedBox(width: 8),
                      const Text(
                        'Select crystals from your collection:',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildCrystalSelector(),
                ],
              ),
              const SizedBox(height: 20),
              
              // Quick action buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickActionButton(
                    'Daily Horoscope',
                    Icons.stars,
                    () => _quickAction('horoscope'),
                  ),
                  _buildQuickActionButton(
                    'Crystal Meditation',
                    Icons.self_improvement,
                    () => _quickAction('meditation'),
                  ),
                  _buildQuickActionButton(
                    'Moon Phase Ritual',
                    Icons.nightlight_round,
                    () => _quickAction('moon_ritual'),
                  ),
                  _buildQuickActionButton(
                    'Chakra Balance',
                    Icons.motion_photos_on,
                    () => _quickAction('chakra'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Query usage indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.purple[300]),
                    const SizedBox(width: 8),
                    Text(
                      _dailyQueryLimit == 0
                        ? 'Queries today: $_dailyQueriesUsed (Unlimited)'
                        : 'Queries today: $_dailyQueriesUsed / $_dailyQueryLimit',
                      style: TextStyle(
                        color: Colors.purple[300],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              _isLoading
                ? Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.purple.withOpacity(0.3),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : MysticalButton(
                    onPressed: _getPersonalizedGuidance,
                    text: 'Receive Guidance',
                    color: Colors.purple,
                    width: double.infinity,
                  ),
            ],
          ),
        ),
        if (_currentGuidance != null) ...[
          const SizedBox(height: 16),
          MysticalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.amber[300]),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Personal Guidance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _currentGuidance!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGuidanceTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _guidanceTypes.map((type) {
        final isSelected = type == _selectedGuidanceType;
        return GestureDetector(
          onTap: () => setState(() => _selectedGuidanceType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected 
                ? LinearGradient(colors: [Colors.purple, Colors.indigo])
                : null,
              color: isSelected ? null : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.3),
              ),
            ),
            child: Text(
              _getGuidanceTypeLabel(type),
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getGuidanceTypeLabel(String type) {
    switch (type) {
      case 'daily': return 'Daily Guidance';
      case 'crystal_selection': return 'Crystal Selection';
      case 'chakra_balancing': return 'Chakra Balancing';
      case 'lunar_guidance': return 'Lunar Guidance';
      case 'manifestation': return 'Manifestation';
      case 'healing_session': return 'Healing Session';
      case 'spiritual_reading': return 'Spiritual Reading';
      default: return type;
    }
  }

  Widget _buildToolsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MysticalCard(
          child: Column(
            children: [
              Icon(Icons.construction, color: Colors.orange[300], size: 48),
              const SizedBox(height: 16),
              const Text(
                'Spiritual Tools & Calculators',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Advanced tools for crystal grids, lunar calculations, and chakra analysis coming soon.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_userProfile != null) _buildProfileInsights(),
      ],
    );
  }

  Widget _buildProfileInsights() {
    final stats = _userProfile!['collection_stats'] as Map<String, dynamic>;
    
    return MysticalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: Colors.blue[300]),
              const SizedBox(width: 8),
              const Text(
                'Your Spiritual Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightRow('Total Crystals', '${stats['totalCrystals']}'),
          _buildInsightRow('Chakra Coverage', '${(stats['chakraCoverage'] as Map).length} chakras'),
          _buildInsightRow('Collection Gaps', '${(stats['gaps'] as List).length} areas'),
          const SizedBox(height: 16),
          if ((stats['gaps'] as List).isNotEmpty) ...[
            const Text(
              'Recommended Additions:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ...(stats['gaps'] as List).map((gap) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $gap',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParallaxBackground() {
    return AnimatedBuilder(
      animation: _parallaxController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.sin(_parallaxController.value * 2 * math.pi) * 0.3,
                math.cos(_parallaxController.value * 2 * math.pi) * 0.3,
              ),
              radius: 1.5,
              colors: [
                Colors.purple.withOpacity(0.2),
                Colors.indigo.withOpacity(0.1),
                Colors.deepPurple.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCrystalSelector() {
    final collection = context.read<CollectionServiceV2>().collection;
    
    if (collection.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.white.withOpacity(0.5)),
            const SizedBox(width: 8),
            Text(
              'No crystals in collection yet',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ],
        ),
      );
    }
    
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: collection.length,
        itemBuilder: (context, index) {
          final entry = collection[index];
          final isSelected = _selectedCrystals.contains(entry.crystal.name);
          
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedCrystals.remove(entry.crystal.name);
                } else {
                  if (_selectedCrystals.length < 3) {
                    _selectedCrystals.add(entry.crystal.name);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Maximum 3 crystals can be selected'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              });
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected 
                  ? Colors.purple.withOpacity(0.3)
                  : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                    ? Colors.purple
                    : Colors.white.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.diamond,
                    size: 24,
                    color: isSelected ? Colors.purple : Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.crystal.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.purple : Colors.white.withOpacity(0.7),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _quickAction(String action) {
    String quickPrompt = '';
    String guidanceType = '';
    
    switch (action) {
      case 'horoscope':
        quickPrompt = 'Please provide my daily horoscope based on my birth chart and current crystal collection. Include specific crystal recommendations for today.';
        guidanceType = 'daily';
        break;
      case 'meditation':
        quickPrompt = 'Suggest a crystal meditation practice for today. Include which crystals from my collection to use and step-by-step instructions.';
        guidanceType = 'crystal_selection';
        break;
      case 'moon_ritual':
        quickPrompt = 'What moon phase ritual should I perform today? Include crystal recommendations from my collection and ritual instructions.';
        guidanceType = 'lunar_guidance';
        break;
      case 'chakra':
        quickPrompt = 'Analyze my chakra balance based on my crystal collection and provide a balancing session using my crystals.';
        guidanceType = 'chakra_balancing';
        break;
    }
    
    // Set the query and guidance type
    setState(() {
      _queryController.text = quickPrompt;
      _selectedGuidanceType = guidanceType;
    });
    
    // Automatically submit the query
    _getPersonalizedGuidance();
  }
}