import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/casaligan_theme.dart';

class JobApplicationsScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const JobApplicationsScreen({
    Key? key,
    required this.jobId,
    required this.jobTitle,
  }) : super(key: key);

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<JobApplication> applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _loadApplications();
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadApplications() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));
    
    setState(() {
      applications = [
        JobApplication(
          id: '1',
          housekeeperId: 'hk_001',
          housekeeperName: 'Maria Santos',
          housekeeperImage: 'assets/images/maria.jpg',
          rating: 4.9,
          completedJobs: 127,
          hourlyRate: 350,
          experience: '5 years',
          specializations: ['Deep Cleaning', 'Laundry', 'Kitchen'],
          status: ApplicationStatus.pending,
          appliedDate: DateTime.now().subtract(const Duration(hours: 2)),
          proposal: 'Hello! I\'m very interested in this cleaning job. I have 5 years of experience and specialize in deep cleaning. I can provide all necessary equipment and am available at your preferred time. Looking forward to working with you!',
          isVerified: true,
          languages: ['English', 'Tagalog'],
          availability: 'Monday-Friday, 8AM-6PM',
        ),
        JobApplication(
          id: '2',
          housekeeperId: 'hk_002',
          housekeeperName: 'Anna Reyes',
          housekeeperImage: 'assets/images/anna.jpg',
          rating: 4.8,
          completedJobs: 89,
          hourlyRate: 320,
          experience: '3 years',
          specializations: ['Regular Cleaning', 'Organizing'],
          status: ApplicationStatus.pending,
          appliedDate: DateTime.now().subtract(const Duration(hours: 5)),
          proposal: 'Good day! I would love to help with your cleaning needs. I\'m very detail-oriented and reliable. I have my own transportation and can work flexible hours. Thank you for considering my application!',
          isVerified: true,
          languages: ['English', 'Tagalog', 'Cebuano'],
          availability: 'Flexible schedule',
        ),
        JobApplication(
          id: '3',
          housekeeperId: 'hk_003',
          housekeeperName: 'Luz Garcia',
          housekeeperImage: 'assets/images/luz.jpg',
          rating: 4.7,
          completedJobs: 156,
          hourlyRate: 380,
          experience: '7 years',
          specializations: ['Deep Cleaning', 'Window Cleaning', 'Post-Construction'],
          status: ApplicationStatus.accepted,
          appliedDate: DateTime.now().subtract(const Duration(days: 1)),
          proposal: 'Hi! I have extensive experience in house cleaning and would be perfect for this job. I bring my own eco-friendly supplies and guarantee excellent results. I\'m available for both one-time and regular cleaning services.',
          isVerified: true,
          languages: ['English', 'Tagalog'],
          availability: 'Weekdays and weekends',
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasaliganTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: CasaliganTheme.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: CasaliganTheme.neutral900,
              ),
            ),
            Text(
              widget.jobTitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CasaliganTheme.neutral500,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: CasaliganTheme.primary,
          unselectedLabelColor: CasaliganTheme.neutral500,
          indicatorColor: CasaliganTheme.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Declined'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: CasaliganTheme.primary,
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildApplicationsList(ApplicationStatus.pending),
                    _buildApplicationsList(ApplicationStatus.accepted),
                    _buildApplicationsList(ApplicationStatus.declined),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildApplicationsList(ApplicationStatus status) {
    final filteredApplications = applications
        .where((app) => app.status == status)
        .toList();

    if (filteredApplications.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: _loadApplications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredApplications.length,
        itemBuilder: (context, index) {
          return _buildApplicationCard(filteredApplications[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(ApplicationStatus status) {
    String message;
    IconData icon;
    
    switch (status) {
      case ApplicationStatus.pending:
        message = 'No pending applications yet.\nApplicants will appear here.';
        icon = Icons.hourglass_empty;
        break;
      case ApplicationStatus.accepted:
        message = 'No accepted applications.\nAccepted applicants will appear here.';
        icon = Icons.check_circle_outline;
        break;
      case ApplicationStatus.declined:
        message = 'No declined applications.\nDeclined applicants will appear here.';
        icon = Icons.cancel_outlined;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: CasaliganTheme.neutral500.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: CasaliganTheme.neutral500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(JobApplication application) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: CasaliganTheme.primary.withOpacity(0.1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: CasaliganTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              application.housekeeperName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (application.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: CasaliganTheme.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    size: 12,
                                    color: CasaliganTheme.success,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: CasaliganTheme.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${application.rating}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${application.completedJobs} jobs completed',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: CasaliganTheme.neutral500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₱${application.hourlyRate}/hour • ${application.experience}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CasaliganTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: application.specializations.map((spec) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: CasaliganTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    spec,
                    style: TextStyle(
                      fontSize: 12,
                      color: CasaliganTheme.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              'Proposal:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              application.proposal,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CasaliganTheme.neutral500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: CasaliganTheme.neutral500,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimeAgo(application.appliedDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: CasaliganTheme.neutral500,
                  ),
                ),
                const Spacer(),
                if (application.status == ApplicationStatus.pending) ...[
                  OutlinedButton(
                    onPressed: () => _handleDeclineApplication(application),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CasaliganTheme.error,
                      side: BorderSide(color: CasaliganTheme.error),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleAcceptApplication(application),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CasaliganTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(application.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusText(application.status),
                      style: TextStyle(
                        color: _getStatusColor(application.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Colors.orange;
      case ApplicationStatus.accepted:
        return CasaliganTheme.success;
      case ApplicationStatus.declined:
        return CasaliganTheme.error;
    }
  }

  String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.declined:
        return 'Declined';
    }
  }

  void _handleAcceptApplication(JobApplication application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Accept Application'),
        content: Text(
          'Are you sure you want to accept ${application.housekeeperName}\'s application? This will notify them and you can proceed with job scheduling.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                application.status = ApplicationStatus.accepted;
              });
              HapticFeedback.mediumImpact();
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Application accepted! ${application.housekeeperName} has been notified.'),
                  backgroundColor: CasaliganTheme.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );

              // Navigate to job scheduling after a brief delay
              Future.delayed(const Duration(milliseconds: 1500), () {
                _navigateToJobScheduling(application);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CasaliganTheme.primary,
            ),
            child: Text('Accept & Schedule'),
          ),
        ],
      ),
    );
  }

  void _navigateToJobScheduling(JobApplication application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobSchedulingModal(
        application: application,
        jobTitle: widget.jobTitle,
        onScheduleConfirmed: (scheduleData) {
          Navigator.pop(context);
          _navigateToJobManagement(application, scheduleData);
        },
      ),
    );
  }

  void _navigateToJobManagement(JobApplication application, Map<String, dynamic> scheduleData) {
    Navigator.pushNamed(
      context,
      '/job-management',
      arguments: {
        'jobId': widget.jobId,
        'jobTitle': widget.jobTitle,
        'housekeeper': application,
        'schedule': scheduleData,
        'status': 'scheduled',
      },
    );
  }

  void _handleDeclineApplication(JobApplication application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Decline Application'),
        content: Text(
          'Are you sure you want to decline ${application.housekeeperName}\'s application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                application.status = ApplicationStatus.declined;
              });
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Application declined.'),
                  backgroundColor: CasaliganTheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CasaliganTheme.error,
            ),
            child: Text('Decline'),
          ),
        ],
      ),
    );
  }
}

