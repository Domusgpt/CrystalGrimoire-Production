import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/animations/mystical_animations.dart';
import '../data/crystal_database.dart';

class CrystalInfoScreen extends StatefulWidget {
  final String? crystalId;

  const CrystalInfoScreen({Key? key, this.crystalId}) : super(key: key);

  @override
  State<CrystalInfoScreen> createState() => _CrystalInfoScreenState();
}

class _CrystalInfoScreenState extends State<CrystalInfoScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _sparkleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sparkleAnimation;
  
  CrystalData? _crystal;
  bool _isInCollection = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
    
    _loadCrystalData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  void _loadCrystalData() {
    // Simulate loading
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        if (widget.crystalId != null) {
          _crystal = CrystalDatabase.getCrystalById(widget.crystalId!);
        } else {
          // Default to first crystal if no ID provided
          _crystal = CrystalDatabase.crystals.first;
        }
        _isLoading = false;
      });
      _fadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Stack(
        children: [
          // Background particles
          const Positioned.fill(
            child: FloatingParticles(
              particleCount: 25,
              color: Colors.deepPurple,
            ),
          ),
          
          // Main content
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              if (_isLoading)
                SliverFillRemaining(
                  child: _buildLoadingState(),
                )
              else if (_crystal != null)
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildCrystalInfo(),
                  ),
                )
              else
                SliverFillRemaining(
                  child: _buildErrorState(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0F0F23),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_crystal != null)
          IconButton(
            icon: Icon(
              _isInCollection ? Icons.favorite : Icons.favorite_border,
              color: _isInCollection ? Colors.red : Colors.white,
            ),
            onPressed: _toggleCollection,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _crystal != null ? _buildCrystalImage() : Container(),
      ),
    );
  }

  Widget _buildCrystalImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getCrystalColor(_crystal!.color).withOpacity(0.8),
                const Color(0xFF0F0F23),
              ],
            ),
          ),
        ),
        
        // Sparkle effects
        AnimatedBuilder(
          animation: _sparkleAnimation,
          builder: (context, child) {
            return Positioned(
              top: 100 + (_sparkleAnimation.value * 50),
              right: 50 + (_sparkleAnimation.value * 30),
              child: CrystalSparkle(
                size: 20,
                color: Colors.white.withOpacity(0.8),
              ),
            );
          },
        ),
        
        // Crystal icon/placeholder
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _getCrystalColor(_crystal!.color),
                  _getCrystalColor(_crystal!.color).withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _getCrystalColor(_crystal!.color).withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.diamond,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
        
        // Crystal name overlay
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _crystal!.name,
                  style: GoogleFonts.cinzel(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _crystal!.type,
                  style: GoogleFonts.crimsonText(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCrystalInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDescriptionSection(),
          const SizedBox(height: 24),
          _buildPropertiesSection(),
          const SizedBox(height: 24),
          _buildChakrasSection(),
          const SizedBox(height: 24),
          _buildGuidanceSection(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return FadeScaleIn(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getCrystalColor(_crystal!.color).withOpacity(0.3),
              _getCrystalColor(_crystal!.color).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _getCrystalColor(_crystal!.color).withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _crystal!.description,
              style: GoogleFonts.crimsonText(
                fontSize: 16,
                color: Colors.white,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesSection() {
    return FadeScaleIn(
      delay: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(0.3),
              Colors.indigo.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metaphysical Properties',
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _crystal!.properties.map((property) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple.withOpacity(0.5)),
                  ),
                  child: Text(
                    property,
                    style: GoogleFonts.cinzel(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChakrasSection() {
    return FadeScaleIn(
      delay: const Duration(milliseconds: 400),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(0.3),
              Colors.red.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chakra Associations',
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _crystal!.chakras.map((chakra) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getChakraColor(chakra).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getChakraColor(chakra)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: _getChakraColor(chakra),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        chakra,
                        style: GoogleFonts.cinzel(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceSection() {
    return FadeScaleIn(
      delay: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.3),
              Colors.cyan.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Use',
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getUsageGuidance(_crystal!.name),
              style: GoogleFonts.crimsonText(
                fontSize: 16,
                color: Colors.white,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return FadeScaleIn(
      delay: const Duration(milliseconds: 800),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: MysticalButton(
              text: _isInCollection ? 'Remove from Collection' : 'Add to Collection',
              icon: _isInCollection ? Icons.remove_circle : Icons.add_circle,
              onPressed: _toggleCollection,
              color: _isInCollection ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: MysticalButton(
              text: 'Get Personalized Guidance',
              icon: Icons.auto_awesome,
              onPressed: _getPersonalizedGuidance,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: MysticalButton(
              text: 'Share Crystal Knowledge',
              icon: Icons.share,
              onPressed: _shareGuidance,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
          SizedBox(height: 16),
          Text(
            'Loading crystal information...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Crystal not found',
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The requested crystal information could not be loaded.',
            style: GoogleFonts.crimsonText(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          MysticalButton(
            text: 'Go Back',
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Color _getCrystalColor(String color) {
    switch (color.toLowerCase()) {
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'clear':
      case 'white':
        return Colors.white;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  Color _getChakraColor(String chakra) {
    switch (chakra.toLowerCase()) {
      case 'root':
        return Colors.red;
      case 'sacral':
        return Colors.orange;
      case 'solar plexus':
        return Colors.yellow;
      case 'heart':
        return Colors.green;
      case 'throat':
        return Colors.blue;
      case 'third eye':
        return Colors.indigo;
      case 'crown':
        return Colors.purple;
      default:
        return Colors.white;
    }
  }

  String _getUsageGuidance(String crystalName) {
    switch (crystalName.toLowerCase()) {
      case 'amethyst':
        return 'Place under your pillow for peaceful sleep and enhanced dreams. Hold during meditation to deepen your spiritual connection. Wear as jewelry for ongoing protection from negative energies.';
      case 'rose quartz':
        return 'Keep near your heart or on your nightstand to attract love and heal emotional wounds. Use in self-love rituals and meditation practices. Gift to loved ones to strengthen relationships.';
      case 'clear quartz':
        return 'Use to amplify the energy of other crystals by placing them nearby. Program with your intentions through focused meditation. Create crystal grids for manifestation work.';
      default:
        return 'Meditate with this crystal to connect with its unique energy. Carry it with you throughout the day for ongoing support. Cleanse regularly under moonlight or with sage.';
    }
  }

  void _toggleCollection() {
    setState(() {
      _isInCollection = !_isInCollection;
    });
    
    final action = _isInCollection ? 'added to' : 'removed from';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_crystal!.name} $action your collection'),
        backgroundColor: _isInCollection ? Colors.green : Colors.orange,
      ),
    );
    
    // Update app state
    context.read<AppState>().incrementUsage('collection_update');
  }

  void _getPersonalizedGuidance() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.purple),
        ),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.purple),
            const SizedBox(width: 8),
            Text(
              'Personalized Guidance',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Based on your spiritual profile and current energy:',
              style: GoogleFonts.crimsonText(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '✨ ${_crystal!.name} resonates strongly with your current spiritual journey.\n\n🌙 Work with this crystal during the new moon for enhanced manifestation.\n\n💎 Combine with meditation and journaling for deeper insights.\n\n🔮 Your birth chart suggests this crystal will support your ${_getPersonalizedBenefit()}.',
              style: GoogleFonts.crimsonText(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.cinzel(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    
    // Update app state
    context.read<AppState>().incrementUsage('personalized_guidance');
  }

  String _getPersonalizedBenefit() {
    final benefits = [
      'emotional healing journey',
      'spiritual growth path',
      'intuitive development',
      'manifestation practices',
      'chakra balancing work',
    ];
    return benefits[DateTime.now().millisecond % benefits.length];
  }

  void _shareGuidance() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.blue),
        ),
        title: Text(
          'Share Crystal Knowledge',
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Share your experience with ${_crystal!.name} to help other crystal enthusiasts on their spiritual journey.',
          style: GoogleFonts.crimsonText(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.cinzel(
                color: Colors.white54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing feature coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Share',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}