/// Legacy service model for backward compatibility
/// 
/// Note: This model is deprecated. Use HousekeeperService from housekeeper.dart instead.
/// This file exists for legacy compatibility only.
@deprecated
class Service {
  final String id;
  final String name;
  final String description;
  final double pricePerHour;
  final int durationInMinutes;
  final String category;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerHour,
    required this.durationInMinutes,
    required this.category,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      durationInMinutes: json['durationInMinutes'] as int,
      category: json['category'] as String,
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
    };
  }
}