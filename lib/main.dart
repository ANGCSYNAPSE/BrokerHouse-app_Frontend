import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_controller.dart';

void main() {
  runApp(const ProviderScope(child: BrokerHouseApp()));
}

class BrokerHouseApp extends ConsumerWidget {
  const BrokerHouseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wire a failed token-refresh (revoked/expired refresh token) to force
    // the app back to the login flow, wherever the user currently is.
    ref.read(apiClientProvider).onSessionExpired = () {
      ref.read(authControllerProvider.notifier).forceSignOut();
    };

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BrokrsHouse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
