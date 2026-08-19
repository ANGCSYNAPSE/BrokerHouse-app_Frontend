import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).user;
    const sections = [
      (Icons.person_outline, 'Personal Information'),
      (Icons.account_balance_outlined, 'Bank Account & UPI Details'),
      (Icons.verified_user_outlined, 'KYC Document Validation'),
      (Icons.workspace_premium_outlined, 'Subscription & Plan'),
      (Icons.help_outline, 'Help & Support'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Text('BH', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.role == null ? 'Broker' : user!.role[0] + user.role.substring(1).toLowerCase(),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.phone != null ? '${user!.countryCode} ${user.phone}' : (user?.email ?? '—'),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Expanded(child: _StatItem(label: 'Total Leads', value: '—')),
                  Expanded(child: _StatItem(label: 'Site Visits', value: '—')),
                  Expanded(child: _StatItem(label: 'Earnings', value: '—')),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (final section in sections)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(section.$1),
                title: Text(section.$2),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
