import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/casaligan_theme.dart';

/// My Jobs screen for house owners to manage their posted jobs
class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int _selectedIndex = 0;
  final List<String> _tabs = ['Active', 'In Progress', 'Completed'];
  
  // Mock user posted jobs
  final List<MyJobPost> _myJobs = [
    MyJobPost(
      id: '1',
      title: 'Deep House Cleaning Needed',
      description: '3-bedroom house needs comprehensive cleaning. Kitchen, bathrooms, living areas, and bedrooms.',
      budget: 4500.0,
      datePosted: DateTime.now().subtract(const Duration(hours: 2)),
      requiredHelpers: 2,
      services: ['Deep Cleaning', 'Kitchen Deep Clean', 'Bathroom Sanitization'],
      status: 'active',
      applicationCount: 8,
      selectedHousekeeper: null,
    ),
    MyJobPost(
      id: '2',
      title: 'Weekly Regular Cleaning Service',
      description: 'Looking for reliable housekeeper for weekly maintenance cleaning. 2-bedroom condo unit.',
      budget: 2000.0,
      datePosted: DateTime.now().subtract(const Duration(days: 1)),
      requiredHelpers: 1,
      services: ['Regular Cleaning'],
      status: 'in_progress',
      applicationCount: 12,
      selectedHousekeeper: 'Maria Santos',
    ),
    MyJobPost(
      id: '3',
      title: 'Move-out Cleaning',
      description: 'Complete cleaning for apartment before moving out. All rooms including appliances.',
      budget: 5500.0,
      datePosted: DateTime.now().subtract(const Duration(days: 7)),
      requiredHelpers: 2,
      services: ['Move-out Cleaning', 'Kitchen Deep Clean', 'Window Cleaning'],
      status: 'completed',
      applicationCount: 15,
      selectedHousekeeper: 'Ana Rodriguez',
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
        title: const Text('My Jobs'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/post-job');
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Post New Job',
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
                  _buildTabSelector(),
                  const SizedBox(height: 24),
                  _buildJobsList(),
                ]),
              ),
            ),
            
            // Add bottom padding for floating action button
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
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
    final activeJobs = _myJobs.where((job) => job.status == 'active').length;
    final completedJobs = _myJobs.where((job) => job.status == 'completed').length;
    final totalApplications = _myJobs.fold<int>(0, (sum, job) => sum + job.applicationCount);
    
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
              'Job Management',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your posted jobs and manage applications',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('$activeJobs', 'Active Jobs', Icons.work_outline),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('$completedJobs', 'Completed', Icons.check_circle_outline),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('$totalApplications', 'Applications', Icons.people_outline),
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

  Widget _buildTabSelector() {
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
                for (int i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _buildTabButton(_tabs[i], i),
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

  Widget _buildJobsList() {
    // Filter jobs based on selected tab
    List<MyJobPost> filteredJobs;
    String sectionTitle;
    
    switch (_selectedIndex) {
      case 0: // Active
        filteredJobs = _myJobs.where((job) => job.status == 'active').toList();
        sectionTitle = 'Active Jobs';
        break;
      case 1: // In Progress
        filteredJobs = _myJobs.where((job) => job.status == 'in_progress').toList();
        sectionTitle = 'Jobs in Progress';
        break;
      case 2: // Completed
        filteredJobs = _myJobs.where((job) => job.status == 'completed').toList();
        sectionTitle = 'Completed Jobs';
        break;
      default:
        filteredJobs = _myJobs;
        sectionTitle = 'All Jobs';
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                sectionTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${filteredJobs.length} jobs',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CasaliganTheme.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (filteredJobs.isEmpty)
            _buildEmptyState()
          else
            ...filteredJobs.map((job) {
              final index = filteredJobs.indexOf(job);
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

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    switch (_selectedIndex) {
      case 0:
        message = 'No active jobs. Post a job to find housekeepers!';
        icon = Icons.work_outline;
        break;
      case 1:
        message = 'No jobs in progress at the moment.';
        icon = Icons.schedule;
        break;
      case 2:
        message = 'No completed jobs yet. Complete some jobs to see them here!';
        icon = Icons.check_circle_outline;
        break;
      default:
        message = 'No jobs found.';
        icon = Icons.search_off;
    }

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: CasaliganTheme.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: CasaliganTheme.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
          if (_selectedIndex == 0) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pushNamed(context, '/post-job');
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Post Your First Job',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CasaliganTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJobCard(MyJobPost job) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (job.status) {
      case 'active':
        statusColor = CasaliganTheme.warning;
        statusText = 'ACTIVE';
        statusIcon = Icons.schedule;
        break;
      case 'in_progress':
        statusColor = CasaliganTheme.primary;
        statusText = 'IN PROGRESS';
        statusIcon = Icons.work;
        break;
      case 'completed':
        statusColor = CasaliganTheme.success;
        statusText = 'COMPLETED';
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = CasaliganTheme.neutral500;
        statusText = 'UNKNOWN';
        statusIcon = Icons.help;
    }

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
                          Text(
                            job.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Posted ${_formatTimeAgo(job.datePosted)}',
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₱${job.budget.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: CasaliganTheme.primary,
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
                
                // Footer Information and Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: CasaliganTheme.neutral500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${job.applicationCount} applications',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: CasaliganTheme.neutral500,
                          ),
                        ),
                        if (job.selectedHousekeeper != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.person,
                            size: 16,
                            color: CasaliganTheme.success,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Assigned to ${job.selectedHousekeeper}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: CasaliganTheme.success,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (job.status == 'active') ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.pushNamed(
                                  context,
                                  '/job-applications',
                                  arguments: {
                                    'jobId': job.id,
                                    'jobTitle': job.title,
                                  },
                                );
                              },
                              icon: Icon(Icons.people_outline, size: 16),
                              label: Text(
                                'View Applications (${job.applicationCount})',
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: CasaliganTheme.primary,
                                side: BorderSide(color: CasaliganTheme.primary),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (job.status == 'in_progress') ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          // Navigate to job management or chat with housekeeper
                        },
                        icon: Icon(Icons.chat, size: 16),
                        label: Text('Contact Housekeeper', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CasaliganTheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ] else if (job.status == 'completed') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: CasaliganTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 16, color: CasaliganTheme.success),
                            const SizedBox(width: 6),
                            Text(
                              'Job Completed',
                              style: TextStyle(
                                color: CasaliganTheme.success,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showJobDetails(MyJobPost job) {
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
                      Text(
                        job.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Posted ${_formatTimeAgo(job.datePosted)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: CasaliganTheme.neutral500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Budget & Status
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CasaliganTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
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
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CasaliganTheme.neutral100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Applications',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: CasaliganTheme.neutral600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${job.applicationCount}',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: CasaliganTheme.neutral800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                      const SizedBox(height: 100), // Space for buttons
                    ],
                  ),
                ),
              ),
              
              // Action Buttons
              Row(
                children: [
                  if (job.status == 'active') ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _viewApplications(job);
                        },
                        icon: const Icon(Icons.people),
                        label: const Text('View Applications'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: CasaliganTheme.primary),
                          foregroundColor: CasaliganTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _editJob(job);
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          'Edit Job',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CasaliganTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ] else if (job.status == 'in_progress') ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context, 
                            '/chat',
                            arguments: {
                              'housekeeper': {'name': job.selectedHousekeeper},
                              'booking': job,
                            },
                          );
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: CasaliganTheme.primary),
                          foregroundColor: CasaliganTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _completeJob(job);
                        },
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text(
                          'Complete Job',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CasaliganTheme.success,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ] else if (job.status == 'completed') ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _viewReceipt(job);
                        },
                        icon: const Icon(Icons.receipt),
                        label: const Text('View Receipt'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: CasaliganTheme.primary),
                          foregroundColor: CasaliganTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: const Text(
                          'Close',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CasaliganTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: const Text(
                          'Close',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CasaliganTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewApplications(MyJobPost job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.people, color: CasaliganTheme.primary),
            const SizedBox(width: 12),
            const Text('Job Applications'),
          ],
        ),
        content: Text(
          'You have ${job.applicationCount} applications for "${job.title}". View and manage applications in the full version.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: CasaliganTheme.primary),
            child: const Text('View All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshJobs() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate refreshing jobs
  }

  void _editJob(MyJobPost job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.edit, color: CasaliganTheme.primary),
            const SizedBox(width: 12),
            const Text('Edit Job'),
          ],
        ),
        content: Text('Job editing will be available in the full version. You can modify job details, budget, and requirements.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: CasaliganTheme.primary),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _completeJob(MyJobPost job) {
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
              'Complete Job',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you satisfied with the cleaning service provided by ${job.selectedHousekeeper}?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CasaliganTheme.neutral600,
              ),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CasaliganTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: CasaliganTheme.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Job: ${job.title}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total Payment: ₱${job.budget.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: CasaliganTheme.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Not Yet'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _processPayment(job);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CasaliganTheme.success,
                    ),
                    child: const Text(
                      'Yes, Complete',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(MyJobPost job) {
    // Determine payment method from job (for demo, we'll show both options)
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
              'Payment',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete payment for this job',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CasaliganTheme.neutral600,
              ),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CasaliganTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Total Amount:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₱${job.budget.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: CasaliganTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Service Provider:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        job.selectedHousekeeper ?? 'N/A',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Payment method buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _processGCashPayment(job);
                },
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text(
                  'Pay with GCash',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007DFF), // GCash blue
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _processCashPayment(job);
                },
                icon: const Icon(Icons.money),
                label: const Text('Confirm Cash Payment'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: CasaliganTheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processGCashPayment(MyJobPost job) {
    // Mock GCash payment flow
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF007DFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.payment, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('GCash Payment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF007DFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '₱${job.budget.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF007DFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transaction ID: GC${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: CasaliganTheme.neutral500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  const Text('Processing payment...'),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Close processing dialog
      _showPaymentSuccess(job, 'GCash');
    });
  }

  void _processCashPayment(MyJobPost job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.money, color: CasaliganTheme.warning),
            const SizedBox(width: 12),
            const Text('Cash Payment Confirmation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please confirm that you have paid ₱${job.budget.toStringAsFixed(0)} in cash to ${job.selectedHousekeeper}.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CasaliganTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: CasaliganTheme.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This confirmation is for record-keeping purposes. Please ensure the service provider has received the payment.',
                      style: TextStyle(
                        color: CasaliganTheme.warning,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPaymentSuccess(job, 'Cash');
            },
            style: ElevatedButton.styleFrom(backgroundColor: CasaliganTheme.warning),
            child: const Text('Confirm Payment', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccess(MyJobPost job, String paymentMethod) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: CasaliganTheme.success, size: 32),
            const SizedBox(width: 12),
            const Text('Payment Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Payment of ₱${job.budget.toStringAsFixed(0)} completed via $paymentMethod'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CasaliganTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Receipt ID: RC${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                style: TextStyle(
                  color: CasaliganTheme.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showReviewDialog(job);
            },
            style: ElevatedButton.styleFrom(backgroundColor: CasaliganTheme.success),
            child: const Text('Continue to Review', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(MyJobPost job) {
    int rating = 5;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.star, color: CasaliganTheme.warning),
              const SizedBox(width: 12),
              const Text('Rate & Review'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How was your experience with ${job.selectedHousekeeper}?'),
              const SizedBox(height: 16),
              
              Text(
                'Rating:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        rating = index + 1;
                      });
                    },
                    child: Icon(
                      Icons.star,
                      color: index < rating ? Colors.amber : CasaliganTheme.neutral300,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Review (Optional):',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _completeJobFlow(job, rating, '');
              },
              child: const Text('Skip Review'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _completeJobFlow(job, rating, reviewController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: CasaliganTheme.primary),
              child: const Text('Submit Review', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _completeJobFlow(MyJobPost job, int rating, String review) {
    // Update job status to completed
    setState(() {
      final index = _myJobs.indexWhere((j) => j.id == job.id);
      if (index != -1) {
        _myJobs[index] = MyJobPost(
          id: job.id,
          title: job.title,
          description: job.description,
          budget: job.budget,
          datePosted: job.datePosted,
          requiredHelpers: job.requiredHelpers,
          services: job.services,
          status: 'completed',
          applicationCount: job.applicationCount,
          selectedHousekeeper: job.selectedHousekeeper,
        );
        
        // Switch to completed tab
        _selectedIndex = 2;
      }
    });

    // Show completion success
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: CasaliganTheme.success, size: 32),
            const SizedBox(width: 12),
            const Text('Job Completed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Thank you for using Casaligan! Your job has been marked as completed.'),
            if (review.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CasaliganTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Your Rating: '),
                        ...List.generate(rating, (index) => Icon(Icons.star, color: Colors.amber, size: 16)),
                      ],
                    ),
                    if (review.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Review: "$review"',
                        style: TextStyle(
                          color: CasaliganTheme.success,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: CasaliganTheme.success),
            child: const Text('Great!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewReceipt(MyJobPost job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.receipt, color: CasaliganTheme.primary),
            const SizedBox(width: 12),
            const Text('Payment Receipt'),
          ],
        ),
        content: Text('Receipt and payment history will be available in the full version.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: CasaliganTheme.primary),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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

/// My job posting model for house owners
class MyJobPost {
  final String id;
  final String title;
  final String description;
  final double budget;
  final DateTime datePosted;
  final int requiredHelpers;
  final List<String> services;
  final String status; // 'active', 'in_progress', 'completed'
  final int applicationCount;
  final String? selectedHousekeeper;

  MyJobPost({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.datePosted,
    required this.requiredHelpers,
    required this.services,
    required this.status,
    required this.applicationCount,
    this.selectedHousekeeper,
  });
}