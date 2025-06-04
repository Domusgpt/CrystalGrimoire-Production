import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../widgets/animations/mystical_animations.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/crystal_logo_painter.dart';
import '../widgets/teal_red_gem_logo.dart';
import '../widgets/gem_symbol_logo.dart';
import '../widgets/daily_crystal_card.dart';
import 'camera_screen.dart';
import 'collection_screen.dart';
import 'journal_screen.dart';
import 'settings_screen.dart';
import 'metaphysical_guidance_screen.dart';
import 'account_screen.dart';
import 'dart:math' as math;

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    
    return Scaffold(
      body: Stack(
        children: [
          // Enhanced mystical background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D0221), // Deep mystical purple-black
                  Color(0xFF1A0B2E), // Dark violet
                  Color(0xFF16213E), // Midnight blue
                ],
              ),
            ),
          ),
          
          // Animated crystal particles
          const FloatingParticles(
            particleCount: 20,
            color: Color(0xFF9D4EDD),
          ),
          
          // Additional floating crystals
          Positioned(
            top: 100,
            left: -50,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Opacity(
                    opacity: 0.3,
                    child: Icon(
                      Icons.diamond,
                      size: 100,
                      color: Color(0xFF7B2CBF),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Positioned(
            bottom: 150,
            right: -30,
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_floatAnimation.value * 0.8),
                  child: Opacity(
                    opacity: 0.2,
                    child: Icon(
                      Icons.hexagon,
                      size: 120,
                      color: Color(0xFF9D4EDD),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // App header with animated logo
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Amethyst Crystal Logo (from Crystal of the Day)
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 200),
                            child: const GemSymbolLogo(
                              size: 120,
                              animate: true,
                              colors: [
                                Color(0xFF9966CC), // Amethyst purple
                                Color(0xFF8A2BE2), // Blue violet
                                Color(0xFFDDA0DD), // Plum
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Shimmering title
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 400),
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Color(0xFFE0AAFF),
                                  Color(0xFFC77DFF),
                                  Color(0xFF9D4EDD),
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                              child: Text(
                                'Crystal Grimoire',
                                style: GoogleFonts.cinzelDecorative(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Animated subtitle
                          FadeScaleIn(
                            delay: const Duration(milliseconds: 600),
                            child: AnimatedDefaultTextStyle(
                              duration: Duration(seconds: 2),
                              style: GoogleFonts.raleway(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 1.5,
                              ),
                              child: Text('Your Mystical Crystal Companion'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Enhanced Crystal Identification - MORE PROMINENT
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: FadeScaleIn(
                        delay: const Duration(milliseconds: 800),
                        child: _EnhancedCrystalIdentificationCard(
                          onShare: (shareType) => _showShareOptions(context, shareType),
                        ),
                      ),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  
                  // Feature cards grid
                  SliverPadding(
                    padding: const EdgeInsets.all(20.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildListDelegate([
                        FadeScaleIn(
                          delay: const Duration(milliseconds: 1000),
                          child: FeatureCard(
                            icon: Icons.collections_bookmark,
                            title: 'Collection',
                            description: 'Your crystal inventory',
                            iconColor: Colors.amber,
                            isPremium: false,
                            infoText: '${appState.collectionCount} Crystals',
                            infoSubtext: appState.isPremiumUser ? 'Unlimited' : '5 Free Slots',
                            onTap: () => _navigateToCollection(context),
                          ),
                        ),
                        FadeScaleIn(
                          delay: const Duration(milliseconds: 1100),
                          child: FeatureCard(
                            icon: Icons.book,
                            title: 'Journal',
                            description: 'Spiritual journal & insights',
                            iconColor: Colors.blue,
                            isPremium: true,
                            infoText: '${appState.currentMonthUsage['journal_entries']} Entries',
                            infoSubtext: 'Premium Feature',
                            onTap: () => _navigateToJournal(context),
                          ),
                        ),
                        FadeScaleIn(
                          delay: const Duration(milliseconds: 1200),
                          child: FeatureCard(
                            icon: Icons.auto_fix_high,
                            title: 'Guidance',
                            description: 'AI spiritual wisdom',
                            iconColor: Colors.purple,
                            isPremium: true,
                            infoText: _getUsageLimitText(appState),
                            infoSubtext: 'Premium Feature',
                            onTap: () => _navigateToMetaphysicalGuidance(context),
                          ),
                        ),
                        FadeScaleIn(
                          delay: const Duration(milliseconds: 1300),
                          child: FeatureCard(
                            icon: Icons.account_circle,
                            title: 'Account',
                            description: 'Profile & billing',
                            iconColor: Colors.green,
                            infoText: appState.isPremiumUser ? 'Premium' : 'Free',
                            infoSubtext: appState.subscriptionTier.toUpperCase(),
                            onTap: () => _navigateToAccount(context),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  
                  // Horizontal Marketplace Button with Heavy Effects
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FadeScaleIn(
                        delay: const Duration(milliseconds: 1400),
                        child: _buildMarketplaceButton(context),
                      ),
                    ),
                  ),
                  
                  // Crystal of the Day (moved here, smaller size)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: FadeScaleIn(
                        delay: const Duration(milliseconds: 1500),
                        child: Container(
                          height: 120, // Smaller size
                          child: const DailyCrystalCard(),
                        ),
                      ),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  
                  // Daily Insight Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FadeScaleIn(
                        delay: const Duration(milliseconds: 1600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Insights',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 12),
                            // Daily message with moon and astrology
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF4A148C).withOpacity(0.8),
                                    Color(0xFF6A1B99).withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color(0xFF9C27B0).withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '🌙 ${_getCurrentMoonPhase()} Moon Energy',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE1BEE7),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _getDailyInsightMessage(),
                                    style: GoogleFonts.raleway(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF240046).withOpacity(0.8),
                                    Color(0xFF3C096C).withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Color(0xFF7209B7).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.nights_stay,
                                        color: Color(0xFFE0AAFF),
                                        size: 28,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Moon Phase',
                                              style: TextStyle(
                                                color: Color(0xFFE0AAFF),
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              _getCurrentMoonPhase(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _buildDailyInsightChip(
                                        icon: Icons.favorite,
                                        label: 'Love Energy',
                                        color: Colors.pink,
                                      ),
                                      SizedBox(width: 8),
                                      _buildDailyInsightChip(
                                        icon: Icons.bolt,
                                        label: '${_getElement()} Element',
                                        color: Colors.orange,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          ),
          
          // Enhanced floating action button
          Positioned(
            bottom: 20,
            right: 20,
            child: FadeScaleIn(
              delay: const Duration(milliseconds: 1800),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF7209B7), Color(0xFF560BAD)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF7209B7).withOpacity(0.5),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () => _navigateToSettings(context),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Icon(Icons.settings, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
  
  Widget _buildDailyInsightChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getCurrentMoonPhase() {
    final phases = ['New Moon', 'Waxing', 'Full Moon', 'Waning'];
    return phases[DateTime.now().day ~/ 8 % phases.length];
  }
  
  String _getDailyInsightMessage() {
    final moonPhase = _getCurrentMoonPhase();
    final element = _getElement();
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    
    final messages = {
      'New Moon': [
        'Perfect time for new beginnings and setting crystal intentions. The universe is ready for your manifestations.',
        'Plant seeds of intention today. Your crystals are charged with fresh lunar energy for new projects.',
        'This new moon brings clarity and vision. Trust your intuition as you work with your crystal allies.',
      ],
      'Waxing': [
        'Building energy supports growth and expansion. Your crystals are amplifying your progress toward goals.',
        'The growing moon enhances manifestation power. Focus your crystal work on abundance and achievement.',
        'Rising lunar energy strengthens your spiritual practice. Let your crystals guide you toward success.',
      ],
      'Full Moon': [
        'Peak lunar energy illuminates hidden truths. Your crystals are at maximum power for healing and insight.',
        'The full moon reveals what needs to be released. Use your crystals for powerful cleansing rituals.',
        'Heightened intuition and psychic abilities flow freely. Your crystal connections are especially strong tonight.',
      ],
      'Waning': [
        'Releasing energy helps clear blockages and old patterns. Your crystals support letting go and renewal.',
        'The diminishing moon aids in banishing negativity. Trust your crystals to protect and purify your energy.',
        'Time for reflection and gratitude. Your crystals have absorbed much - cleanse and appreciate their service.',
      ],
    };
    
    final phaseMessages = messages[moonPhase] ?? messages['New Moon']!;
    final selectedMessage = phaseMessages[dayOfYear % phaseMessages.length];
    
    return '$selectedMessage The $element element is particularly active today, bringing ${_getElementalGift(element)} energy to your spiritual practice.';
  }
  
  String _getElementalGift(String element) {
    switch (element) {
      case 'Fire': return 'passionate and transformative';
      case 'Earth': return 'grounding and stabilizing';
      case 'Air': return 'clarity and communication';
      case 'Water': return 'emotional healing and intuitive';
      default: return 'balanced and harmonious';
    }
  }
  
  String _getElement() {
    final elements = ['Fire', 'Earth', 'Air', 'Water'];
    return elements[DateTime.now().day % elements.length];
  }
  
  String _getUsageLimitText(AppState appState) {
    if (appState.subscriptionTier == 'pro') {
      return 'Unlimited';
    } else if (appState.subscriptionTier == 'premium') {
      return '${appState.currentMonthUsage['identifications']}/30';
    } else {
      return '${appState.currentMonthUsage['identifications']}/${appState.monthlyLimit}';
    }
  }
  
  int _getDailyLimit(AppState appState) {
    if (appState.subscriptionTier == 'pro') {
      return 999; // Unlimited
    } else if (appState.subscriptionTier == 'premium') {
      return 30;
    } else {
      return appState.monthlyLimit;
    }
  }
  
  Widget _buildMarketplaceButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * 0.3),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.9), // Gold
                  const Color(0xFFE0115F).withOpacity(0.8), // Ruby
                  const Color(0xFF50C878).withOpacity(0.8), // Emerald
                  const Color(0xFF0F52BA).withOpacity(0.9), // Sapphire
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: const Color(0xFFE0115F).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Shimmer overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        begin: Alignment(-1.0 + (_floatAnimation.value + 10) * 0.1, 0),
                        end: Alignment(1.0 + (_floatAnimation.value + 10) * 0.1, 0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Main button content
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _navigateToMarketplace(context),
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: Row(
                        children: [
                          // Multi-colored gem icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.9),
                                  const Color(0xFFFFD700).withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.diamond,
                                  color: const Color(0xFFE0115F),
                                  size: 28,
                                ),
                                Transform.rotate(
                                  angle: (_floatAnimation.value + 10) * 0.1,
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 20),
                          
                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '💎 CRYSTAL MARKETPLACE',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  'Buy • Sell • Trade Premium Crystals',
                                  style: GoogleFonts.raleway(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Pulsing arrow
                          Transform.scale(
                            scale: 1.0 + (_floatAnimation.value + 10) * 0.01,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEnhancedUsageCard(BuildContext context, AppState appState, ThemeData theme) {
    final usageData = appState.currentMonthUsage;
    final isFreeTier = appState.subscriptionTier == 'free';
    final limit = appState.monthlyLimit;
    final used = usageData['identifications'] ?? 0;
    final remaining = limit - used;
    final percentage = limit > 0 ? used / limit : 0.0;
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface.withOpacity(0.8),
            theme.colorScheme.surface.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Usage',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isFreeTier ? 'Free Tier' : appState.subscriptionTier.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isFreeTier ? Colors.grey : Colors.amber,
                    ),
                  ),
                ],
              ),
              if (isFreeTier)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.deepPurple],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Upgrade',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20),
          
          // Enhanced usage display
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$used / $limit',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Crystals Identified Today',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 8,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage > 0.8 ? Colors.orange : theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '$remaining',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      child: Text(
                        'left',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (isFreeTier) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Upgrade for unlimited identifications & premium features!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  // Navigation methods
  void _navigateToIdentify(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
  }
  
  void _navigateToCollection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CollectionScreen()),
    );
  }
  
  void _navigateToJournal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JournalScreen()),
    );
  }
  
  void _navigateToMetaphysicalGuidance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MetaphysicalGuidanceScreen()),
    );
  }
  
  void _navigateToAccount(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountScreen()),
    );
  }
  
  void _navigateToMarketplace(BuildContext context) {
    // TODO: Implement marketplace screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marketplace coming soon!'),
        backgroundColor: Colors.amber,
      ),
    );
  }
  
  void _showShareOptions(BuildContext context, String shareType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D1B69),
              Color(0xFF1A0B2E),
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              margin: EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '✨ Share Your Crystal Journey',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShareButton(
                        icon: Icons.link,
                        label: 'Copy Link',
                        color: Color(0xFF9C27B0),
                        onTap: () => _copyShareLink(context, shareType),
                      ),
                      _buildShareButton(
                        icon: Icons.facebook,
                        label: 'Facebook',
                        color: Color(0xFF1877F2),
                        onTap: () => _shareToSocial(context, 'facebook', shareType),
                      ),
                      _buildShareButton(
                        icon: Icons.share,
                        label: 'Twitter',
                        color: Color(0xFF1DA1F2),
                        onTap: () => _shareToSocial(context, 'twitter', shareType),
                      ),
                      _buildShareButton(
                        icon: Icons.message,
                        label: 'Message',
                        color: Color(0xFF25D366),
                        onTap: () => _shareToSocial(context, 'message', shareType),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  void _copyShareLink(BuildContext context, String shareType) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔗 Link copied! Share your crystal discoveries with friends'),
        backgroundColor: Color(0xFF9C27B0),
      ),
    );
  }
  
  void _shareToSocial(BuildContext context, String platform, String shareType) {
    Navigator.pop(context);
    final messages = {
      'crystal_identification': '🔮 Just discovered an amazing crystal using Crystal Grimoire! Check out this mystical app for identifying and learning about crystals ✨',
      'journal': '📖 Recording my spiritual journey with Crystal Grimoire - the most beautiful crystal companion app! 🌙',
      'guidance': '🔮 Got incredible spiritual guidance from Crystal Grimoire today! This AI oracle is amazing ✨',
    };
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📱 Opening $platform to share: ${messages[shareType]}'),
        backgroundColor: Color(0xFF1DA1F2),
      ),
    );
  }
}

