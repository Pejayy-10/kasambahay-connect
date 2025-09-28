import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/housekeeper_provider.dart';
import '../../theme/casaligan_theme.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // AI Matchmaking state
  String? _selectedServiceType;
  String? _selectedFrequency;
  String? _selectedBudget;
  List<String> _selectedTiming = [];

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
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<HousekeeperProvider>(context, listen: false);
    await provider.loadHousekeepers();
    _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _cardAnimationController.forward();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: CasaliganTheme.surfaceContainer,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: CasaliganTheme.primary,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildModernAppBar(context),
            SliverToBoxAdapter(child: _buildNavigationSection()),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 20,
                vertical: 16,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildAIMatchmakingSection(context),
                  const SizedBox(height: 16),
                  _buildQuickActionsSection(context, isTablet),
                  const SizedBox(height: 20),
                  _buildPopularServicesSection(context),
                  const SizedBox(height: 24),
                  _buildTopRatedHousekeepersSection(context),
                  const SizedBox(height: 100), // Bottom padding for FAB
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildBookingFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      snap: false,
      elevation: 0,
      backgroundColor: CasaliganTheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double appBarHeight = constraints.biggest.height;
          final double expandRatio = ((appBarHeight - kToolbarHeight) / (120 - kToolbarHeight)).clamp(0.0, 1.0);
          
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CasaliganTheme.primary.withOpacity((0.1 * expandRatio).clamp(0.0, 1.0)),
                  CasaliganTheme.primaryLight.withOpacity((0.05 * expandRatio).clamp(0.0, 1.0)),
                ],
              ),
            ),
            child: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsets.only(
                left: 20, 
                bottom: 16 + (expandRatio * 8),
              ),
              title: Opacity(
                opacity: expandRatio.clamp(0.0, 1.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, Sarah! 👋',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: CasaliganTheme.neutral900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (expandRatio > 0.5)
                      Text(
                        'Ready for a clean home?',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CasaliganTheme.neutral600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/profile');
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: CasaliganTheme.primary.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CasaliganTheme.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CasaliganTheme.primary.withOpacity(0.1),
                          CasaliganTheme.primary.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: CasaliganTheme.primary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(
            icon: Icons.work_outline,
            label: 'My Jobs',
            onTap: () => Navigator.pushNamed(context, '/my-jobs'),
            hasNotification: false,
          ),
          _buildNavButton(
            icon: Icons.chat_outlined,
            label: 'Messages',
            onTap: () => Navigator.pushNamed(context, '/messages'),
            hasNotification: true,
            notificationCount: 2,
          ),
          _buildNavButton(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => Navigator.pushNamed(context, '/notifications'),
            hasNotification: true,
          ),
          _buildNavButton(
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: () => Navigator.pushNamed(context, '/profile'),
            hasNotification: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool hasNotification = false,
    int? notificationCount,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CasaliganTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: CasaliganTheme.primary,
                    size: 24,
                  ),
                ),
                if (hasNotification)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CasaliganTheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: notificationCount != null
                          ? Text(
                              '$notificationCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const SizedBox(width: 6, height: 6),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CasaliganTheme.neutral700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIMatchmakingSection(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CasaliganTheme.primary.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CasaliganTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: CasaliganTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Matching',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: CasaliganTheme.neutral900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Find your perfect housekeeper',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CasaliganTheme.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Get personalized recommendations based on your preferences, budget, and location.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CasaliganTheme.neutral700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _startAIMatchmaking();
                },
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Start Matching'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CasaliganTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, bool isTablet) {
    final quickActions = [
      {
        'icon': Icons.home_filled,
        'title': 'Deep Clean',
        'subtitle': 'Complete home cleaning',
        'color': CasaliganTheme.secondary,
      },
      {
        'icon': Icons.refresh,
        'title': 'Regular Clean',
        'subtitle': 'Weekly maintenance',
        'color': CasaliganTheme.accent,
      },
      {
        'icon': Icons.window,
        'title': 'Window Clean',
        'subtitle': 'Crystal clear windows',
        'color': CasaliganTheme.success,
      },
      {
        'icon': Icons.local_laundry_service,
        'title': 'Laundry',
        'subtitle': 'Wash & fold service',
        'color': CasaliganTheme.warning,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ScaleTransition(
          scale: _scaleAnimation,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 4 : 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: quickActions.length,
            itemBuilder: (context, index) {
              final action = quickActions[index];
              return _buildQuickActionCard(context, action, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, Map<String, dynamic> action, int index) {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        final delay = index * 0.1;
        final animationValue = Curves.elasticOut.transform(
          (_cardAnimationController.value - delay).clamp(0.0, 1.0),
        ).clamp(0.0, 1.0);
        
        return Transform.scale(
          scale: animationValue,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (action['color'] as Color).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pushNamed(context, '/housekeeper-selection');
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (action['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        action['title'] as String,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Flexible(
                        child: Text(
                          action['subtitle'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: CasaliganTheme.neutral500,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularServicesSection(BuildContext context) {
    final services = [
      {
        'name': 'Deep Cleaning',
        'price': '₱3,000',
        'duration': '3-4 hours',
        'rating': 4.9,
        'icon': Icons.home_filled,
        'color': CasaliganTheme.secondary,
        'discount': '20% OFF',
      },
      {
        'name': 'Regular Cleaning',
        'price': '₱2,000',
        'duration': '2-3 hours',
        'rating': 4.8,
        'icon': Icons.cleaning_services,
        'color': CasaliganTheme.accent,
        'discount': null,
      },
      {
        'name': 'Move-in Cleaning',
        'price': '₱5,000',
        'duration': '5-6 hours',
        'rating': 5.0,
        'icon': Icons.moving,
        'color': CasaliganTheme.primary,
        'discount': '15% OFF',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Services',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => HapticFeedback.lightImpact(),
                child: Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return _buildServiceCard(context, services[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service, int index) {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        final delay = index * 0.15;
        final animationValue = Curves.easeOutBack.transform(
          (_cardAnimationController.value - delay).clamp(0.0, 1.0),
        ).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(50 * (1 - animationValue), 0),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: CasaliganTheme.neutral200.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => HapticFeedback.mediumImpact(),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (service['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                service['icon'] as IconData,
                                color: service['color'] as Color,
                                size: 24,
                              ),
                            ),
                            const Spacer(),
                            if (service['discount'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: CasaliganTheme.error,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  service['discount'],
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          service['name'],
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          service['duration'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: CasaliganTheme.neutral500,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              service['price'],
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: CasaliganTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: CasaliganTheme.warning,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  service['rating'].toString(),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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

  Widget _buildTopRatedHousekeepersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top-Rated Housekeepers',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/housekeeper-selection');
                },
                child: Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Consumer<HousekeeperProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return _buildHousekeepersSkeletonLoader();
            }

            final topHousekeepers = provider.housekeepers.take(3).toList();
            
            return Column(
              children: topHousekeepers.asMap().entries.map((entry) {
                final index = entry.key;
                final housekeeper = entry.value;
                return _buildHousekeeperCard(context, housekeeper, index);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHousekeeperCard(BuildContext context, dynamic housekeeper, int index) {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        final delay = index * 0.1;
        final animationValue = Curves.easeOutCubic.transform(
          (_cardAnimationController.value - delay).clamp(0.0, 1.0),
        ).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pushNamed(
                  context,
                  '/housekeeper-detail',
                  arguments: {'housekeeper': housekeeper},
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: CasaliganTheme.neutral200.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          housekeeper.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${housekeeper.yearsOfExperience} years experience',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: CasaliganTheme.neutral500,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₱${housekeeper.baseHourlyRate.toStringAsFixed(0)}/hr',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: CasaliganTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pushNamed(
                        context,
                        '/housekeeper-detail',
                        arguments: {'housekeeper': housekeeper},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CasaliganTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Book'),
                  ),
                ],
              ),
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHousekeepersSkeletonLoader() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
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
                height: 36,
                width: 60,
                decoration: BoxDecoration(
                  color: CasaliganTheme.neutral200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBookingFAB(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.heavyImpact();
          Navigator.pushNamed(context, '/housekeeper-selection');
        },
        backgroundColor: CasaliganTheme.primary,
        elevation: 8,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  /// Show AI Matchmaking modal
  void _startAIMatchmaking() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIMatchmakingModal(
        selectedServiceType: _selectedServiceType,
        selectedFrequency: _selectedFrequency,
        selectedBudget: _selectedBudget,
        selectedTiming: _selectedTiming,
        onServiceTypeChanged: (value) => setState(() => _selectedServiceType = value),
        onFrequencyChanged: (value) => setState(() => _selectedFrequency = value),
        onBudgetChanged: (value) => setState(() => _selectedBudget = value),
        onTimingChanged: (values) => setState(() => _selectedTiming = values),
        onComplete: () {
          Navigator.pop(context);
          _processAIMatchmaking();
        },
      ),
    );
  }

  void _processAIMatchmaking() {
    // Simulate AI processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Finding perfect matches...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );

    // After 2 seconds, show results
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      Navigator.pushNamed(
        context,
        '/housekeeper-selection',
        arguments: {'aiMatched': true},
      );
    });
  }
}

// Separate StatefulWidget for AI Matchmaking Modal
class AIMatchmakingModal extends StatefulWidget {
  final String? selectedServiceType;
  final String? selectedFrequency;
  final String? selectedBudget;
  final List<String> selectedTiming;
  final Function(String) onServiceTypeChanged;
  final Function(String) onFrequencyChanged;
  final Function(String) onBudgetChanged;
  final Function(List<String>) onTimingChanged;
  final VoidCallback onComplete;

  const AIMatchmakingModal({
    Key? key,
    this.selectedServiceType,
    this.selectedFrequency,
    this.selectedBudget,
    required this.selectedTiming,
    required this.onServiceTypeChanged,
    required this.onFrequencyChanged,
    required this.onBudgetChanged,
    required this.onTimingChanged,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<AIMatchmakingModal> createState() => _AIMatchmakingModalState();
}

class _AIMatchmakingModalState extends State<AIMatchmakingModal> {
  late String? _localServiceType;
  late String? _localFrequency;
  late String? _localBudget;
  late List<String> _localTiming;

  @override
  void initState() {
    super.initState();
    _localServiceType = widget.selectedServiceType;
    _localFrequency = widget.selectedFrequency;
    _localBudget = widget.selectedBudget;
    _localTiming = List.from(widget.selectedTiming);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CasaliganTheme.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CasaliganTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: CasaliganTheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Matchmaking',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Answer a few questions to get personalized recommendations',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: CasaliganTheme.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Preference Questions
              _buildSingleChoiceQuestion(
                'What type of cleaning service do you need?',
                ['Regular House Cleaning', 'Deep Cleaning', 'Move-in/Move-out', 'Office Cleaning'],
                _localServiceType,
                (value) {
                  setState(() => _localServiceType = value);
                  widget.onServiceTypeChanged(value);
                },
              ),
              const SizedBox(height: 24),
              
              _buildSingleChoiceQuestion(
                'How often do you need cleaning?',
                ['One-time', 'Weekly', 'Bi-weekly', 'Monthly'],
                _localFrequency,
                (value) {
                  setState(() => _localFrequency = value);
                  widget.onFrequencyChanged(value);
                },
              ),
              const SizedBox(height: 24),
              
              _buildSingleChoiceQuestion(
                'What\'s your preferred budget range?',
                ['₱500-1000', '₱1000-2000', '₱2000-3000', '₱3000+'],
                _localBudget,
                (value) {
                  setState(() => _localBudget = value);
                  widget.onBudgetChanged(value);
                },
              ),
              const SizedBox(height: 24),
              
              _buildMultiChoiceQuestion(
                'Preferred time of service? (Select all that work)',
                ['Morning (8AM-12PM)', 'Afternoon (12PM-5PM)', 'Evening (5PM-8PM)', 'Flexible'],
                _localTiming,
                (values) {
                  setState(() => _localTiming = values);
                  widget.onTimingChanged(values);
                },
              ),
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: CasaliganTheme.neutral300),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: CasaliganTheme.neutral700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CasaliganTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Find Matches',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildSingleChoiceQuestion(String question, List<String> options, String? selectedValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: CasaliganTheme.neutral800,
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
              onSelected: (selected) {
                if (selected) {
                  HapticFeedback.selectionClick();
                  onChanged(option);
                }
              },
              selectedColor: CasaliganTheme.primary.withOpacity(0.2),
              checkmarkColor: CasaliganTheme.primary,
              side: BorderSide(
                color: isSelected ? CasaliganTheme.primary : CasaliganTheme.neutral300,
              ),
              labelStyle: TextStyle(
                color: isSelected ? CasaliganTheme.primary : CasaliganTheme.neutral700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultiChoiceQuestion(String question, List<String> options, List<String> selectedValues, Function(List<String>) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: CasaliganTheme.neutral800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                HapticFeedback.selectionClick();
                List<String> newValues = List.from(selectedValues);
                if (selected) {
                  newValues.add(option);
                } else {
                  newValues.remove(option);
                }
                onChanged(newValues);
              },
              selectedColor: CasaliganTheme.primary.withOpacity(0.2),
              checkmarkColor: CasaliganTheme.primary,
              side: BorderSide(
                color: isSelected ? CasaliganTheme.primary : CasaliganTheme.neutral300,
              ),
              labelStyle: TextStyle(
                color: isSelected ? CasaliganTheme.primary : CasaliganTheme.neutral700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}