/// Model representing a housekeeping service offered by a housekeeper
class HousekeeperService {
  final String id;
  final String name;
  final String description;
  final double pricePerHour;
  final int durationInMinutes;
  final String category;
  final bool isEcoFriendly;

  HousekeeperService({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerHour,
    required this.durationInMinutes,
    required this.category,
    this.isEcoFriendly = false,
  });

  factory HousekeeperService.fromJson(Map<String, dynamic> json) {
    return HousekeeperService(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      durationInMinutes: json['durationInMinutes'] as int,
      category: json['category'] as String,
      isEcoFriendly: json['isEcoFriendly'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pricePerHour': pricePerHour,
      'durationInMinutes': durationInMinutes,
      'category': category,
      'isEcoFriendly': isEcoFriendly,
    };
  }

  HousekeeperService copyWith({
    String? id,
    String? name,
    String? description,
    double? pricePerHour,
    int? durationInMinutes,
    String? category,
    bool? isEcoFriendly,
  }) {
    return HousekeeperService(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      category: category ?? this.category,
      isEcoFriendly: isEcoFriendly ?? this.isEcoFriendly,
    );
  }
}

/// Model representing a professional housekeeper
class Housekeeper {
  final String id;
  final String name;
  final String bio;
  final double baseHourlyRate;
  final String location;
  final double rating;
  final int reviewCount;
  final String profileImageUrl;
  final bool isVerified;
  final bool isAvailable;
  final List<String> languages;
  final List<String> specialties;
  final List<HousekeeperService> services;
  final int yearsOfExperience;
  final String phoneNumber;
  final String email;

  Housekeeper({
    required this.id,
    required this.name,
    required this.bio,
    required this.baseHourlyRate,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.profileImageUrl,
    this.isVerified = false,
    this.isAvailable = true,
    this.languages = const ['English'],
    this.specialties = const [],
    this.services = const [],
    this.yearsOfExperience = 1,
    required this.phoneNumber,
    required this.email,
  });

  factory Housekeeper.fromJson(Map<String, dynamic> json) {
    return Housekeeper(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String,
      baseHourlyRate: (json['baseHourlyRate'] as num).toDouble(),
      location: json['location'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      profileImageUrl: json['profileImageUrl'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? true,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['English'],
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => HousekeeperService.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      yearsOfExperience: json['yearsOfExperience'] as int? ?? 1,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'baseHourlyRate': baseHourlyRate,
      'location': location,
      'rating': rating,
      'reviewCount': reviewCount,
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'languages': languages,
      'specialties': specialties,
      'services': services.map((s) => s.toJson()).toList(),
      'yearsOfExperience': yearsOfExperience,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  Housekeeper copyWith({
    String? id,
    String? name,
    String? bio,
    double? baseHourlyRate,
    String? location,
    double? rating,
    int? reviewCount,
    String? profileImageUrl,
    bool? isVerified,
    bool? isAvailable,
    List<String>? languages,
    List<String>? specialties,
    List<HousekeeperService>? services,
    int? yearsOfExperience,
    String? phoneNumber,
    String? email,
  }) {
    return Housekeeper(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      baseHourlyRate: baseHourlyRate ?? this.baseHourlyRate,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      isAvailable: isAvailable ?? this.isAvailable,
      languages: languages ?? this.languages,
      specialties: specialties ?? this.specialties,
      services: services ?? this.services,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }
}

/// Model for cart item (selected service with quantity)
class CartItem {
  final HousekeeperService service;
  final int quantity;
  final Housekeeper housekeeper;

  CartItem({
    required this.service,
    required this.quantity,
    required this.housekeeper,
  });

  double get totalPrice => service.pricePerHour * quantity;
  int get totalDuration => service.durationInMinutes * quantity;

  CartItem copyWith({
    HousekeeperService? service,
    int? quantity,
    Housekeeper? housekeeper,
  }) {
    return CartItem(
      service: service ?? this.service,
      quantity: quantity ?? this.quantity,
      housekeeper: housekeeper ?? this.housekeeper,
    );
  }
}