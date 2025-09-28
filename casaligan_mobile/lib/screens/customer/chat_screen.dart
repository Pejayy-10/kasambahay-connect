import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/casaligan_theme.dart';
import '../../models/housekeeper.dart';

/// Chat screen for communication between house owner and housekeeper
class ChatScreen extends StatefulWidget {
  final Housekeeper housekeeper;
  final Map<String, dynamic>? booking;

  const ChatScreen({
    super.key,
    required this.housekeeper,
    this.booking,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Mock chat messages
  final List<ChatMessage> _messages = [];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialMessages();
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
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialMessages() {
    // Add initial booking confirmation message
    if (widget.booking != null) {
      _messages.add(ChatMessage(
        id: '1',
        senderId: 'system',
        senderName: 'Casaligan',
        message: 'Booking confirmed! Here are the details:',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        isFromMe: false,
        isSystemMessage: true,
      ));
      
      final booking = widget.booking!;
      final services = (booking['services'] as List<String>).join(', ');
      final total = booking['total'] as double;
      final date = booking['date'] as DateTime;
      final time = booking['time'] as String;
      
      _messages.add(ChatMessage(
        id: '2',
        senderId: 'system',
        senderName: 'Casaligan',
        message: 'Services: $services\nDate: ${date.day}/${date.month}/${date.year}\nTime: $time\nTotal: ₱${total.toStringAsFixed(0)}\n\nPlease coordinate directly with your housekeeper for any special instructions.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        isFromMe: false,
        isSystemMessage: true,
      ));
    }
    
    // Add welcome message from housekeeper
    _messages.add(ChatMessage(
      id: '3',
      senderId: widget.housekeeper.id,
      senderName: widget.housekeeper.name,
      message: 'Hi! Thank you for booking my services. I\'m looking forward to helping you with your cleaning needs. Do you have any specific areas you\'d like me to focus on?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      isFromMe: false,
    ));

    setState(() {});
    _animationController.forward();
    
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'You',
      message: text,
      timestamp: DateTime.now(),
      isFromMe: true,
    );

    setState(() {
      _messages.add(message);
    });

    _messageController.clear();
    HapticFeedback.lightImpact();

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate response after a delay
    Future.delayed(const Duration(seconds: 2), () {
      _simulateResponse();
    });
  }

  void _simulateResponse() {
    final responses = [
      'That sounds perfect! I\'ll make sure to pay special attention to those areas.',
      'Understood. I\'ll bring all necessary cleaning supplies.',
      'Great! I\'ll be there on time. Looking forward to working with you!',
      'Thank you for the details. I\'ll make sure everything is spotless.',
      'Perfect! I\'ll focus on those areas during the cleaning session.',
    ];

    final randomResponse = responses[DateTime.now().millisecond % responses.length];
    
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.housekeeper.id,
      senderName: widget.housekeeper.name,
      message: randomResponse,
      timestamp: DateTime.now(),
      isFromMe: false,
    );

    if (mounted) {
      setState(() {
        _messages.add(message);
      });

      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasaliganTheme.surfaceContainer,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildBookingSummaryCard(),
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, color: CasaliganTheme.neutral700),
      ),
      title: Row(
        children: [
          Hero(
            tag: 'housekeeper-${widget.housekeeper.id}',
            child: CircleAvatar(
              radius: 20,
              backgroundColor: CasaliganTheme.primary.withOpacity(0.1),
              child: Text(
                widget.housekeeper.name.split(' ').map((n) => n[0]).take(2).join(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: CasaliganTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.housekeeper.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CasaliganTheme.neutral800,
                  ),
                ),
                Text(
                  widget.housekeeper.isAvailable ? 'Active now' : 'Last seen recently',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.housekeeper.isAvailable ? CasaliganTheme.success : CasaliganTheme.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // Show more options
            _showChatOptions(context);
          },
          icon: const Icon(Icons.more_vert, color: CasaliganTheme.neutral700),
        ),
      ],
    );
  }

  Widget _buildBookingSummaryCard() {
    if (widget.booking == null) return const SizedBox.shrink();
    
    final booking = widget.booking!;
    final services = (booking['services'] as List<String>).join(', ');
    final total = booking['total'] as double;
    final date = booking['date'] as DateTime;
    final time = booking['time'] as String;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CasaliganTheme.primary.withOpacity(0.2)),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CasaliganTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: CasaliganTheme.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Booking Confirmed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CasaliganTheme.success,
                  ),
                ),
                const Spacer(),
                Text(
                  '₱${total.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CasaliganTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Services',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CasaliganTheme.neutral500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        services,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Date & Time',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CasaliganTheme.neutral500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CasaliganTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return _buildMessageBubble(message);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isFromMe = message.isFromMe;
    final isSystem = message.isSystemMessage;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromMe && !isSystem) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: CasaliganTheme.primary.withOpacity(0.1),
              child: Text(
                message.senderName[0],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: CasaliganTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSystem 
                    ? CasaliganTheme.neutral100
                    : isFromMe 
                        ? CasaliganTheme.primary
                        : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isFromMe ? 16 : 4),
                  bottomRight: Radius.circular(isFromMe ? 4 : 16),
                ),
                boxShadow: isSystem ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isSystem ? Border.all(color: CasaliganTheme.neutral300) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSystem) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: CasaliganTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          message.senderName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: CasaliganTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    message.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSystem 
                          ? CasaliganTheme.neutral700
                          : isFromMe 
                              ? Colors.white
                              : CasaliganTheme.neutral800,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(message.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSystem 
                          ? CasaliganTheme.neutral500
                          : isFromMe 
                              ? Colors.white.withOpacity(0.7)
                              : CasaliganTheme.neutral500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isFromMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: CasaliganTheme.accent.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 16,
                color: CasaliganTheme.accent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Show attachment options
              },
              icon: Icon(
                Icons.add_circle_outline,
                color: CasaliganTheme.neutral500,
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: CasaliganTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: CasaliganTheme.neutral300),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: CasaliganTheme.primary,
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
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
              leading: Icon(Icons.info_outline, color: CasaliganTheme.primary),
              title: const Text('View Booking Details'),
              onTap: () {
                Navigator.pop(context);
                // Show booking details
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: CasaliganTheme.warning),
              title: const Text('Reschedule Booking'),
              onTap: () {
                Navigator.pop(context);
                // Reschedule booking
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel_outlined, color: CasaliganTheme.error),
              title: const Text('Cancel Booking'),
              onTap: () {
                Navigator.pop(context);
                // Cancel booking
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Chat message model
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isFromMe;
  final bool isSystemMessage;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isFromMe,
    this.isSystemMessage = false,
  });
}