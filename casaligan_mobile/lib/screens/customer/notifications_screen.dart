import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/casaligan_theme.dart';

/// Notifications screen for customers
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Mock notifications
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Booking Confirmed',
      message: 'Maria Santos has confirmed your booking for Deep House Cleaning',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.booking,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Payment Received',
      message: 'Payment of ₱2,500.00 has been processed for your Move-in Cleaning service',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.payment,
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Service Completed',
      message: 'Ana Rodriguez has marked your Weekly Regular Cleaning as completed',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.service,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'New Message',
      message: 'Carmen Lopez sent you a message about kitchen deep clean details',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      type: NotificationType.message,
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Review Reminder',
      message: 'Don\'t forget to rate your experience with Maria Santos',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.review,
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadNotifications();
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

  Future<void> _loadNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    
    return Scaffold(
      backgroundColor: CasaliganTheme.surfaceContainer,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _markAllAsRead();
              },
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: CasaliganTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showNotificationSettings();
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Notification settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
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
                  if (unreadCount > 0) _buildUnreadHeader(unreadCount),
                  if (unreadCount > 0) const SizedBox(height: 24),
                  _buildNotificationsList(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnreadHeader(int unreadCount) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [CasaliganTheme.primary, CasaliganTheme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$unreadCount New Notification${unreadCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'You have unread notifications',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
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

  Widget _buildNotificationsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Notifications',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_notifications.isEmpty)
            _buildEmptyState()
          else
            ..._notifications.map((notification) {
              final index = _notifications.indexOf(notification);
              return AnimatedBuilder(
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
                      child: _buildNotificationCard(notification),
                    ),
                  );
                },
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    final typeConfig = _getNotificationTypeConfig(notification.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : CasaliganTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: notification.isRead 
            ? null 
            : Border.all(color: CasaliganTheme.primary.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _handleNotificationTap(notification);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Type icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeConfig['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    typeConfig['icon'],
                    color: typeConfig['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                color: notification.isRead 
                                    ? CasaliganTheme.neutral800 
                                    : CasaliganTheme.neutral900,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: CasaliganTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: notification.isRead 
                              ? CasaliganTheme.neutral600 
                              : CasaliganTheme.neutral700,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: CasaliganTheme.neutral500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeAgo(notification.timestamp),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: CasaliganTheme.neutral500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            typeConfig['label'],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: typeConfig['color'],
                              fontWeight: FontWeight.w500,
                            ),
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
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: CasaliganTheme.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CasaliganTheme.neutral500,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you about bookings, payments, and messages',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CasaliganTheme.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getNotificationTypeConfig(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return {
          'icon': Icons.event_note,
          'color': CasaliganTheme.primary,
          'label': 'Booking',
        };
      case NotificationType.payment:
        return {
          'icon': Icons.payment,
          'color': CasaliganTheme.success,
          'label': 'Payment',
        };
      case NotificationType.service:
        return {
          'icon': Icons.cleaning_services,
          'color': CasaliganTheme.accent,
          'label': 'Service',
        };
      case NotificationType.message:
        return {
          'icon': Icons.message,
          'color': CasaliganTheme.primaryLight,
          'label': 'Message',
        };
      case NotificationType.review:
        return {
          'icon': Icons.star,
          'color': Colors.amber,
          'label': 'Review',
        };
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read
    if (!notification.isRead) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = NotificationItem(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            timestamp: notification.timestamp,
            type: notification.type,
            isRead: true,
          );
        }
      });
    }

    // Navigate based on type
    switch (notification.type) {
      case NotificationType.booking:
      case NotificationType.service:
        Navigator.pushNamed(context, '/my-jobs');
        break;
      case NotificationType.message:
        Navigator.pushNamed(context, '/messages');
        break;
      case NotificationType.payment:
      case NotificationType.review:
        // Show details dialog
        _showNotificationDetails(notification);
        break;
    }
  }

  void _showNotificationDetails(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(notification.title),
        content: Text(notification.message),
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

  void _markAllAsRead() {
    setState(() {
      _notifications.replaceRange(0, _notifications.length, 
        _notifications.map((n) => NotificationItem(
          id: n.id,
          title: n.title,
          message: n.message,
          timestamp: n.timestamp,
          type: n.type,
          isRead: true,
        )).toList()
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All notifications marked as read'),
        backgroundColor: CasaliganTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.settings, color: CasaliganTheme.primary),
            const SizedBox(width: 12),
            const Text('Notification Settings'),
          ],
        ),
        content: const Text('Notification preferences and settings will be available in the full version.'),
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

  Future<void> _refreshNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate refreshing notifications
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '1w ago';
    }
  }
}

/// Notification types
enum NotificationType {
  booking,
  payment,
  service,
  message,
  review,
}

/// Notification item model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.isRead,
  });
}