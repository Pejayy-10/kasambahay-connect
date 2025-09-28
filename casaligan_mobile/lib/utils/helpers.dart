import 'package:intl/intl.dart';

/// Utility functions for the Casaligan app
class Helpers {
  /// Format price to Philippine Peso currency
  static String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  /// Format price with decimal places
  static String formatPriceDecimal(double price) {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(price);
  }

  /// Format duration in minutes to human readable format
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours h $remainingMinutes min';
    }
  }

  /// Format date to readable format
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date with day of week
  static String formatDateWithDay(DateTime date) {
    return DateFormat('EEEE, MMM dd, yyyy').format(date);
  }

  /// Format time to readable format
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • h:mm a').format(dateTime);
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate Philippine mobile number
  static bool isValidPhoneNumber(String phone) {
    // Remove spaces, dashes, and parentheses
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Philippine mobile number formats:
    // +63XXXXXXXXXX (13 digits total)
    // 09XXXXXXXXX (11 digits total)
    // 63XXXXXXXXXX (12 digits total)
    
    if (cleanPhone.startsWith('+63')) {
      return cleanPhone.length == 13 && RegExp(r'^\+63\d{10}$').hasMatch(cleanPhone);
    } else if (cleanPhone.startsWith('63')) {
      return cleanPhone.length == 12 && RegExp(r'^63\d{10}$').hasMatch(cleanPhone);
    } else if (cleanPhone.startsWith('09')) {
      return cleanPhone.length == 11 && RegExp(r'^09\d{9}$').hasMatch(cleanPhone);
    }
    
    return false;
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (cleanPhone.startsWith('+63')) {
      final number = cleanPhone.substring(3);
      return '+63 ${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6)}';
    } else if (cleanPhone.startsWith('63')) {
      final number = cleanPhone.substring(2);
      return '+63 ${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6)}';
    } else if (cleanPhone.startsWith('09')) {
      return '${cleanPhone.substring(0, 4)} ${cleanPhone.substring(4, 7)} ${cleanPhone.substring(7)}';
    }
    
    return phone;
  }

  /// Calculate rating stars display
  static Map<String, int> calculateRatingStars(double rating) {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    
    return {
      'full': fullStars,
      'half': hasHalfStar ? 1 : 0,
      'empty': emptyStars,
    };
  }

  /// Generate initials from name
  static String generateInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    return text.split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  /// Get time of day from DateTime
  static String getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
           date.month == tomorrow.month &&
           date.day == tomorrow.day;
  }

  /// Get relative date string (Today, Tomorrow, or date)
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isTomorrow(date)) return 'Tomorrow';
    return formatDate(date);
  }

  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Generate a color from string (for avatars)
  static int generateColorFromString(String input) {
    var hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = input.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return hash;
  }
}