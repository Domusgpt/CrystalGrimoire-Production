import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/crystal.dart';
import '../widgets/animations/mystical_animations.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/common/mystical_card.dart';
import '../widgets/common/mystical_text_widgets.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({Key? key}) : super(key: key);

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _filterController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _filterAnimation;
  
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _isGridView = true;
  
  final List<String> _filters = [
    'all',
    'favorites',
    'healing',
    'protection',
    'meditation',
    'energy',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _filterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filterController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeController.forward();
    _filterController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _filterController.dispose();
    super.dispose();
  }
  
  List<Crystal> _getFilteredCrystals(List<Crystal> crystals) {
    var filtered = crystals;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((crystal) =>
        crystal.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        crystal.group.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Apply category filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((crystal) {
        switch (_selectedFilter) {
          case 'favorites':
            return crystal.properties['isFavorite'] == true;
          case 'healing':
            return (crystal.properties['healing'] as List?)?.isNotEmpty ?? false;
          case 'protection':
            return crystal.properties['protection'] == true;
          case 'meditation':
            return crystal.properties['meditation'] == true;
          case 'energy':
            return crystal.properties['energy'] != null;
          default:
            return true;
        }
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final userCrystals = appState.userCrystals;
    final filteredCrystals = _getFilteredCrystals(userCrystals);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.background,
                  theme.colorScheme.background.withBlue(30),
                ],
              ),
            ),
          ),
          
          // Floating particles
          const FloatingParticles(
            particleCount: 10,
            color: Colors.purpleAccent,
          ),
          
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        MysticalIconButton(
                          icon: Icons.arrow_back,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ShimmeringText(
                            text: 'My Collection',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        MysticalIconButton(
                          icon: _isGridView ? Icons.list : Icons.grid_view,
                          onPressed: () {
                            setState(() => _isGridView = !_isGridView);
                            HapticFeedback.selectionClick();
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FadeScaleIn(
                      delay: const Duration(milliseconds: 200),
                      child: MysticalCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextField(
                          onChanged: (value) => setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'Search crystals...',
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.search,
                              color: theme.colorScheme.primary,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Filter chips
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isSelected = _selectedFilter == filter;
                        
                        return FadeScaleIn(
                          delay: Duration(milliseconds: 300 + (index * 50)),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(_getFilterLabel(filter)),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() => _selectedFilter = selected ? filter : 'all');
                                HapticFeedback.selectionClick();
                              },
                              backgroundColor: theme.colorScheme.surface,
                              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                              checkmarkColor: theme.colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Collection stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: FadeScaleIn(
                      delay: const Duration(milliseconds: 400),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filteredCrystals.length} crystals',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                          if (userCrystals.isNotEmpty)
                            Text(
                              '${_getTotalValue(userCrystals)} total value',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Crystal grid/list
                  Expanded(
                    child: filteredCrystals.isEmpty
                        ? _buildEmptyState(theme)
                        : _isGridView
                            ? _buildGridView(filteredCrystals)
                            : _buildListView(filteredCrystals),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // FAB for adding crystals
      floatingActionButton: FadeScaleIn(
        delay: const Duration(milliseconds: 800),
        child: CrystalFAB(
          icon: Icons.add,
          onPressed: () {
            // TODO: Navigate to identify screen
          },
          tooltip: 'Add Crystal',
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: FadeScaleIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.diamond_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No crystals found'
                  : 'Your collection awaits',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search'
                  : 'Start by identifying your first crystal',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.4),
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 24),
              MysticalButton(
                onPressed: () {
                  // TODO: Navigate to identify screen
                },
                text: 'Identify Crystal',
                icon: Icons.camera_alt,
                color: Colors.purple,
                width: double.infinity,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildGridView(List<Crystal> crystals) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: crystals.length,
      itemBuilder: (context, index) {
        final crystal = crystals[index];
        return FadeScaleIn(
          delay: Duration(milliseconds: 500 + (index * 50)),
          child: _CrystalGridItem(
            crystal: crystal,
            onTap: () => _openCrystalDetail(crystal),
          ),
        );
      },
    );
  }
  
  Widget _buildListView(List<Crystal> crystals) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: crystals.length,
      itemBuilder: (context, index) {
        final crystal = crystals[index];
        return FadeScaleIn(
          delay: Duration(milliseconds: 500 + (index * 50)),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: CrystalInfoCard(
              crystalName: crystal.name,
              subtitle: crystal.group,
              properties: [
                if (crystal.chakras.isNotEmpty) crystal.chakras.first,
                if (crystal.elements.isNotEmpty) crystal.elements.first,
                if (crystal.properties['energy'] != null) 
                  crystal.properties['energy'] as String,
              ],
              onTap: () => _openCrystalDetail(crystal),
              trailing: crystal.properties['isFavorite'] == true
                  ? Icon(Icons.favorite, color: Colors.red, size: 20)
                  : null,
            ),
          ),
        );
      },
    );
  }
  
  void _openCrystalDetail(Crystal crystal) {
    // TODO: Navigate to crystal detail screen
    HapticFeedback.mediumImpact();
  }
  
  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all': return 'All';
      case 'favorites': return '❤️ Favorites';
      case 'healing': return '💚 Healing';
      case 'protection': return '🛡️ Protection';
      case 'meditation': return '🧘 Meditation';
      case 'energy': return '⚡ Energy';
      default: return filter;
    }
  }
  
  String _getTotalValue(List<Crystal> crystals) {
    // This would calculate based on crystal rarity, size, etc.
    return '${crystals.length * 25} pts';
  }
}

/// Grid item widget for crystal collection
class _CrystalGridItem extends StatelessWidget {
  final Crystal crystal;
  final VoidCallback onTap;

  const _CrystalGridItem({
    required this.crystal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFavorite = crystal.properties['isFavorite'] == true;
    
    return MysticalCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Crystal image
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.3),
                        theme.colorScheme.secondary.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.diamond,
                      size: 60,
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                ),
                
                // Favorite indicator
                if (isFavorite)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Crystal info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crystal.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  crystal.group,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (crystal.chakras.isNotEmpty)
                      _MiniChip(
                        label: crystal.chakras.first,
                        color: theme.colorScheme.primary,
                      ),
                    const Spacer(),
                    if (crystal.elements.isNotEmpty)
                      Icon(
                        _getElementIcon(crystal.elements.first),
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getElementIcon(String element) {
    switch (element.toLowerCase()) {
      case 'fire': return Icons.local_fire_department;
      case 'water': return Icons.water_drop;
      case 'earth': return Icons.terrain;
      case 'air': return Icons.air;
      case 'spirit': return Icons.auto_awesome;
      default: return Icons.circle;
    }
  }
}

/// Mini chip widget
class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}