import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/casaligan_theme.dart';

class JobManagementScreen extends StatefulWidget {
  const JobManagementScreen({Key? key}) : super(key: key);

  @override
  State<JobManagementScreen> createState() => _JobManagementScreenState();
}

class _JobManagementScreenState extends State<JobManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  Map<String, dynamic>? jobData;
  String currentStatus = 'scheduled'; // scheduled, in_progress, completed, paid
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _loadJobData();
    _animationController.forward();
  }

  void _loadJobData() async {
    // Get job data from arguments
    await Future.delayed(const Duration(milliseconds: 500));
    
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    setState(() {
      jobData = args;
      currentStatus = args?['status'] ?? 'scheduled';
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || jobData == null) {
      return Scaffold(
        backgroundColor: CasaliganTheme.surfaceContainer,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: CasaliganTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: CasaliganTheme.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Job Management',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: CasaliganTheme.neutral900,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJobCard(),
              const SizedBox(height: 16),
              _buildStatusTracker(),
              const SizedBox(height: 16),
              _buildCurrentStepContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard() {
    final schedule = jobData!['schedule'] as Map<String, dynamic>;
    final housekeeper = jobData!['housekeeper'];
    
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: CasaliganTheme.primary.withOpacity(0.1),
                child: Text(
                  housekeeper.housekeeperName[0],
                  style: TextStyle(
                    color: CasaliganTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobData!['jobTitle'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'with ${housekeeper.housekeeperName}',
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
                  color: _getStatusColor(currentStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(currentStatus),
                  style: TextStyle(
                    color: _getStatusColor(currentStatus),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: CasaliganTheme.neutral500),
              const SizedBox(width: 8),
              Text(
                '${schedule['date'].day}/${schedule['date'].month}/${schedule['date'].year} at ${schedule['time'].format(context)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CasaliganTheme.neutral600,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.timer, size: 16, color: CasaliganTheme.neutral500),
              const SizedBox(width: 8),
              Text(
                schedule['duration'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CasaliganTheme.neutral600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTracker() {
    final steps = [
      {'title': 'Scheduled', 'icon': Icons.schedule, 'status': 'scheduled'},
      {'title': 'In Progress', 'icon': Icons.cleaning_services, 'status': 'in_progress'},
      {'title': 'Completed', 'icon': Icons.check_circle, 'status': 'completed'},
      {'title': 'Paid', 'icon': Icons.payment, 'status': 'paid'},
    ];

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: steps.map((step) {
              final index = steps.indexOf(step);
              final isActive = _isStepActive(step['status'] as String);
              final isCompleted = _isStepCompleted(step['status'] as String);
              
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted || isActive
                            ? CasaliganTheme.primary
                            : CasaliganTheme.neutral200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: isCompleted || isActive
                            ? Colors.white
                            : CasaliganTheme.neutral500,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step['title'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isCompleted || isActive
                            ? CasaliganTheme.primary
                            : CasaliganTheme.neutral500,
                        fontWeight: isCompleted || isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (index < steps.length - 1) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 2,
                        color: isCompleted
                            ? CasaliganTheme.primary
                            : CasaliganTheme.neutral200,
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (currentStatus) {
      case 'scheduled':
        return _buildScheduledContent();
      case 'in_progress':
        return _buildInProgressContent();
      case 'completed':
        return _buildCompletedContent();
      case 'paid':
        return _buildPaidContent();
      default:
        return const SizedBox();
    }
  }

  Widget _buildScheduledContent() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Steps',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Group Chat Option
          _buildActionTile(
            icon: Icons.chat,
            title: 'Start Group Chat',
            subtitle: 'Communicate with your housekeeper',
            onTap: () => _startGroupChat(),
          ),
          
          const SizedBox(height: 12),
          
          // Mark as In Progress (for testing)
          _buildActionTile(
            icon: Icons.play_arrow,
            title: 'Mark as In Progress',
            subtitle: 'Job has started',
            onTap: () => _updateStatus('in_progress'),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressContent() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job In Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Chat Option
          _buildActionTile(
            icon: Icons.chat,
            title: 'Open Chat',
            subtitle: 'Message your housekeeper',
            onTap: () => _openChat(),
          ),
          
          const SizedBox(height: 12),
          
          // Mark as Completed
          _buildActionTile(
            icon: Icons.check_circle,
            title: 'Mark as Completed',
            subtitle: 'Job is finished',
            onTap: () => _updateStatus('completed'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedContent() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Completed!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: CasaliganTheme.success,
            ),
          ),
          const SizedBox(height: 16),
          
          // Payment Option
          _buildActionTile(
            icon: Icons.payment,
            title: 'Process Payment',
            subtitle: 'Pay ₱${_calculateAmount()}',
            onTap: () => _processPayment(),
          ),
          
          const SizedBox(height: 12),
          
          // Rate & Review
          _buildActionTile(
            icon: Icons.star,
            title: 'Rate & Review',
            subtitle: 'Share your experience',
            onTap: () => _rateAndReview(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaidContent() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: CasaliganTheme.success, size: 28),
              const SizedBox(width: 12),
              Text(
                'Job Complete!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CasaliganTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Thank you for using Casaligan! Your payment has been processed and your housekeeper has been notified.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CasaliganTheme.neutral600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Book Again
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/customer-home'));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CasaliganTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Book Another Service',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: CasaliganTheme.neutral200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CasaliganTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: CasaliganTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: CasaliganTheme.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: CasaliganTheme.neutral400),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled': return CasaliganTheme.warning;
      case 'in_progress': return CasaliganTheme.primary;
      case 'completed': return CasaliganTheme.success;
      case 'paid': return CasaliganTheme.success;
      default: return CasaliganTheme.neutral500;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled': return 'Scheduled';
      case 'in_progress': return 'In Progress';
      case 'completed': return 'Completed';
      case 'paid': return 'Completed';
      default: return 'Unknown';
    }
  }

  bool _isStepActive(String stepStatus) {
    return stepStatus == currentStatus;
  }

  bool _isStepCompleted(String stepStatus) {
    const statusOrder = ['scheduled', 'in_progress', 'completed', 'paid'];
    final currentIndex = statusOrder.indexOf(currentStatus);
    final stepIndex = statusOrder.indexOf(stepStatus);
    return stepIndex < currentIndex;
  }

  String _calculateAmount() {
    final housekeeper = jobData!['housekeeper'];
    return '${housekeeper.hourlyRate * 3}'; // Estimate based on duration
  }

  void _updateStatus(String newStatus) {
    setState(() {
      currentStatus = newStatus;
    });
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Job status updated to ${_getStatusText(newStatus)}'),
        backgroundColor: _getStatusColor(newStatus),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startGroupChat() {
    // Navigate to chat screen
    Navigator.pushNamed(
      context,
      '/job-chat',
      arguments: {
        'jobId': jobData!['jobId'],
        'housekeeper': jobData!['housekeeper'],
        'jobTitle': jobData!['jobTitle'],
      },
    );
  }

  void _openChat() {
    _startGroupChat();
  }

  void _processPayment() {
    // Navigate to payment screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentModal(
        amount: _calculateAmount(),
        onPaymentCompleted: () {
          Navigator.pop(context);
          _updateStatus('paid');
        },
      ),
    );
  }

  void _rateAndReview() {
    // Navigate to rating screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RatingModal(
        housekeeper: jobData!['housekeeper'],
        onRatingCompleted: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

// Simple Payment Modal
class PaymentModal extends StatelessWidget {
  final String amount;
  final VoidCallback onPaymentCompleted;

  const PaymentModal({
    Key? key,
    required this.amount,
    required this.onPaymentCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.8,
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
              
              Text(
                'Payment',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CasaliganTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '₱$amount',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: CasaliganTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Simulate payment processing
                    HapticFeedback.mediumImpact();
                    Future.delayed(const Duration(seconds: 2), () {
                      onPaymentCompleted();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CasaliganTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Process Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple Rating Modal
class RatingModal extends StatefulWidget {
  final dynamic housekeeper;
  final VoidCallback onRatingCompleted;

  const RatingModal({
    Key? key,
    required this.housekeeper,
    required this.onRatingCompleted,
  }) : super(key: key);

  @override
  State<RatingModal> createState() => _RatingModalState();
}

class _RatingModalState extends State<RatingModal> {
  int rating = 5;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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
              
              Text(
                'Rate your experience',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => rating = index + 1),
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: CasaliganTheme.warning,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              
              // Review Text
              TextField(
                controller: _reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your experience with ${widget.housekeeper.housekeeperName}...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onRatingCompleted();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CasaliganTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Submit Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}