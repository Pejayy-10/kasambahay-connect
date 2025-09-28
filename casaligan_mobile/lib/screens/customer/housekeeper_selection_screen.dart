import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/housekeeper_provider.dart';
import '../../theme/casaligan_theme.dart';

class HousekeeperSelectionScreen extends StatefulWidget {
  const HousekeeperSelectionScreen({Key? key}) : super(key: key);

  @override
  State<HousekeeperSelectionScreen> createState() => _HousekeeperSelectionScreenState();
}

class _HousekeeperSelectionScreenState extends State<HousekeeperSelectionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  String _selectedRating = 'All';
  String _selectedPriceRange = 'All';
  String _selectedLocation = 'All';
  List<String> _selectedServices = [];

  final List<String> _ratings = ['All', '4+ Stars', '4.5+ Stars', '5 Stars'];
  final List<String> _priceRanges = ['All', '\$20-40', '\$40-60', '\$60-80', '\$80+'];
  final List<String> _locations = ['All', 'Downtown', 'Uptown', 'Midtown', 'Suburbs'];
  final List<String> _services = ['Deep Cleaning', 'Regular Cleaning', 'Window Cleaning', 'Laundry', 'Organization'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Use post frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _filterAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<HousekeeperProvider>(context, listen: false);
    await provider.loadHousekeepers();
    _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _filterAnimationController.forward();
  }

  void _performSearch() {
    final provider = Provider.of<HousekeeperProvider>(context, listen: false);
    provider.searchAndFilter(
      nameQuery: _searchController.text,
      minRating: _getMinRatingFromSelection(_selectedRating),
      location: _selectedLocation != 'All' ? _selectedLocation : null,
      specialty: _selectedServices.isNotEmpty ? _selectedServices.first : null,
    );
  }

  double _getMinRatingFromSelection(String ratingFilter) {
    switch (ratingFilter) {
      case '4+ Stars':
        return 4.0;
      case '4.5+ Stars':
        return 4.5;
      case '5 Stars':
        return 5.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasaliganTheme.surfaceContainer,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSearchSection(context),
                const SizedBox(height: 20),
                _buildFilterSection(context),
                const SizedBox(height: 24),
                _buildResultsSection(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CasaliganTheme.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: CasaliganTheme.primary,
          ),
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CasaliganTheme.primary.withOpacity(0.1),
              CasaliganTheme.accent.withOpacity(0.05),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          centerTitle: true,
          titlePadding: const EdgeInsets.only(bottom: 16),
          title: FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Find Housekeepers',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: CasaliganTheme.neutral900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CasaliganTheme.primary.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _performSearch(),
            decoration: InputDecoration(
              hintText: 'Search housekeepers...',
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CasaliganTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: CasaliganTheme.primary,
                  size: 20,
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _searchController.clear();
                        _performSearch();
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: CasaliganTheme.neutral500,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CasaliganTheme.neutral400,
              ),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _showFilterSheet,
                icon: Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: CasaliganTheme.primary,
                ),
                label: Text('Customize'),
                style: TextButton.styleFrom(
                  foregroundColor: CasaliganTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip('Rating: $_selectedRating', _selectedRating != 'All'),
                _buildFilterChip('Price: $_selectedPriceRange', _selectedPriceRange != 'All'),
                _buildFilterChip('Location: $_selectedLocation', _selectedLocation != 'All'),
                if (_selectedServices.isNotEmpty)
                  _buildFilterChip('Services: ${_selectedServices.length}', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : CasaliganTheme.neutral600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        backgroundColor: Colors.white,
        selectedColor: CasaliganTheme.primary,
        checkmarkColor: Colors.white,
        elevation: isSelected ? 4 : 2,
        shadowColor: CasaliganTheme.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? CasaliganTheme.primary : CasaliganTheme.neutral300,
          ),
        ),
        onSelected: (_) => _showFilterSheet(),
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context) {
    return Consumer<HousekeeperProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildSkeletonLoader();
        }

        final housekeepers = provider.filteredHousekeepers;

        if (housekeepers.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                '${housekeepers.length} housekeepers found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: CasaliganTheme.neutral600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...housekeepers.asMap().entries.map((entry) {
              final index = entry.key;
              final housekeeper = entry.value;
              return _buildHousekeeperCard(context, housekeeper, index);
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildHousekeeperCard(BuildContext context, dynamic housekeeper, int index) {
    return AnimatedBuilder(
      animation: _filterAnimationController,
      builder: (context, child) {
        final delay = index * 0.1;
        final animationValue = Curves.easeOutBack.transform(
          (_filterAnimationController.value - delay).clamp(0.0, 1.0),
        ).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, 50 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: CasaliganTheme.primary.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pushNamed(
                      context,
                      '/housekeeper-detail',
                      arguments: {'housekeeper': housekeeper},
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: CasaliganTheme.primary.withOpacity(0.1),
                                  child: Text(
                                    housekeeper.name.split(' ').map((n) => n[0]).join(''),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: CasaliganTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: CasaliganTheme.success,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        housekeeper.name,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: CasaliganTheme.success.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Available',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: CasaliganTheme.success,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: CasaliganTheme.warning,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        housekeeper.rating.toString(),
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        ' • ${housekeeper.yearsOfExperience} years',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: CasaliganTheme.neutral500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${housekeeper.baseHourlyRate.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: CasaliganTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'per hour',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: CasaliganTheme.neutral500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Specializes in: ${housekeeper.specialties.take(3).join(', ')}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: CasaliganTheme.neutral600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => HapticFeedback.lightImpact(),
                                icon: Icon(Icons.message_outlined, size: 18),
                                label: Text('Message'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  Navigator.pushNamed(
                                    context,
                                    '/housekeeper-detail',
                                    arguments: {'housekeeper': housekeeper},
                                  );
                                },
                                icon: Icon(Icons.calendar_today_outlined, size: 18),
                                label: Text('Book Now'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CasaliganTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: CasaliganTheme.neutral200,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: 120,
                          decoration: BoxDecoration(
                            color: CasaliganTheme.neutral200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 80,
                          decoration: BoxDecoration(
                            color: CasaliganTheme.neutral200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 16,
                    width: 60,
                    decoration: BoxDecoration(
                      color: CasaliganTheme.neutral200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: CasaliganTheme.neutral200,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: CasaliganTheme.neutral200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: CasaliganTheme.neutral200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CasaliganTheme.neutral100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: CasaliganTheme.neutral400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No housekeepers found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CasaliganTheme.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _clearFilters,
              child: Text('Clear All Filters'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return StatefulBuilder(
      builder: (context, setStateModal) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CasaliganTheme.surfaceContainerHigh,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Options',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterOptionSection('Rating', _ratings, _selectedRating, (value) {
                        setStateModal(() => _selectedRating = value);
                      }),
                      const SizedBox(height: 24),
                      _buildFilterOptionSection('Price Range', _priceRanges, _selectedPriceRange, (value) {
                        setStateModal(() => _selectedPriceRange = value);
                      }),
                      const SizedBox(height: 24),
                      _buildFilterOptionSection('Location', _locations, _selectedLocation, (value) {
                        setStateModal(() => _selectedLocation = value);
                      }),
                      const SizedBox(height: 24),
                      _buildServiceFilters(setStateModal),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: CasaliganTheme.neutral200,
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearFilters,
                        child: Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _performSearch();
                        },
                        child: Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOptionSection(String title, List<String> options, String selectedValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onChanged(option),
              selectedColor: CasaliganTheme.primary.withOpacity(0.2),
              checkmarkColor: CasaliganTheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceFilters(StateSetter setStateModal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _services.map((service) {
            final isSelected = _selectedServices.contains(service);
            return FilterChip(
              label: Text(service),
              selected: isSelected,
              onSelected: (selected) {
                setStateModal(() {
                  if (selected) {
                    _selectedServices.add(service);
                  } else {
                    _selectedServices.remove(service);
                  }
                });
              },
              selectedColor: CasaliganTheme.primary.withOpacity(0.2),
              checkmarkColor: CasaliganTheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedRating = 'All';
      _selectedPriceRange = 'All';
      _selectedLocation = 'All';
      _selectedServices.clear();
      _searchController.clear();
    });
    _performSearch();
  }
}