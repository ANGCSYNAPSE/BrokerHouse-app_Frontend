import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/presentation/otp_verify_screen.dart';
import '../../features/auth/presentation/phone_entry_screen.dart';
import '../../features/home/presentation/coming_soon_screen.dart';
import '../../features/users/presentation/broker_profile_setup_screen.dart';
import '../widgets/splash_screen.dart';

/// Rebuilt whenever auth status/profile-completeness changes (rare — only on
/// login/logout/profile-setup transitions), which is enough to drive
/// redirects without a heavier ChangeNotifier bridge.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  String targetForState(AuthState s) {
    return switch (s.status) {
      AuthStatus.unknown => '/splash',
      AuthStatus.unauthenticated => '/login',
      AuthStatus.otpSent => '/otp',
      AuthStatus.authenticated => s.profileComplete ? '/home' : '/profile-setup',
    };
  }

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final target = targetForState(authState);
      return state.matchedLocation == target ? null : target;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const PhoneEntryScreen()),
      GoRoute(path: '/otp', builder: (context, state) => const OtpVerifyScreen()),
      GoRoute(path: '/profile-setup', builder: (context, state) => const BrokerProfileSetupScreen()),
      GoRoute(path: '/home', builder: (context, state) => const ComingSoonScreen()),
    ],
  );
});
