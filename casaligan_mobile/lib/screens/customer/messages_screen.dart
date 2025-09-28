import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/casaligan_theme.dart';

/// Messages center screen for house owners
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Mock conversations
  final List<Conversation> _conversations = [
    Conversation(
      id: '1',
      housekeeperName: 'Maria Santos',
      lastMessage: 'I\'ll be there at 2 PM tomorrow as scheduled.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      unreadCount: 2,
      jobTitle: 'Deep House Cleaning',
      housekeeperAvatar: 'https://images.unsplash.com/photo-1494790108755-2616b9c75e0a',
      isOnline: true,
    ),
    Conversation(
      id: '2',
      housekeeperName: 'Ana Rodriguez',
      lastMessage: 'Thank you for choosing me for this job!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      jobTitle: 'Move-in Cleaning',
      housekeeperAvatar: 'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
      isOnline: false,
    ),
    Conversation(
      id: '3',
      housekeeperName: 'Carmen Lopez',
      lastMessage: 'I have a question about the kitchen deep clean...',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      unreadCount: 1,
      jobTitle: 'Weekly Regular Cleaning',
      housekeeperAvatar: 'https://images.unsplash.com/photo-1580489944761-15a19d654956',
      isOnline: true,
    ),
  ];

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
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
        title: const Text('Messages'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showMessageOptions();
            },
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMessages,
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
                  _buildStatsHeader(),
                  const SizedBox(height: 24),
                  _buildConversationsList(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader() {
    final unreadCount = _conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);
    final onlineCount = _conversations.where((conv) => conv.isOnline).length;
    
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Messages Center',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stay connected with your housekeepers',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('${_conversations.length}', 'Total Chats', Icons.chat_outlined),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('$unreadCount', 'Unread', Icons.mark_unread_chat_alt),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('$onlineCount', 'Online Now', Icons.circle, color: CasaliganTheme.success),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color ?? Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Conversations',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_conversations.isEmpty)
            _buildEmptyState()
          else
            ..._conversations.map((conversation) {
              final index = _conversations.indexOf(conversation);
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
                      child: _buildConversationCard(conversation),
                    ),
                  );
                },
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildConversationCard(Conversation conversation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _openChat(conversation);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(conversation.housekeeperAvatar),
                      onBackgroundImageError: (_, __) {},
                      child: conversation.housekeeperAvatar.isEmpty 
                          ? const Icon(Icons.person, size: 28) 
                          : null,
                    ),
                    if (conversation.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
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
                
                // Conversation details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.housekeeperName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (conversation.unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: CasaliganTheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${conversation.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        conversation.jobTitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CasaliganTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        conversation.lastMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: conversation.unreadCount > 0 
                              ? CasaliganTheme.neutral800
                              : CasaliganTheme.neutral600,
                          fontWeight: conversation.unreadCount > 0 
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                        maxLines: 2,
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
                            _formatTimeAgo(conversation.timestamp),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: CasaliganTheme.neutral500,
                            ),
                          ),
                          const Spacer(),
                          if (conversation.isOnline)
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: CasaliganTheme.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Online',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: CasaliganTheme.success,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
            Icons.chat_bubble_outline,
            size: 64,
            color: CasaliganTheme.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CasaliganTheme.neutral500,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start booking services to chat with housekeepers',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CasaliganTheme.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/customer-home',
                (route) => false,
              );
            },
            icon: const Icon(Icons.home, color: Colors.white),
            label: const Text(
              'Go to Home',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: CasaliganTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(Conversation conversation) {
    Navigator.pushNamed(
      context, 
      '/chat',
      arguments: {
        'housekeeper': {'name': conversation.housekeeperName},
        'booking': {
          'title': conversation.jobTitle,
          'selectedHousekeeper': conversation.housekeeperName,
        },
      },
    );
  }

  void _showMessageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CasaliganTheme.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: Icon(Icons.mark_chat_read, color: CasaliganTheme.primary),
              title: const Text('Mark All as Read'),
              onTap: () {
                Navigator.pop(context);
                _markAllAsRead();
              },
            ),
            ListTile(
              leading: Icon(Icons.archive, color: CasaliganTheme.primary),
              title: const Text('Archive All Conversations'),
              onTap: () {
                Navigator.pop(context);
                _showArchiveConfirmation();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: CasaliganTheme.primary),
              title: const Text('Message Settings'),
              onTap: () {
                Navigator.pop(context);
                _showSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _conversations.length; i++) {
        _conversations[i] = Conversation(
          id: _conversations[i].id,
          housekeeperName: _conversations[i].housekeeperName,
          lastMessage: _conversations[i].lastMessage,
          timestamp: _conversations[i].timestamp,
          unreadCount: 0,
          jobTitle: _conversations[i].jobTitle,
          housekeeperAvatar: _conversations[i].housekeeperAvatar,
          isOnline: _conversations[i].isOnline,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All messages marked as read'),
        backgroundColor: CasaliganTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showArchiveConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Archive Conversations'),
        content: const Text('Are you sure you want to archive all conversations? You can restore them later from settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Archive logic would go here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All conversations archived'),
                  backgroundColor: CasaliganTheme.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: CasaliganTheme.primary),
            child: const Text('Archive', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.settings, color: CasaliganTheme.primary),
            const SizedBox(width: 12),
            const Text('Message Settings'),
          ],
        ),
        content: const Text('Message notification settings and preferences will be available in the full version.'),
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

  Future<void> _refreshMessages() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate refreshing messages
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

/// Conversation model
class Conversation {
  final String id;
  final String housekeeperName;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final String jobTitle;
  final String housekeeperAvatar;
  final bool isOnline;

  Conversation({
    required this.id,
    required this.housekeeperName,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.jobTitle,
    required this.housekeeperAvatar,
    required this.isOnline,
  });
}