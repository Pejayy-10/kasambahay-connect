import '../models/housekeeper.dart';

/// Repository for managing housekeeper data
/// Uses mock data for prototyping purposes
class HousekeeperRepository {
  static final HousekeeperRepository _instance = HousekeeperRepository._internal();
  factory HousekeeperRepository() => _instance;
  HousekeeperRepository._internal();

  /// Mock housekeepers data
  List<Housekeeper> get mockHousekeepers => [
    Housekeeper(
      id: 'hk001',
      name: 'Maria Santos',
      bio: 'Experienced housekeeper with 5 years of professional cleaning services. I specialize in deep cleaning and take pride in leaving your home spotless. I am reliable, trustworthy, and detail-oriented.',
      baseHourlyRate: 450.0,
      location: 'Makati City, Metro Manila',
      rating: 4.8,
      reviewCount: 127,
      profileImageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400',
      isVerified: true,
      isAvailable: true,
      languages: ['English', 'Filipino', 'Tagalog'],
      specialties: ['Deep Cleaning', 'Kitchen Maintenance', 'Organization'],
      yearsOfExperience: 5,
      phoneNumber: '+63-917-123-4567',
      email: 'maria.santos@email.com',
      services: [
        HousekeeperService(
          id: 'svc001',
          name: 'Regular House Cleaning',
          description: 'Basic cleaning of all rooms including dusting, vacuuming, and mopping',
          pricePerHour: 450.0,
          durationInMinutes: 120,
          category: 'Regular Cleaning',
        ),
        HousekeeperService(
          id: 'svc002',
          name: 'Deep Cleaning Service',
          description: 'Comprehensive deep cleaning including baseboards, inside appliances, and detailed scrubbing',
          pricePerHour: 520.0,
          durationInMinutes: 180,
          category: 'Deep Cleaning',
        ),
        HousekeeperService(
          id: 'svc003',
          name: 'Kitchen Deep Clean',
          description: 'Complete kitchen cleaning including inside oven, refrigerator, and cabinets',
          pricePerHour: 480.0,
          durationInMinutes: 90,
          category: 'Kitchen Cleaning',
        ),
      ],
    ),
    Housekeeper(
      id: 'hk002',
      name: 'Ana Dela Cruz',
      bio: 'Eco-friendly cleaning specialist committed to using only green, non-toxic products. Perfect for families with children and pets. I offer flexible scheduling and exceptional attention to detail.',
      baseHourlyRate: 520.0,
      location: 'Taguig City, Metro Manila',
      rating: 4.9,
      reviewCount: 89,
      profileImageUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400',
      isVerified: true,
      isAvailable: true,
      languages: ['English', 'Filipino'],
      specialties: ['Eco-Friendly Cleaning', 'Window Cleaning', 'Office Cleaning'],
      yearsOfExperience: 3,
      phoneNumber: '+63-918-765-4321',
      email: 'ana.delacruz@email.com',
      services: [
        HousekeeperService(
          id: 'svc004',
          name: 'Eco-Friendly House Cleaning',
          description: 'Complete house cleaning using only eco-friendly, non-toxic cleaning products',
          pricePerHour: 520.0,
          durationInMinutes: 150,
          category: 'Eco-Friendly',
          isEcoFriendly: true,
        ),
        HousekeeperService(
          id: 'svc005',
          name: 'Window Cleaning Service',
          description: 'Professional window cleaning inside and outside for crystal clear results',
          pricePerHour: 380.0,
          durationInMinutes: 60,
          category: 'Window Cleaning',
          isEcoFriendly: true,
        ),
        HousekeeperService(
          id: 'svc006',
          name: 'Office Space Cleaning',
          description: 'Professional office cleaning including desks, electronics, and common areas',
          pricePerHour: 450.0,
          durationInMinutes: 120,
          category: 'Office Cleaning',
          isEcoFriendly: true,
        ),
      ],
    ),
    Housekeeper(
      id: 'hk003',
      name: 'Rosa Martinez',
      bio: 'Reliable housekeeper with extensive experience in home maintenance. I excel at laundry services and have a special touch with pet-friendly cleaning. Your satisfaction is my priority.',
      baseHourlyRate: 400.0,
      location: 'Pasig City, Metro Manila',
      rating: 4.7,
      reviewCount: 156,
      profileImageUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400',
      isVerified: true,
      isAvailable: true,
      languages: ['English', 'Filipino', 'Spanish'],
      specialties: ['Maintenance Cleaning', 'Laundry Services', 'Pet-Friendly'],
      yearsOfExperience: 8,
      phoneNumber: '+63-919-555-0123',
      email: 'rosa.martinez@email.com',
      services: [
        HousekeeperService(
          id: 'svc007',
          name: 'Maintenance Cleaning',
          description: 'Regular upkeep and maintenance cleaning to keep your home consistently clean',
          pricePerHour: 400.0,
          durationInMinutes: 90,
          category: 'Maintenance',
        ),
        HousekeeperService(
          id: 'svc008',
          name: 'Laundry & Ironing Service',
          description: 'Complete laundry service including washing, drying, folding, and ironing',
          pricePerHour: 320.0,
          durationInMinutes: 120,
          category: 'Laundry',
        ),
        HousekeeperService(
          id: 'svc009',
          name: 'Pet-Friendly Cleaning',
          description: 'Safe cleaning for homes with pets, including pet hair removal and sanitization',
          pricePerHour: 420.0,
          durationInMinutes: 135,
          category: 'Pet-Friendly',
        ),
      ],
    ),
  ];

