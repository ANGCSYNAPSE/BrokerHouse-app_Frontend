import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/presentation/otp_verify_screen.dart';
import '../../features/auth/presentation/phone_entry_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../widgets/splash_screen.dart';

/// Rebuilt whenever auth status changes (rare — only on login/logout
/// transitions), which is enough to drive redirects without a heavier
/// ChangeNotifier bridge.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  String targetForStatus(AuthStatus status) {
    return switch (status) {
      AuthStatus.unknown => '/splash',
      AuthStatus.unauthenticated => '/login',
      AuthStatus.otpSent => '/otp',
      AuthStatus.authenticated => '/home',
    };
  }

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final target = targetForStatus(authState.status);
      return state.matchedLocation == target ? null : target;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const PhoneEntryScreen()),
      GoRoute(path: '/otp', builder: (context, state) => const OtpVerifyScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
});