// Enhanced Crystal Identification Card with prominent positioning
class _EnhancedCrystalIdentificationCard extends StatefulWidget {
  final Function(String) onShare;
  
  const _EnhancedCrystalIdentificationCard({
    Key? key,
    required this.onShare,
  }) : super(key: key);
  
  @override
  State<_EnhancedCrystalIdentificationCard> createState() => _EnhancedCrystalIdentificationCardState();
}

class _EnhancedCrystalIdentificationCardState extends State<_EnhancedCrystalIdentificationCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _shimmerAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Stack(
            children: [
              Container(
            height: 150, // 25% larger for more prominence
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF20B2AA).withOpacity(0.8), // Teal from gem logo
                  const Color(0xFFFF4500).withOpacity(0.7), // Red from gem logo
                  const Color(0xFFFFD700).withOpacity(0.6), // Gold accent
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF20B2AA).withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: const Color(0xFFFF4500).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Shimmer overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment(-1.0 + _shimmerAnimation.value * 2, 0),
                        end: Alignment(1.0 + _shimmerAnimation.value * 2, 0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Main content
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _navigateToIdentify(context),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Enhanced icon with multiple animations
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.9),
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0.3),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Main camera icon
                                Icon(
                                  Icons.photo_camera,
                                  color: const Color(0xFF20B2AA),
                                  size: 40,
                                ),
                                // Rotating sparkle
                                Transform.rotate(
                                  angle: _shimmerAnimation.value * 2 * math.pi,
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: const Color(0xFFFFD700),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 20),
                          
                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'IDENTIFY CRYSTAL',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Take a photo or describe your crystal',
                                  style: GoogleFonts.raleway(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'TAP TO START',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Daily usage display (moved here from separate card)
                                Consumer<AppState>(
                                  builder: (context, appState, child) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.flash_on,
                                            color: Color(0xFFFFD700),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${appState.currentMonthUsage['identifications'] ?? 0}/${appState.subscriptionTier == 'pro' ? 999 : appState.subscriptionTier == 'premium' ? 30 : appState.monthlyLimit} uses today',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          // Share and Arrow indicators
                          Row(
                            children: [
                              // Share button
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                child: GestureDetector(
                                  onTap: () => widget.onShare('crystal_identification'),
                                  child: Icon(
                                    Icons.share,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Arrow indicator
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white.withOpacity(0.8),
                                size: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
              ),
              
              // Ammolite sparkle effect overlay (moved from Crystal of the Day)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: AmmoliteSparklesPainter(
                      progress: _shimmerAnimation.value,
                      intensity: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _navigateToIdentify(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    );
  }
}

// Keep the enhanced FeatureCard from original file
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isPremium;
  final String? infoText;
  final String? infoSubtext;

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.onTap,
    this.isPremium = false,
    this.infoText,
    this.infoSubtext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface.withOpacity(0.8),
              theme.colorScheme.surface.withOpacity(0.6),
            ],
          ),
          border: Border.all(
            color: isPremium 
              ? Colors.amber.withOpacity(0.5)
              : theme.colorScheme.outline.withOpacity(0.2),
            width: isPremium ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isPremium 
                ? Colors.amber.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          iconColor.withOpacity(0.3),
                          iconColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  if (infoText != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            infoText!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: iconColor,
                            ),
                          ),
                          if (infoSubtext != null)
                            Text(
                              infoSubtext!,
                              style: TextStyle(
                                fontSize: 10,
                                color: iconColor.withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isPremium)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.black),
                      const SizedBox(width: 2),
                      Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for ammolite/diamond sparkle effects
class AmmoliteSparklesPainter extends CustomPainter {
  final double progress;
  final double intensity;
  
  AmmoliteSparklesPainter({
    required this.progress,
    required this.intensity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(42); // Fixed seed for consistent pattern
    
    // Draw ammolite-style shimmering particles
    for (int i = 0; i < 15; i++) {
      final angle = (i * 24 + progress * 360) * math.pi / 180;
      final distance = 30 + random.nextDouble() * (size.width * 0.3);
      final sparkleSize = 2 + random.nextDouble() * 4;
      
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);
      
      // Cycle through ammolite colors
      final colorIndex = (progress * 3 + i * 0.3) % 1.0;
      Color sparkleColor;
      
      if (colorIndex < 0.33) {
        sparkleColor = Color.lerp(
          const Color(0xFF20B2AA), // Teal
          const Color(0xFFFF4500), // Red-orange
          (colorIndex / 0.33),
        )!;
      } else if (colorIndex < 0.66) {
        sparkleColor = Color.lerp(
          const Color(0xFFFF4500), // Red-orange
          const Color(0xFFFFD700), // Gold
          ((colorIndex - 0.33) / 0.33),
        )!;
      } else {
        sparkleColor = Color.lerp(
          const Color(0xFFFFD700), // Gold
          const Color(0xFF20B2AA), // Teal
          ((colorIndex - 0.66) / 0.34),
        )!;
      }
      
      final opacity = math.sin(progress * math.pi * 2 + i * 0.5) * 0.5 + 0.5;
      paint.color = sparkleColor.withOpacity(opacity * intensity * 0.8);
      
      // Draw diamond-shaped sparkle
      final sparklePath = Path()
        ..moveTo(x, y - sparkleSize)
        ..lineTo(x + sparkleSize * 0.6, y)
        ..lineTo(x, y + sparkleSize)
        ..lineTo(x - sparkleSize * 0.6, y)
        ..close();
      
      canvas.drawPath(sparklePath, paint);
      
      // Add center highlight
      paint.color = Colors.white.withOpacity(opacity * intensity * 0.6);
      canvas.drawCircle(Offset(x, y), sparkleSize * 0.3, paint);
    }
    
    // Add central faceted crystal reflection
    final reflectionPaint = Paint()
      ..color = Colors.white.withOpacity(0.3 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final reflectionSize = 60 + intensity * 20;
    final reflectionPath = Path();
    
    // Create hexagonal faceted pattern
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 + progress * 30) * math.pi / 180;
      final x = center.dx + reflectionSize * math.cos(angle);
      final y = center.dy + reflectionSize * math.sin(angle);
      
      if (i == 0) {
        reflectionPath.moveTo(x, y);
      } else {
        reflectionPath.lineTo(x, y);
      }
    }
    reflectionPath.close();
    
    canvas.drawPath(reflectionPath, reflectionPaint);
    
    // Add internal facet lines
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 + progress * 30) * math.pi / 180;
      final x = center.dx + reflectionSize * math.cos(angle);
      final y = center.dy + reflectionSize * math.sin(angle);
      
      canvas.drawLine(
        center,
        Offset(x, y),
        reflectionPaint..strokeWidth = 1,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}