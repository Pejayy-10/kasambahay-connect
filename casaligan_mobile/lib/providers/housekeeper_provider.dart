import 'package:flutter/foundation.dart';
import '../models/housekeeper.dart';
import '../repositories/housekeeper_repository.dart';

/// State management for housekeepers, cart, and booking flow
class HousekeeperProvider with ChangeNotifier {
  final HousekeeperRepository _repository = HousekeeperRepository();

  // State
  List<Housekeeper> _housekeepers = [];
  List<Housekeeper> _filteredHousekeepers = [];
  Housekeeper? _selectedHousekeeper;
  List<CartItem> _cart = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Search and filter state
  String _searchQuery = '';
  String _locationFilter = '';
  bool? _verifiedFilter;
  double? _minRatingFilter;
  String _specialtyFilter = '';

  // Getters
  List<Housekeeper> get housekeepers => _housekeepers;
  List<Housekeeper> get filteredHousekeepers => _filteredHousekeepers;
  Housekeeper? get selectedHousekeeper => _selectedHousekeeper;
  List<CartItem> get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Search and filter getters
  String get searchQuery => _searchQuery;
  String get locationFilter => _locationFilter;
  bool? get verifiedFilter => _verifiedFilter;
  double? get minRatingFilter => _minRatingFilter;
  String get specialtyFilter => _specialtyFilter;

  // Cart computed properties
  double get cartTotal => _cart.fold(0.0, (sum, item) => sum + item.totalPrice);
  int get cartTotalDuration => _cart.fold(0, (sum, item) => sum + item.totalDuration);
  int get cartItemCount => _cart.length;
  bool get isCartEmpty => _cart.isEmpty;

  /// Load all housekeepers
  Future<void> loadHousekeepers() async {
    _setLoading(true);
    _clearError();

    try {
      _housekeepers = await _repository.getAllHousekeepers();
      _filteredHousekeepers = List.from(_housekeepers);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load housekeepers: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Select a housekeeper (for viewing profile or booking)
  void selectHousekeeper(Housekeeper housekeeper) {
    _selectedHousekeeper = housekeeper;
    notifyListeners();
  }

  /// Clear selected housekeeper
  void clearSelectedHousekeeper() {
    _selectedHousekeeper = null;
    notifyListeners();
  }

  /// Search housekeepers by name
  Future<void> searchHousekeepers(String query) async {
    _searchQuery = query;
    await _applyFilters();
  }

  /// Combined search and filter method
  Future<void> searchAndFilter({
    String? nameQuery,
    String? location,
    bool? verified,
    double? minRating,
    String? specialty,
    bool? availableOnly,
  }) async {
    _searchQuery = nameQuery ?? '';
    _locationFilter = location ?? '';
    _verifiedFilter = verified;
    _minRatingFilter = minRating;
    _specialtyFilter = specialty ?? '';
    // Note: availableOnly is handled in the repository filter
    await _applyFilters();
  }

  /// Set location filter
  void setLocationFilter(String location) {
    _locationFilter = location;
    _applyFilters();
  }

  /// Set verification filter
  void setVerificationFilter(bool? verified) {
    _verifiedFilter = verified;
    _applyFilters();
  }

  /// Set minimum rating filter
  void setMinimumRatingFilter(double? rating) {
    _minRatingFilter = rating;
    _applyFilters();
  }

  /// Set specialty filter
  void setSpecialtyFilter(String specialty) {
    _specialtyFilter = specialty;
    _applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _locationFilter = '';
    _verifiedFilter = null;
    _minRatingFilter = null;
    _specialtyFilter = '';
    _filteredHousekeepers = List.from(_housekeepers);
    notifyListeners();
  }

  /// Apply current filters
  Future<void> _applyFilters() async {
    _setLoading(true);

    try {
      _filteredHousekeepers = await _repository.searchAndFilter(
        nameQuery: _searchQuery.isEmpty ? null : _searchQuery,
        location: _locationFilter.isEmpty ? null : _locationFilter,
        verified: _verifiedFilter,
        minRating: _minRatingFilter,
        specialty: _specialtyFilter.isEmpty ? null : _specialtyFilter,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to filter housekeepers: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add service to cart
  void addServiceToCart(HousekeeperService service, Housekeeper housekeeper, {int quantity = 1}) {
    // Check if service already exists in cart
    final existingIndex = _cart.indexWhere((item) => 
        item.service.id == service.id && item.housekeeper.id == housekeeper.id);

    if (existingIndex != -1) {
      // Update quantity if exists
      _cart[existingIndex] = _cart[existingIndex].copyWith(
        quantity: _cart[existingIndex].quantity + quantity,
      );
    } else {
      // Add new item
      _cart.add(CartItem(
        service: service,
        quantity: quantity,
        housekeeper: housekeeper,
      ));
    }
    
    notifyListeners();
  }

  /// Remove service from cart
  void removeServiceFromCart(String serviceId, String housekeeperId) {
    _cart.removeWhere((item) => 
        item.service.id == serviceId && item.housekeeper.id == housekeeperId);
    notifyListeners();
  }

  /// Update cart item quantity
  void updateCartItemQuantity(String serviceId, String housekeeperId, int newQuantity) {
    if (newQuantity <= 0) {
      removeServiceFromCart(serviceId, housekeeperId);
      return;
    }

    final index = _cart.indexWhere((item) => 
        item.service.id == serviceId && item.housekeeper.id == housekeeperId);

    if (index != -1) {
      _cart[index] = _cart[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  /// Clear entire cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  /// Get cart items for specific housekeeper
  List<CartItem> getCartItemsForHousekeeper(String housekeeperId) {
    return _cart.where((item) => item.housekeeper.id == housekeeperId).toList();
  }

  /// Get total price for specific housekeeper in cart
  double getCartTotalForHousekeeper(String housekeeperId) {
    return getCartItemsForHousekeeper(housekeeperId)
        .fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Check if service is in cart
  bool isServiceInCart(String serviceId, String housekeeperId) {
    return _cart.any((item) => 
        item.service.id == serviceId && item.housekeeper.id == housekeeperId);
  }

  /// Get cart item quantity for service
  int getCartItemQuantity(String serviceId, String housekeeperId) {
    final item = _cart.firstWhere(
      (item) => item.service.id == serviceId && item.housekeeper.id == housekeeperId,
      orElse: () => CartItem(
        service: HousekeeperService(
          id: '', name: '', description: '', 
          pricePerHour: 0, durationInMinutes: 0, category: ''
        ),
        quantity: 0,
        housekeeper: Housekeeper(
          id: '', name: '', bio: '', baseHourlyRate: 0, 
          location: '', rating: 0, reviewCount: 0, 
          profileImageUrl: '', phoneNumber: '', email: ''
        ),
      ),
    );
    return item.quantity;
  }

  /// Simulate booking completion (for prototype)
  Future<bool> completeBooking({
    required DateTime scheduledDate,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    String? customerNotes,
  }) async {
    if (_cart.isEmpty) return false;

    _setLoading(true);
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Clear cart after successful booking
      clearCart();
      
      // In a real app, this would save to backend
      debugPrint('Booking completed for $customerName on $scheduledDate');
      debugPrint('Services: ${_cart.map((item) => item.service.name).join(', ')}');
      
      return true;
    } catch (e) {
      _setError('Failed to complete booking: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadHousekeepers();
  }
}