// Job Scheduling Modal
class JobSchedulingModal extends StatefulWidget {
  final JobApplication application;
  final String jobTitle;
  final Function(Map<String, dynamic>) onScheduleConfirmed;

  const JobSchedulingModal({
    Key? key,
    required this.application,
    required this.jobTitle,
    required this.onScheduleConfirmed,
  }) : super(key: key);

  @override
  State<JobSchedulingModal> createState() => _JobSchedulingModalState();
}

class _JobSchedulingModalState extends State<JobSchedulingModal> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedDuration = '2-3 hours';
  String additionalNotes = '';
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.6,
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
                      Icons.schedule,
                      color: CasaliganTheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule Job',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Set date and time with ${widget.application.housekeeperName}',
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

              // Date Selection
              _buildDateSelection(),
              const SizedBox(height: 24),

              // Time Selection
              _buildTimeSelection(),
              const SizedBox(height: 24),

              // Duration Selection
              _buildDurationSelection(),
              const SizedBox(height: 24),

              // Additional Notes
              _buildNotesSection(),
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
                      onPressed: _canConfirmSchedule() ? _confirmSchedule : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CasaliganTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Confirm Schedule',
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

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: CasaliganTheme.neutral800,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
            );
            if (date != null) {
              setState(() => selectedDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: CasaliganTheme.neutral300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: CasaliganTheme.primary),
                const SizedBox(width: 12),
                Text(
                  selectedDate != null
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : 'Choose date',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: selectedDate != null ? CasaliganTheme.neutral800 : CasaliganTheme.neutral500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: CasaliganTheme.neutral400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: CasaliganTheme.neutral800,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 9, minute: 0),
            );
            if (time != null) {
              setState(() => selectedTime = time);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: CasaliganTheme.neutral300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: CasaliganTheme.primary),
                const SizedBox(width: 12),
                Text(
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : 'Choose time',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: selectedTime != null ? CasaliganTheme.neutral800 : CasaliganTheme.neutral500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: CasaliganTheme.neutral400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelection() {
    final durations = ['1-2 hours', '2-3 hours', '3-4 hours', '4-5 hours', '5+ hours'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expected Duration',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: CasaliganTheme.neutral800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: durations.map((duration) {
            final isSelected = selectedDuration == duration;
            return FilterChip(
              label: Text(duration),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => selectedDuration = duration);
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

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: CasaliganTheme.neutral800,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any specific instructions or preferences...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: CasaliganTheme.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: CasaliganTheme.primary),
            ),
          ),
          onChanged: (value) => additionalNotes = value,
        ),
      ],
    );
  }

  bool _canConfirmSchedule() {
    return selectedDate != null && selectedTime != null;
  }

  void _confirmSchedule() {
    final scheduleData = {
      'date': selectedDate,
      'time': selectedTime,
      'duration': selectedDuration,
      'notes': additionalNotes,
      'housekeeperName': widget.application.housekeeperName,
      'housekeeperId': widget.application.housekeeperId,
    };
    
    HapticFeedback.mediumImpact();
    widget.onScheduleConfirmed(scheduleData);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

class JobApplication {
  final String id;
  final String housekeeperId;
  final String housekeeperName;
  final String housekeeperImage;
  final double rating;
  final int completedJobs;
  final int hourlyRate;
  final String experience;
  final List<String> specializations;
  ApplicationStatus status;
  final DateTime appliedDate;
  final String proposal;
  final bool isVerified;
  final List<String> languages;
  final String availability;

  JobApplication({
    required this.id,
    required this.housekeeperId,
    required this.housekeeperName,
    required this.housekeeperImage,
    required this.rating,
    required this.completedJobs,
    required this.hourlyRate,
    required this.experience,
    required this.specializations,
    required this.status,
    required this.appliedDate,
    required this.proposal,
    required this.isVerified,
    required this.languages,
    required this.availability,
  });
}

enum ApplicationStatus {
  pending,
  accepted,
  declined,
}