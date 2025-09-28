import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/casaligan_theme.dart';
import '../../models/housekeeper.dart';

/// Detailed view of a housekeeper profile with booking options
class HousekeeperDetailScreen extends StatefulWidget {
  final Housekeeper housekeeper;

  const HousekeeperDetailScreen({
    super.key,
    required this.housekeeper,
  });

  @override
  State<HousekeeperDetailScreen> createState() => _HousekeeperDetailScreenState();
}

class _HousekeeperDetailScreenState extends State<HousekeeperDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabAnimation;
  
  bool _showFullDescription = false;
  String _selectedService = '';
  
  final List<String> _availableTimes = [
    '9:00 AM', '10:00 AM', '11:00 AM', '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM'
  ];
  
  String _selectedTime = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fabAnimationController = AnimationController(
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
    
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _fabAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      backgroundColor: CasaliganTheme.surfaceContainer,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 20,
              vertical: 16,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProfileHeader(context),
                const SizedBox(height: 24),
                _buildStatsSection(context),
                const SizedBox(height: 24),
                _buildAboutSection(context),
                const SizedBox(height: 24),
                _buildServicesSection(context),
                const SizedBox(height: 24),
                _buildReviewsSection(context),
                const SizedBox(height: 24),
                _buildAvailabilitySection(context),
                const SizedBox(height: 100), // Space for FAB
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildBookingFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: CasaliganTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CasaliganTheme.primary,
                CasaliganTheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Profile Image
              Center(
                child: Hero(
                  tag: 'housekeeper-${widget.housekeeper.id}',
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 75,
                      backgroundColor: CasaliganTheme.surfaceContainer,
                      child: Text(
                        widget.housekeeper.name.split(' ').map((n) => n[0]).take(2).join(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: CasaliganTheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Availability Badge
              Positioned(
                top: 80,
                right: 50,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.housekeeper.isAvailable ? CasaliganTheme.success : CasaliganTheme.warning,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.housekeeper.isAvailable ? 'Available' : 'Busy',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // Toggle favorite
          },
          icon: const Icon(Icons.favorite_border, color: Colors.white),
        ),
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // Share profile
          },
          icon: const Icon(Icons.share, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Text(
              widget.housekeeper.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: CasaliganTheme.neutral500,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.housekeeper.location,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CasaliganTheme.neutral500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: CasaliganTheme.warning,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.housekeeper.rating.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${widget.housekeeper.reviewCount} reviews)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CasaliganTheme.neutral500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final stats = [
      {
        'title': 'Experience',
        'value': '${widget.housekeeper.yearsOfExperience}+ years',
        'icon': Icons.work_outline,
      },
      {
        'title': 'Base Rate',
        'value': '₱${widget.housekeeper.baseHourlyRate}/hr',
        'icon': Icons.attach_money,
      },
      {
        'title': 'Completed Jobs',
        'value': '${widget.housekeeper.reviewCount * 2}+',
        'icon': Icons.check_circle_outline,
      },
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: stats.map((stat) {
          final index = stats.indexOf(stat);
          return Expanded(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final delay = index * 0.1;
                final animationValue = Curves.easeOutCubic.transform(
                  (_animationController.value - delay).clamp(0.0, 1.0),
                ).clamp(0.0, 1.0);
                
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: Container(
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 8,
                        right: index == stats.length - 1 ? 0 : 8,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            stat['icon'] as IconData,
                            color: CasaliganTheme.primary,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stat['value'] as String,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stat['title'] as String,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: CasaliganTheme.neutral500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    const description = "Professional housekeeper with over 5 years of experience providing top-quality cleaning services. I specialize in deep cleaning, organization, and maintaining pristine living spaces. My attention to detail and commitment to excellence ensures your home will be spotless and welcoming.";
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Me',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _showFullDescription ? description : description.substring(0, 120) + "...",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: CasaliganTheme.neutral600,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _showFullDescription = !_showFullDescription;
                });
              },
              child: Text(_showFullDescription ? 'Show Less' : 'Read More'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services & Specialties',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.housekeeper.specialties.map((specialty) {
                final isSelected = _selectedService == specialty;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedService = isSelected ? '' : specialty;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? CasaliganTheme.primary : CasaliganTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? CasaliganTheme.primary : CasaliganTheme.neutral300,
                      ),
                    ),
                    child: Text(
                      specialty,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : CasaliganTheme.neutral600,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
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

  Widget _buildReviewsSection(BuildContext context) {
    final reviews = [
      {
        'name': 'Sarah Johnson',
        'rating': 5.0,
        'date': '2 weeks ago',
        'comment': 'Excellent service! Very thorough and professional.',
      },
      {
        'name': 'Mike Chen',
        'rating': 4.8,
        'date': '1 month ago',
        'comment': 'Great attention to detail. Highly recommend!',
      },
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Reviews',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // Show all reviews
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...reviews.map((review) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: CasaliganTheme.surfaceContainer,
                          child: Text(
                            (review['name'] as String)[0],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['name'] as String,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < (review['rating'] as double).floor()
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        color: CasaliganTheme.warning,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    review['date'] as String,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: CasaliganTheme.neutral500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review['comment'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CasaliganTheme.neutral600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Today',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTimes.map((time) {
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedTime = isSelected ? '' : time;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? CasaliganTheme.primary : CasaliganTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? CasaliganTheme.primary : CasaliganTheme.neutral300,
                      ),
                    ),
                    child: Text(
                      time,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : CasaliganTheme.neutral600,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
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

  Widget _buildBookingFab(BuildContext context) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.heavyImpact();
            Navigator.pushNamed(
              context,
              '/booking',
              arguments: {
                'housekeeper': widget.housekeeper,
                'selectedService': _selectedService.isEmpty ? 'Deep Cleaning' : _selectedService,
                'selectedTime': _selectedTime.isEmpty ? '10:00 AM' : _selectedTime,
              },
            );
          },
          backgroundColor: CasaliganTheme.primary,
          elevation: 8,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Book Now - ₱${widget.housekeeper.baseHourlyRate}/hr',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}