import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/application/auth_controller.dart';

/// Deliberately minimal placeholder for whatever comes after onboarding —
/// swap for the real home/dashboard screen once its Figma design arrives.
class ComingSoonScreen extends ConsumerWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broker House'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => ref.read(authControllerProvider.notifier).logout()),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.dashboard_customize_outlined, size: 48, color: AppColors.gold),
              SizedBox(height: 16),
              Text(
                "You're all set — onboarding complete.",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              SizedBox(height: 8),
              Text(
                'The home dashboard is next — waiting on its Figma screens.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
