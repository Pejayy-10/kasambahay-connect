import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/casaligan_theme.dart';
import '../../providers/housekeeper_provider.dart';
import '../../utils/helpers.dart';
import '../../models/housekeeper.dart';

/// Screen for browsing and selecting housekeepers
class HousekeeperSelectionScreen extends StatefulWidget {
  const HousekeeperSelectionScreen({super.key});

  @override
  State<HousekeeperSelectionScreen> createState() => _HousekeeperSelectionScreenState();
}

class _HousekeeperSelectionScreenState extends State<HousekeeperSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocation = 'All';
  String _selectedSpecialty = 'All';
  double _minRating = 0.0;
  bool _verifiedOnly = false;
  bool _availableOnly = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HousekeeperProvider>();
      if (provider.housekeepers.isEmpty) {
        provider.loadHousekeepers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final provider = context.read<HousekeeperProvider>();
    provider.searchAndFilter(
      nameQuery: _searchController.text,
      location: _selectedLocation == 'All' ? null : _selectedLocation,
      specialty: _selectedSpecialty == 'All' ? null : _selectedSpecialty,
      minRating: _minRating > 0 ? _minRating : null,
      verified: _verifiedOnly ? true : null,
      availableOnly: _availableOnly,
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedLocation = 'All';
      _selectedSpecialty = 'All';
      _minRating = 0.0;
      _verifiedOnly = false;
      _availableOnly = true;
    });
    context.read<HousekeeperProvider>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasaliganTheme.lightGray,
      appBar: AppBar(
        title: const Text('Find Housekeepers'),
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: CasaliganTheme.mediumGray),
                ),
              ),
              onChanged: (value) {
                setState(() {});
                _applyFilters();
              },
            ),
          ),

          // Active Filters Chips
          _buildActiveFilters(),

          // Housekeepers List
          Expanded(
            child: Consumer<HousekeeperProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return _buildLoadingState();
                }

                if (provider.errorMessage != null) {
                  return _buildErrorState(provider);
                }

                final housekeepers = provider.filteredHousekeepers;

                if (housekeepers.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () => provider.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: housekeepers.length,
                    itemBuilder: (context, index) {
                      return _buildHousekeeperCard(context, housekeepers[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build active filters chips
  Widget _buildActiveFilters() {
    final activeFilters = <Widget>[];

    if (_searchController.text.isNotEmpty) {
      activeFilters.add(_buildFilterChip('Search: ${_searchController.text}', () {
        _searchController.clear();
        _applyFilters();
      }));
    }

    if (_selectedLocation != 'All') {
      activeFilters.add(_buildFilterChip(_selectedLocation, () {
        setState(() => _selectedLocation = 'All');
        _applyFilters();
      }));
    }

    if (_selectedSpecialty != 'All') {
      activeFilters.add(_buildFilterChip(_selectedSpecialty, () {
        setState(() => _selectedSpecialty = 'All');
        _applyFilters();
      }));
    }

    if (_minRating > 0) {
      activeFilters.add(_buildFilterChip('${_minRating}+ stars', () {
        setState(() => _minRating = 0.0);
        _applyFilters();
      }));
    }

    if (_verifiedOnly) {
      activeFilters.add(_buildFilterChip('Verified', () {
        setState(() => _verifiedOnly = false);
        _applyFilters();
      }));
    }

    if (!_availableOnly) {
      activeFilters.add(_buildFilterChip('All', () {
        setState(() => _availableOnly = true);
        _applyFilters();
      }));
    }

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              children: activeFilters,
            ),
          ),
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  /// Build filter chip
  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close, size: 16),
      backgroundColor: CasaliganTheme.primaryBlue.withOpacity(0.1),
      labelStyle: const TextStyle(color: CasaliganTheme.primaryBlue),
    );
  }

  /// Build housekeeper card
  Widget _buildHousekeeperCard(BuildContext context, Housekeeper housekeeper) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.read<HousekeeperProvider>().selectHousekeeper(housekeeper);
          Navigator.of(context).pushNamed('/housekeeper-profile');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(housekeeper.profileImageUrl),
                    onBackgroundImageError: (_, __) {},
                    child: housekeeper.profileImageUrl.isEmpty
                        ? Text(Helpers.generateInitials(housekeeper.name))
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // Basic Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                housekeeper.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (housekeeper.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.verified,
                                      size: 12,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Verified',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Location
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: CasaliganTheme.mediumGray),
                            const SizedBox(width: 4),
                            Text(
                              housekeeper.location,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: CasaliganTheme.mediumGray,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Rating and Reviews
                        Row(
                          children: [
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < housekeeper.rating.floor()
                                      ? Icons.star
                                      : index < housekeeper.rating
                                          ? Icons.star_half
                                          : Icons.star_border,
                                  size: 16,
                                  color: Colors.amber,
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${housekeeper.rating} (${housekeeper.reviewCount} reviews)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Availability Status
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: housekeeper.isAvailable
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          housekeeper.isAvailable ? 'Available' : 'Busy',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: housekeeper.isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Helpers.formatPrice(housekeeper.baseHourlyRate),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: CasaliganTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Bio
              Text(
                Helpers.truncateText(housekeeper.bio, 120),
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 12),

              // Specialties
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: housekeeper.specialties.take(3).map((specialty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CasaliganTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      specialty,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CasaliganTheme.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<HousekeeperProvider>().selectHousekeeper(housekeeper);
                        Navigator.of(context).pushNamed('/housekeeper-profile');
                      },
                      child: const Text('View Profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: housekeeper.isAvailable
                          ? () {
                              context.read<HousekeeperProvider>().selectHousekeeper(housekeeper);
                              Navigator.of(context).pushNamed('/housekeeper-booking');
                            }
                          : null,
                      child: const Text('Book Now'),
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

  /// Build loading state
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  /// Build skeleton loading card
  Widget _buildSkeletonCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: CasaliganTheme.lightGray,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: 150,
                        decoration: BoxDecoration(
                          color: CasaliganTheme.lightGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: 100,
                        decoration: BoxDecoration(
                          color: CasaliganTheme.lightGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(HousekeeperProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: CasaliganTheme.accentPink,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CasaliganTheme.mediumGray,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.refresh(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: CasaliganTheme.mediumGray,
            ),
            const SizedBox(height: 16),
            Text(
              'No housekeepers found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CasaliganTheme.mediumGray,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _clearFilters,
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show filter bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  /// Build filter bottom sheet content
  Widget _buildFilterBottomSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextButton(
                    onPressed: () {
                      _clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Location Filter
              Text(
                'Location',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ['All', 'Makati City', 'Taguig City', 'Pasig City', 'BGC', 'Ortigas']
                    .map((location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        ))
                    .toList(),
                onChanged: (value) {
                  setModalState(() => _selectedLocation = value!);
                },
              ),
              const SizedBox(height: 16),

              // Specialty Filter
              Text(
                'Specialty',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSpecialty,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ['All', 'Residential Cleaning', 'Deep Cleaning', 'Eco-Friendly', 'Office Cleaning']
                    .map((specialty) => DropdownMenuItem(
                          value: specialty,
                          child: Text(specialty),
                        ))
                    .toList(),
                onChanged: (value) {
                  setModalState(() => _selectedSpecialty = value!);
                },
              ),
              const SizedBox(height: 16),

              // Minimum Rating Filter
              Text(
                'Minimum Rating: ${_minRating.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _minRating,
                min: 0.0,
                max: 5.0,
                divisions: 10,
                onChanged: (value) {
                  setModalState(() => _minRating = value);
                },
              ),
              const SizedBox(height: 16),

              // Verification Filter
              CheckboxListTile(
                title: const Text('Verified Only'),
                value: _verifiedOnly,
                onChanged: (value) {
                  setModalState(() => _verifiedOnly = value!);
                },
                contentPadding: EdgeInsets.zero,
              ),

              // Availability Filter
              CheckboxListTile(
                title: const Text('Available Only'),
                value: _availableOnly,
                onChanged: (value) {
                  setModalState(() => _availableOnly = value!);
                },
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),

              // Apply Filters Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}