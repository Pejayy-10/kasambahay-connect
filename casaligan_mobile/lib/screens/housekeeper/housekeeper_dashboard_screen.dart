import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/casaligan_theme.dart';

/// Housekeeper dashboard screen for managing bookings, applications, and earnings
class HousekeeperDashboardScreen extends StatefulWidget {
  const HousekeeperDashboardScreen({super.key});

  @override
  State<HousekeeperDashboardScreen> createState() => _HousekeeperDashboardScreenState();
}

class _HousekeeperDashboardScreenState extends State<HousekeeperDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  int _selectedIndex = 0;
  
  // Mock data
  final double _todayEarnings = 3500.0;
  final double _weeklyEarnings = 18750.0;
  final int _completedJobs = 127;
  final double _rating = 4.9;
  final int _activeBookings = 3;

  final List<BookingItem> _upcomingBookings = [
    BookingItem(
      id: '1',
      clientName: 'Maria Santos',
      service: 'Deep House Cleaning',
      date: DateTime.now().add(const Duration(hours: 2)),
      duration: '3 hours',
      payment: 4500.0,
      location: 'Makati City',
      status: 'confirmed',
    ),
    BookingItem(
      id: '2',
      clientName: 'John Rodriguez',
      service: 'Regular Cleaning',
      date: DateTime.now().add(const Duration(days: 1)),
      duration: '2 hours',
      payment: 2000.0,
      location: 'BGC, Taguig',
      status: 'confirmed',
    ),
    BookingItem(
      id: '3',
      clientName: 'Sarah Chen',
      service: 'Move-in Cleaning',
      date: DateTime.now().add(const Duration(days: 3)),
      duration: '4 hours',
      payment: 5500.0,
      location: 'Quezon City',
      status: 'pending',
    ),
  ];

  final List<ApplicationItem> _jobApplications = [
    ApplicationItem(
      jobTitle: 'Weekly Office Cleaning',
      clientName: 'ABC Corporation',
      budget: 8000.0,
      location: 'Ortigas Center',
      applicationDate: DateTime.now().subtract(const Duration(hours: 1)),
      status: 'pending',
    ),
    ApplicationItem(
      jobTitle: 'Post-Party Cleaning',
      clientName: 'Mike Johnson',
      budget: 3500.0,
      location: 'Alabang',
      applicationDate: DateTime.now().subtract(const Duration(hours: 3)),
      status: 'shortlisted',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      backgroundColor: CasaliganTheme.surfaceContainer,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value.clamp(0.0, 1.0),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: _buildAppBarContent(),
                    expandedHeight: 180,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 20,
                      vertical: 16,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildStatsCards(),
                        const SizedBox(height: 24),
                        _buildTabSection(),
                        const SizedBox(height: 24),
                        _buildContentSection(),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildAppBarContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CasaliganTheme.primary, CasaliganTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: const NetworkImage(
                      'https://images.unsplash.com/photo-1494790108755-2616b9c75e0a',
                    ),
                    onBackgroundImageError: (_, __) {},
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Ana Rodriguez',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Handle notifications
                    },
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: CasaliganTheme.error,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                            child: const Text(
                              '2',
                              style: TextStyle(color: Colors.white, fontSize: 8),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$_rating',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Text(
                    '$_completedJobs jobs completed',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
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

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Today',
            '₱${_todayEarnings.toStringAsFixed(0)}',
            'Earnings',
            Icons.today,
            CasaliganTheme.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'This Week',
            '₱${_weeklyEarnings.toStringAsFixed(0)}',
            'Earnings',
            Icons.calendar_view_week,
            CasaliganTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Active',
            '$_activeBookings',
            'Bookings',
            Icons.work_outline,
            CasaliganTheme.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String period, String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                period,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CasaliganTheme.neutral500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: CasaliganTheme.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: CasaliganTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Bookings', 0),
                ),
                Expanded(
                  child: _buildTabButton('Applications', 1),
                ),
                Expanded(
                  child: _buildTabButton('Jobs', 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? CasaliganTheme.primary : CasaliganTheme.neutral500,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    switch (_selectedIndex) {
      case 0:
        return _buildBookingsTab();
      case 1:
        return _buildApplicationsTab();
      case 2:
        return _buildJobsTab();
      default:
        return _buildBookingsTab();
    }
  }

  Widget _buildBookingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Bookings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._upcomingBookings.map((booking) => _buildBookingCard(booking)).toList(),
      ],
    );
  }

  Widget _buildBookingCard(BookingItem booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.clientName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      booking.service,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CasaliganTheme.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: booking.status == 'confirmed' 
                      ? CasaliganTheme.success.withOpacity(0.1)
                      : CasaliganTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    color: booking.status == 'confirmed' 
                        ? CasaliganTheme.success 
                        : CasaliganTheme.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: CasaliganTheme.neutral500),
              const SizedBox(width: 8),
              Text(
                _formatBookingDate(booking.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CasaliganTheme.neutral600,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.timer, size: 16, color: CasaliganTheme.neutral500),
              const SizedBox(width: 8),
              Text(
                booking.duration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CasaliganTheme.neutral600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: CasaliganTheme.neutral500),
              const SizedBox(width: 8),
              Text(
                booking.location,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CasaliganTheme.neutral600,
                ),
              ),
              const Spacer(),
              Text(
                '₱${booking.payment.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: CasaliganTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showBookingDetails(booking);
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: CasaliganTheme.primary),
                    foregroundColor: CasaliganTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(
                      context, 
                      '/chat',
                      arguments: {
                        'housekeeper': {'name': 'Ana Rodriguez'},
                        'booking': booking,
                      },
                    );
                  },
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text(
                    'Chat',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CasaliganTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Applications',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._jobApplications.map((application) => _buildApplicationCard(application)).toList(),
      ],
    );
  }

  Widget _buildApplicationCard(ApplicationItem application) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.jobTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      application.clientName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CasaliganTheme.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: application.status == 'shortlisted' 
                      ? CasaliganTheme.success.withOpacity(0.1)
                      : CasaliganTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  application.status.toUpperCase(),
                  style: TextStyle(
                    color: application.status == 'shortlisted' 
                        ? CasaliganTheme.success 
                        : CasaliganTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: CasaliganTheme.neutral500),
              const SizedBox(width: 8),
              Text(
                application.location,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CasaliganTheme.neutral600,
                ),
              ),
              const Spacer(),
              Text(
                '₱${application.budget.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: CasaliganTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Applied ${_formatTimeAgo(application.applicationDate)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: CasaliganTheme.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Browse Jobs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, '/job-board');
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pushNamed(context, '/job-board');
          },
          icon: const Icon(Icons.work_outline, color: Colors.white),
          label: const Text(
            'Browse Available Jobs',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: CasaliganTheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard, 'Dashboard', true),
              _buildNavItem(Icons.work_outline, 'Jobs', false),
              _buildNavItem(Icons.chat_outlined, 'Messages', false),
              _buildNavItem(Icons.person_outline, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (label == 'Jobs') {
          Navigator.pushNamed(context, '/job-board');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? CasaliganTheme.primary : CasaliganTheme.neutral400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? CasaliganTheme.primary : CasaliganTheme.neutral400,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(BookingItem booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 20),
            Text(
              'Booking Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Client', booking.clientName),
            _buildDetailRow('Service', booking.service),
            _buildDetailRow('Date & Time', _formatBookingDate(booking.date)),
            _buildDetailRow('Duration', booking.duration),
            _buildDetailRow('Location', booking.location),
            _buildDetailRow('Payment', '₱${booking.payment.toStringAsFixed(0)}'),
            _buildDetailRow('Status', booking.status.toUpperCase()),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CasaliganTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CasaliganTheme.neutral500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBookingDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDate = DateTime(date.year, date.month, date.day);
    
    if (bookingDate == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (bookingDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${_formatTime(date)}';
    } else {
      return '${_formatDate(date)}, ${_formatTime(date)}';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Booking item model
class BookingItem {
  final String id;
  final String clientName;
  final String service;
  final DateTime date;
  final String duration;
  final double payment;
  final String location;
  final String status;

  BookingItem({
    required this.id,
    required this.clientName,
    required this.service,
    required this.date,
    required this.duration,
    required this.payment,
    required this.location,
    required this.status,
  });
}

/// Application item model
class ApplicationItem {
  final String jobTitle;
  final String clientName;
  final double budget;
  final String location;
  final DateTime applicationDate;
  final String status;

  ApplicationItem({
    required this.jobTitle,
    required this.clientName,
    required this.budget,
    required this.location,
    required this.applicationDate,
    required this.status,
  });
}