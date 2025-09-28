import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/casaligan_theme.dart';
import '../../models/housekeeper.dart';

/// Comprehensive booking screen with service selection, scheduling, and payment
class BookingScreen extends StatefulWidget {
  final Housekeeper housekeeper;
  final String? preSelectedService;
  final String? preSelectedTime;

  const BookingScreen({
    super.key,
    required this.housekeeper,
    this.preSelectedService,
    this.preSelectedTime,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Booking data
  final Set<String> _selectedServices = {};
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '';
  String _locationType = 'Default';
  String _paymentMethod = 'GCash';
  double _tipAmount = 0.0;
  double _baseAmount = 0.0;
  
  // Available services with pricing
  final List<Map<String, dynamic>> _availableServices = [
    {
      'name': 'Deep Cleaning',
      'description': 'Comprehensive cleaning of all areas',
      'price': 3000.0, // ₱3,000
      'duration': '3-4 hours',
      'icon': Icons.home_filled,
      'color': CasaliganTheme.primary,
    },
    {
      'name': 'Regular Cleaning',
      'description': 'Standard weekly/bi-weekly maintenance',
      'price': 2000.0, // ₱2,000
      'duration': '2-3 hours',
      'icon': Icons.cleaning_services,
      'color': CasaliganTheme.accent,
    },
    {
      'name': 'Kitchen Deep Clean',
      'description': 'Detailed kitchen and appliance cleaning',
      'price': 2250.0, // ₱2,250
      'duration': '2-3 hours',
      'icon': Icons.kitchen,
      'color': CasaliganTheme.secondary,
    },
    {
      'name': 'Bathroom Sanitization',
      'description': 'Complete bathroom cleaning and sanitization',
      'price': 1750.0, // ₱1,750
      'duration': '1-2 hours',
      'icon': Icons.bathroom,
      'color': CasaliganTheme.warning,
    },
    {
      'name': 'Window Cleaning',
      'description': 'Interior and exterior window cleaning',
      'price': 1500.0, // ₱1,500
      'duration': '1-2 hours',
      'icon': Icons.window,
      'color': CasaliganTheme.accent,
    },
    {
      'name': 'Organization Service',
      'description': 'Decluttering and organizing spaces',
      'price': 2500.0, // ₱2,500
      'duration': '3-4 hours',
      'icon': Icons.inventory_2,
      'color': CasaliganTheme.success,
    },
  ];

  final List<String> _availableTimes = [
    '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM',
    '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeBookingData();
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

  void _initializeBookingData() {
    // Pre-select service if provided
    if (widget.preSelectedService != null) {
      _selectedServices.add(widget.preSelectedService!);
    }
    
    // Pre-select time if provided
    if (widget.preSelectedTime != null) {
      _selectedTime = widget.preSelectedTime!;
    }
    
    _calculateTotal();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _animationController.forward();
  }

  void _calculateTotal() {
    _baseAmount = 0.0;
    for (String serviceName in _selectedServices) {
      final service = _availableServices.firstWhere(
        (s) => s['name'] == serviceName,
        orElse: () => {'price': 0.0},
      );
      _baseAmount += service['price'] as double;
    }
    setState(() {});
  }

  double get _totalAmount => _baseAmount + _tipAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasaliganTheme.surfaceContainer,
      appBar: AppBar(
        title: const Text('Book Service'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHousekeeperSummary(),
                  const SizedBox(height: 24),
                  _buildServicesSection(),
                  const SizedBox(height: 24),
                  _buildDateTimeSection(),
                  const SizedBox(height: 24),
                  _buildLocationSection(),
                  const SizedBox(height: 24),
                  _buildNotesSection(),
                  const SizedBox(height: 24),
                  _buildPaymentSection(),
                  const SizedBox(height: 24),
                  _buildPricingBreakdown(),
                  const SizedBox(height: 100), // Space for booking button
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBookingFooter(),
    );
  }

  Widget _buildHousekeeperSummary() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Hero(
              tag: 'housekeeper-${widget.housekeeper.id}',
              child: CircleAvatar(
                radius: 30,
                backgroundColor: CasaliganTheme.primary.withOpacity(0.1),
                child: Text(
                  widget.housekeeper.name.split(' ').map((n) => n[0]).take(2).join(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CasaliganTheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.housekeeper.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: CasaliganTheme.warning,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.housekeeper.rating.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• \$${widget.housekeeper.baseHourlyRate}/hr',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: CasaliganTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
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
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
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
              children: [
                Icon(
                  Icons.checklist,
                  color: CasaliganTheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Services',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_availableServices.map((service) {
              final isSelected = _selectedServices.contains(service['name']);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedServices.add(service['name']);
                      } else {
                        _selectedServices.remove(service['name']);
                      }
                      _calculateTotal();
                    });
                    HapticFeedback.lightImpact();
                  },
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (service['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          service['icon'] as IconData,
                          color: service['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['name'],
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              service['description'],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: CasaliganTheme.neutral500,
                              ),
                            ),
                            Text(
                              '${service['duration']} • ₱${service['price'].toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: CasaliganTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  activeColor: CasaliganTheme.primary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  dense: false,
                ),
              );
            }).toList()),
            if (_selectedServices.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CasaliganTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CasaliganTheme.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      color: CasaliganTheme.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please select at least one service',
                        style: TextStyle(
                          color: CasaliganTheme.warning,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildDateTimeSection() {
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
              children: [
                Icon(
                  Icons.calendar_today,
                  color: CasaliganTheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Date & Time',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Date Selection
            Text(
              'Select Date',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                  HapticFeedback.lightImpact();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CasaliganTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CasaliganTheme.neutral300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: CasaliganTheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_drop_down,
                      color: CasaliganTheme.neutral500,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Time Selection
            Text(
              'Available Times',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTimes.map((time) {
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = isSelected ? '' : time;
                    });
                    HapticFeedback.lightImpact();
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

  Widget _buildLocationSection() {
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
              children: [
                Icon(
                  Icons.location_on,
                  color: CasaliganTheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Location Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Location Type
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Default Location'),
                    value: 'Default',
                    groupValue: _locationType,
                    onChanged: (value) {
                      setState(() {
                        _locationType = value!;
                      });
                      HapticFeedback.lightImpact();
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Custom Location'),
                    value: 'Custom',
                    groupValue: _locationType,
                    onChanged: (value) {
                      setState(() {
                        _locationType = value!;
                      });
                      HapticFeedback.lightImpact();
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
            
            if (_locationType == 'Custom') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter your address',
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) {
                  if (_locationType == 'Custom' && (value == null || value.isEmpty)) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
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
              children: [
                Icon(
                  Icons.note_add,
                  color: CasaliganTheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Additional Notes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Any special instructions or areas to focus on...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
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
              children: [
                Icon(
                  Icons.payment,
                  color: CasaliganTheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Payment Method',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Payment Methods
            Column(
              children: [
                RadioListTile<String>(
                  title: Row(
                    children: [
                      Icon(Icons.qr_code, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      const Text('GCash (QR Payment)'),
                    ],
                  ),
                  value: 'GCash',
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                    HapticFeedback.lightImpact();
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<String>(
                  title: Row(
                    children: [
                      Icon(Icons.money, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      const Text('Cash (Pay directly to helper)'),
                    ],
                  ),
                  value: 'Cash',
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                    HapticFeedback.lightImpact();
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Tip Section
            Text(
              'Add Tip (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _tipAmount,
                    min: 0,
                    max: 50,
                    divisions: 10,
                    activeColor: CasaliganTheme.primary,
                    onChanged: (value) {
                      setState(() {
                        _tipAmount = value;
                      });
                    },
                  ),
                ),
                Container(
                  width: 80,
                  child: Text(
                    '\$${_tipAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: CasaliganTheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingBreakdown() {
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
              children: [
                Icon(
                  Icons.receipt_long,
                  color: CasaliganTheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Pricing Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Selected Services
            if (_selectedServices.isNotEmpty) ...[
              ...(_selectedServices.map((serviceName) {
                final service = _availableServices.firstWhere(
                  (s) => s['name'] == serviceName,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        serviceName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${(service['price'] as double).toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '\$${_baseAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            
            if (_tipAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tip',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CasaliganTheme.neutral500,
                    ),
                  ),
                  Text(
                    '\$${_tipAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CasaliganTheme.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            const Divider(thickness: 2),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CasaliganTheme.primary,
                  ),
                ),
                Text(
                  '\$${_totalAmount.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CasaliganTheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingFooter() {
    final canBook = _selectedServices.isNotEmpty && _selectedTime.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canBook ? _proceedToChat : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canBook ? CasaliganTheme.primary : CasaliganTheme.neutral300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: canBook ? 8 : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  canBook 
                    ? 'Proceed to Chat - \$${_totalAmount.toStringAsFixed(0)}'
                    : 'Select Services & Time',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _proceedToChat() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    HapticFeedback.heavyImpact();
    
    // Show booking confirmation
    _showBookingConfirmation();
  }

  void _showBookingConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: CasaliganTheme.success,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Booking Confirmed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your booking with ${widget.housekeeper.name} has been confirmed.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CasaliganTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Details:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  Text('Time: $_selectedTime'),
                  Text('Services: ${_selectedServices.join(', ')}'),
                  Text('Total: \$${_totalAmount.toStringAsFixed(0)}'),
                  Text('Payment: $_paymentMethod'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
              Navigator.pushNamed(context, '/chat', arguments: {
                'housekeeper': widget.housekeeper,
                'booking': {
                  'services': _selectedServices.toList(),
                  'date': _selectedDate,
                  'time': _selectedTime,
                  'total': _totalAmount,
                  'paymentMethod': _paymentMethod,
                  'location': _locationType == 'Custom' ? _addressController.text : 'Default Location',
                  'notes': _notesController.text,
                }
              });
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }
}