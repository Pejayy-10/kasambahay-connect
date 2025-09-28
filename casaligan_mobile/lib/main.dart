import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';

import 'theme/casaligan_theme.dart';
import 'providers/housekeeper_provider.dart';
import 'providers/service_provider.dart';

// Screens
import 'screens/auth/loading_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/customer/housekeeper_selection_screen.dart';
import 'screens/customer/housekeeper_detail_screen.dart';
import 'screens/customer/booking_screen.dart';
import 'screens/customer/chat_screen.dart';
import 'screens/shared/job_board_screen.dart';
import 'screens/shared/job_posting_screen.dart';
import 'screens/housekeeper/housekeeper_dashboard_screen.dart';
import 'screens/customer/my_jobs_screen.dart';
import 'screens/customer/job_applications_screen.dart';
import 'screens/customer/messages_screen.dart';
import 'screens/customer/customer_profile_screen.dart';
import 'screens/customer/notifications_screen.dart';
import 'screens/customer/job_management_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true, // Enable device preview for responsive testing
      builder: (context) => const CasaliganApp(),
    ),
  );
}

class CasaliganApp extends StatelessWidget {
  const CasaliganApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HousekeeperProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()), // Legacy compatibility
      ],
      child: MaterialApp(
        title: 'Casaligan - Housekeeping Services',
        debugShowCheckedModeBanner: false,
        
        // Device Preview Integration
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        
        // Theme
        theme: CasaliganTheme.theme,
        
        // Initial Route
        initialRoute: '/',
        
        // Route Generation
        onGenerateRoute: _generateRoute,
        
        // Fallback Route
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => const _NotFoundScreen(),
          );
        },
      ),
    );
  }

  /// Generate routes for navigation
  static Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoadingScreen());
        
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());
        
      case '/customer-home':
        return MaterialPageRoute(builder: (_) => const CustomerHomeScreen());
        
      case '/housekeeper-selection':
        return MaterialPageRoute(builder: (_) => const HousekeeperSelectionScreen());
        
      case '/booking':
        // Extract arguments for booking screen
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['housekeeper'] != null) {
          return MaterialPageRoute(
            builder: (_) => BookingScreen(
              housekeeper: args['housekeeper'],
              preSelectedService: args['selectedService'],
              preSelectedTime: args['selectedTime'],
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const _PlaceholderScreen(
          title: 'Booking',
          message: 'Invalid booking data',
        ));
        
      case '/chat':
        // Extract arguments for chat screen
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['housekeeper'] != null) {
          return MaterialPageRoute(
            builder: (_) => ChatScreen(
              housekeeper: args['housekeeper'],
              booking: args['booking'],
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const _PlaceholderScreen(
          title: 'Chat',
          message: 'Invalid chat data',
        ));
        
      case '/housekeeper-booking':
        return MaterialPageRoute(builder: (_) => const _PlaceholderScreen(
          title: 'Book Services',
          message: 'Booking screen will be implemented in Phase 2',
        ));
        
      case '/booking-details':
        return MaterialPageRoute(builder: (_) => const _PlaceholderScreen(
          title: 'Booking Details',
          message: 'Booking details screen will be implemented in Phase 2',
        ));
        
      case '/housekeeper-detail':
        // Extract housekeeper from arguments
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['housekeeper'] != null) {
          return MaterialPageRoute(
            builder: (_) => HousekeeperDetailScreen(
              housekeeper: args['housekeeper'],
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const _PlaceholderScreen(
          title: 'Housekeeper Detail',
          message: 'Invalid housekeeper data',
        ));
        
      case '/housekeeper-profile':
        return MaterialPageRoute(builder: (_) => const _PlaceholderScreen(
          title: 'Housekeeper Profile',
          message: 'Profile screen will be implemented in Phase 2',
        ));

      case '/job-board':
        return MaterialPageRoute(builder: (_) => const JobBoardScreen());

      case '/post-job':
        return MaterialPageRoute(builder: (_) => const JobPostingScreen());

      case '/housekeeper-dashboard':
        return MaterialPageRoute(builder: (_) => const HousekeeperDashboardScreen());

      case '/my-jobs':
        return MaterialPageRoute(builder: (_) => const MyJobsScreen());

      case '/job-applications':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => JobApplicationsScreen(
            jobId: args?['jobId'] ?? '',
            jobTitle: args?['jobTitle'] ?? 'Unknown Job',
          ),
        );

      case '/messages':
        return MaterialPageRoute(builder: (_) => const MessagesScreen());

      case '/profile':
        return MaterialPageRoute(builder: (_) => const CustomerProfileScreen());

      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
        
      case '/job-management':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => JobManagementScreen(),
          settings: RouteSettings(arguments: args),
        );

      default:
        return null;
    }
  }
}

/// Placeholder screen for unimplemented routes
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;

  const _PlaceholderScreen({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 64,
                color: CasaliganTheme.mediumGray,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 404 Not Found Screen
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: CasaliganTheme.accentPink,
              ),
              const SizedBox(height: 24),
              Text(
                '404',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: CasaliganTheme.accentPink,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'The page you are looking for does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                ),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}