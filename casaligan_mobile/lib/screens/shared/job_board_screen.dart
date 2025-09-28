import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/casaligan_theme.dart';

/// Job board screen where house owners can post jobs and housekeepers can browse/apply
class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Mock job postings
  final List<JobPosting> _jobPostings = [
    JobPosting(
      id: '1',
      title: 'Deep House Cleaning Needed',
      description: '3-bedroom house needs comprehensive cleaning. Kitchen, bathrooms, living areas, and bedrooms.',
      budget: 4500.0,
      location: 'Makati City',
      postedBy: 'Maria Santos',
      timePosted: DateTime.now().subtract(const Duration(hours: 2)),
      requiredHelpers: 2,
      services: ['Deep Cleaning', 'Kitchen Deep Clean', 'Bathroom Sanitization'],
      paymentMethod: 'GCash',
      applicationCount: 8,
      isUrgent: false,
    ),
    JobPosting(
      id: '2',
      title: 'Weekly Regular Cleaning Service',
      description: 'Looking for reliable housekeeper for weekly maintenance cleaning. 2-bedroom condo unit.',
      budget: 2000.0,
      location: 'BGC, Taguig',
      postedBy: 'John Rodriguez',
      timePosted: DateTime.now().subtract(const Duration(hours: 5)),
      requiredHelpers: 1,
      services: ['Regular Cleaning'],
      paymentMethod: 'Cash',
      applicationCount: 12,
      isUrgent: true,
    ),
    JobPosting(
      id: '3',
      title: 'Move-in Cleaning for New Apartment',
      description: 'New apartment needs thorough cleaning before moving in. All rooms including kitchen and bathroom.',
      budget: 5500.0,
      location: 'Quezon City',
      postedBy: 'Sarah Chen',
      timePosted: DateTime.now().subtract(const Duration(days: 1)),
      requiredHelpers: 2,
      services: ['Move-in Cleaning', 'Kitchen Deep Clean', 'Window Cleaning'],
      paymentMethod: 'GCash',
      applicationCount: 15,
      isUrgent: false,
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
        title: const Text('Job Board'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/post-job');
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Post a Job',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshJobs,
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
                  _buildFiltersSection(),
                  const SizedBox(height: 24),
                  _buildJobsList(),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(context, '/post-job');
        },
        backgroundColor: CasaliganTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Post Job',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatsHeader() {
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
              'Available Jobs',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find the perfect cleaning job that fits your schedule',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('${_jobPostings.length}', 'Total Jobs', Icons.work_outline),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    '${_jobPostings.where((j) => j.isUrgent).length}', 
                    'Urgent Jobs', 
                    Icons.priority_high
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    '₱${_calculateAverageRate().toStringAsFixed(0)}', 
                    'Avg. Rate', 
                    Icons.attach_money
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
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

  Widget _buildFiltersSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
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
            Text(
              'Filter Jobs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All Jobs', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Urgent', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('High Pay', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Near Me', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Today', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        HapticFeedback.lightImpact();
        // Handle filter selection
      },
      selectedColor: CasaliganTheme.primary.withOpacity(0.2),
      checkmarkColor: CasaliganTheme.primary,
    );
  }

  Widget _buildJobsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Job Postings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._jobPostings.map((job) {
            final index = _jobPostings.indexOf(job);
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
                    child: _buildJobCard(job),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildJobCard(JobPosting job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showJobDetails(job);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (job.isUrgent) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: CasaliganTheme.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'URGENT',
                                    style: TextStyle(
                                      color: CasaliganTheme.error,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  job.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Posted by ${job.postedBy}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: CasaliganTheme.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₱${job.budget.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: CasaliganTheme.primary,
                          ),
                        ),
                        Text(
                          _formatTimeAgo(job.timePosted),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: CasaliganTheme.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  job.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CasaliganTheme.neutral600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // Services Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: job.services.take(3).map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CasaliganTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service,
                        style: TextStyle(
                          color: CasaliganTheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Footer Row
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: CasaliganTheme.neutral500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.location,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CasaliganTheme.neutral500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.people,
                      size: 16,
                      color: CasaliganTheme.neutral500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${job.requiredHelpers} helper${job.requiredHelpers > 1 ? 's' : ''} needed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CasaliganTheme.neutral500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CasaliganTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${job.applicationCount} applied',
                        style: TextStyle(
                          color: CasaliganTheme.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
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
    );
  }

  void _showJobDetails(JobPosting job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 20),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job Header
                      Row(
                        children: [
                          if (job.isUrgent) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: CasaliganTheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'URGENT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Text(
                              job.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Posted by ${job.postedBy} • ${_formatTimeAgo(job.timePosted)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: CasaliganTheme.neutral500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Budget
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CasaliganTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.attach_money, color: CasaliganTheme.primary),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Budget',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: CasaliganTheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '₱${job.budget.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: CasaliganTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Payment Method',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: CasaliganTheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  job.paymentMethod,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: CasaliganTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Description
                      Text(
                        'Job Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: CasaliganTheme.neutral600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Services Required
                      Text(
                        'Services Required',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: job.services.map((service) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: CasaliganTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              service,
                              style: TextStyle(
                                color: CasaliganTheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      
                      // Job Details
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem('Location', job.location, Icons.location_on),
                          ),
                          Expanded(
                            child: _buildDetailItem('Helpers Needed', '${job.requiredHelpers}', Icons.people),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem('Applications', '${job.applicationCount}', Icons.assignment),
                          ),
                          Expanded(
                            child: _buildDetailItem('Payment', job.paymentMethod, Icons.payment),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100), // Space for button
                    ],
                  ),
                ),
              ),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.pop(context);
                    _applyForJob(job);
                  },
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text(
                    'Apply for this Job',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CasaliganTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CasaliganTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: CasaliganTheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CasaliganTheme.neutral500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _applyForJob(JobPosting job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.send, color: CasaliganTheme.success),
            const SizedBox(width: 12),
            const Text('Application Sent!'),
          ],
        ),
        content: Text(
          'Your application for "${job.title}" has been submitted. The house owner will review and contact you if selected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshJobs() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate refreshing jobs
  }

  double _calculateAverageRate() {
    if (_jobPostings.isEmpty) return 0;
    return _jobPostings.map((j) => j.budget).reduce((a, b) => a + b) / _jobPostings.length;
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

/// Job posting model
class JobPosting {
  final String id;
  final String title;
  final String description;
  final double budget;
  final String location;
  final String postedBy;
  final DateTime timePosted;
  final int requiredHelpers;
  final List<String> services;
  final String paymentMethod;
  final int applicationCount;
  final bool isUrgent;

  JobPosting({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.location,
    required this.postedBy,
    required this.timePosted,
    required this.requiredHelpers,
    required this.services,
    required this.paymentMethod,
    required this.applicationCount,
    this.isUrgent = false,
  });
}