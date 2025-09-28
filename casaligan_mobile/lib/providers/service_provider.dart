import 'package:flutter/foundation.dart';
import '../models/service.dart';

/// Legacy service provider for backward compatibility
/// 
/// @deprecated Use HousekeeperProvider instead
@deprecated
class ServiceProvider with ChangeNotifier {
  List<Service> _services = [];
  bool _isLoading = false;

  List<Service> get services => _services;
  bool get isLoading => _isLoading;

  /// Legacy method - use HousekeeperProvider.loadHousekeepers() instead
  @deprecated
  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();

    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 500));

    _services = [
      Service(
        id: '1',
        name: 'Basic Cleaning',
        description: 'Standard house cleaning service',
        pricePerHour: 400.0,
        durationInMinutes: 120,
        category: 'Regular',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }
}