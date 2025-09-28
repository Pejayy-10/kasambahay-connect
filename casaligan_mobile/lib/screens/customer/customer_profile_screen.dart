import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/casaligan_theme.dart';

/// Customer profile management screen
class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Mock user data
  final Map<String, dynamic> _userData = {
    'name': 'John Dela Cruz',
    'email': 'john.delacruz@email.com',
    'phone': '+63 917 123 4567',
    'address': 'Makati City, Metro Manila',
    'profilePicture': 'https://images.unsplash.com/photo-1560250097-0b93528c311a',
    'memberSince': DateTime(2024, 1, 15),
    'totalBookings': 24,
    'completedBookings': 20,
    'totalSpent': 15750.00,
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProfile();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      backgroundColor: CasaliganTheme.surfaceContainer,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showEditProfile();
            },
            icon: const Icon(Icons.edit),
            tooltip: 'Edit profile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: CasaliganTheme.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 20,
                vertical: 16,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  _buildMenuSection(),
                  const SizedBox(height: 100), // Bottom padding
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [CasaliganTheme.primary, CasaliganTheme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Profile picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(_userData['profilePicture']),
                  onBackgroundImageError: (_, __) {},
                  child: _userData['profilePicture'].isEmpty 
                      ? const Icon(Icons.person, size: 50) 
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: CasaliganTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Name
            Text(
              _userData['name'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            
            // Email
            Text(
              _userData['email'],
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 4),
            
            // Member since
            Text(
              'Member since ${_formatDate(_userData['memberSince'])}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '${_userData['totalBookings']}',
                  'Total Bookings',
                  Icons.event_note,
                  CasaliganTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '${_userData['completedBookings']}',
                  'Completed',
                  Icons.check_circle,
                  CasaliganTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            '₱${_userData['totalSpent'].toStringAsFixed(2)}',
            'Total Amount Spent',
            Icons.account_balance_wallet,
            CasaliganTheme.accent,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color, {bool fullWidth = false}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animationValue = Curves.easeOutCubic.transform(
          (_animationController.value - 0.2).clamp(0.0, 1.0),
        ).clamp(0.0, 1.0);
        
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              width: fullWidth ? double.infinity : null,
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: CasaliganTheme.neutral800,
                          ),
                        ),
                        Text(
                          label,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: CasaliganTheme.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuSection() {
    final menuItems = [
      MenuItemData(
        icon: Icons.person_outline,
        title: 'Personal Information',
        subtitle: 'Update your personal details',
        onTap: () => _showPersonalInfo(),
      ),
      MenuItemData(
        icon: Icons.location_on_outlined,
        title: 'Addresses',
        subtitle: 'Manage your saved addresses',
        onTap: () => _showAddresses(),
      ),
      MenuItemData(
        icon: Icons.payment,
        title: 'Payment Methods',
        subtitle: 'Manage your payment options',
        onTap: () => _showPaymentMethods(),
      ),
      MenuItemData(
        icon: Icons.star_outline,
        title: 'My Reviews',
        subtitle: 'See all your reviews and ratings',
        onTap: () => _showMyReviews(),
      ),
      MenuItemData(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'Configure notification preferences',
        onTap: () => _showNotificationSettings(),
      ),
      MenuItemData(
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'Get help and contact support',
        onTap: () => _showHelp(),
      ),
      MenuItemData(
        icon: Icons.privacy_tip_outlined,
        title: 'Privacy & Terms',
        subtitle: 'Review our privacy policy and terms',
        onTap: () => _showPrivacyTerms(),
      ),
      MenuItemData(
        icon: Icons.logout,
        title: 'Sign Out',
        subtitle: 'Sign out of your account',
        onTap: () => _showSignOutConfirmation(),
        isDestructive: true,
      ),
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
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
              children: menuItems.map((item) {
                final index = menuItems.indexOf(item);
                final isLast = index == menuItems.length - 1;
                
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final delay = index * 0.05;
                    final animationValue = Curves.easeOutCubic.transform(
                      (_animationController.value - 0.4 - delay).clamp(0.0, 1.0),
                    ).clamp(0.0, 1.0);
                    
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - animationValue)),
                      child: Opacity(
                        opacity: animationValue,
                        child: _buildMenuItem(item, isLast),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuItemData item, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          item.onTap();
        },
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(16),
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: isLast ? null : Border(
              bottom: BorderSide(color: CasaliganTheme.neutral100, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.isDestructive 
                      ? CasaliganTheme.error.withOpacity(0.1)
                      : CasaliganTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  color: item.isDestructive 
                      ? CasaliganTheme.error 
                      : CasaliganTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: item.isDestructive 
                            ? CasaliganTheme.error 
                            : CasaliganTheme.neutral800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (item.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CasaliganTheme.neutral500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: CasaliganTheme.neutral400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Menu actions
  void _showEditProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profile'),
        content: const Text('Profile editing functionality will be available in the full version of the app.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: CasaliganTheme.primary),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPersonalInfo() => _showFeatureNotAvailable('Personal Information');
  void _showAddresses() => _showFeatureNotAvailable('Address Management');
  void _showPaymentMethods() => _showFeatureNotAvailable('Payment Methods');
  void _showMyReviews() => _showFeatureNotAvailable('My Reviews');
  void _showNotificationSettings() => _showFeatureNotAvailable('Notification Settings');
  void _showHelp() => _showFeatureNotAvailable('Help & Support');
  void _showPrivacyTerms() => _showFeatureNotAvailable('Privacy & Terms');

  void _showFeatureNotAvailable(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(feature),
        content: const Text('This feature will be available in the full version of the app.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: CasaliganTheme.primary),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.logout, color: CasaliganTheme.error),
            const SizedBox(width: 12),
            const Text('Sign Out'),
          ],
        ),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: CasaliganTheme.error),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshProfile() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate refreshing profile data
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Menu item data model
class MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });
}