  /// Simulate API delay for realistic UX
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// Fetch all housekeepers
  Future<List<Housekeeper>> getAllHousekeepers() async {
    await _simulateDelay();
    return List.from(mockHousekeepers);
  }

  /// Get housekeeper by ID
  Future<Housekeeper?> getHousekeeperById(String id) async {
    await _simulateDelay();
    try {
      return mockHousekeepers.firstWhere((hk) => hk.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search housekeepers by name
  Future<List<Housekeeper>> searchHousekeepersByName(String query) async {
    await _simulateDelay();
    if (query.isEmpty) return mockHousekeepers;
    
    return mockHousekeepers
        .where((hk) => hk.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Filter housekeepers by location
  Future<List<Housekeeper>> filterByLocation(String location) async {
    await _simulateDelay();
    return mockHousekeepers
        .where((hk) => hk.location.toLowerCase().contains(location.toLowerCase()))
        .toList();
  }

  /// Filter housekeepers by verification status
  Future<List<Housekeeper>> filterByVerification(bool verified) async {
    await _simulateDelay();
    return mockHousekeepers
        .where((hk) => hk.isVerified == verified)
        .toList();
  }

  /// Get available housekeepers only
  Future<List<Housekeeper>> getAvailableHousekeepers() async {
    await _simulateDelay();
    return mockHousekeepers
        .where((hk) => hk.isAvailable)
        .toList();
  }

  /// Filter by minimum rating
  Future<List<Housekeeper>> filterByMinimumRating(double minRating) async {
    await _simulateDelay();
    return mockHousekeepers
        .where((hk) => hk.rating >= minRating)
        .toList();
  }

  /// Get housekeepers by specialty
  Future<List<Housekeeper>> filterBySpecialty(String specialty) async {
    await _simulateDelay();
    return mockHousekeepers
        .where((hk) => hk.specialties
            .any((s) => s.toLowerCase().contains(specialty.toLowerCase())))
        .toList();
  }

  /// Combined search and filter
  Future<List<Housekeeper>> searchAndFilter({
    String? nameQuery,
    String? location,
    bool? verified,
    double? minRating,
    String? specialty,
    bool availableOnly = true,
  }) async {
    await _simulateDelay();
    
    List<Housekeeper> result = List.from(mockHousekeepers);

    if (availableOnly) {
      result = result.where((hk) => hk.isAvailable).toList();
    }

    if (nameQuery != null && nameQuery.isNotEmpty) {
      result = result
          .where((hk) => hk.name.toLowerCase().contains(nameQuery.toLowerCase()))
          .toList();
    }

    if (location != null && location.isNotEmpty) {
      result = result
          .where((hk) => hk.location.toLowerCase().contains(location.toLowerCase()))
          .toList();
    }

    if (verified != null) {
      result = result.where((hk) => hk.isVerified == verified).toList();
    }

    if (minRating != null) {
      result = result.where((hk) => hk.rating >= minRating).toList();
    }

    if (specialty != null && specialty.isNotEmpty) {
      result = result
          .where((hk) => hk.specialties
              .any((s) => s.toLowerCase().contains(specialty.toLowerCase())))
          .toList();
    }

    return result;
  }
}