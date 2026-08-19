import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/project_card.dart';
import '../../auth/application/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Text('BH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back', style: theme.textTheme.bodySmall),
                      Text(
                        user?.role == null ? 'Broker' : user!.role[0] + user.role.substring(1).toLowerCase(),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              readOnly: true,
              onTap: () {},
              decoration: InputDecoration(
                hintText: 'Search projects, locations…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.75)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Festive Commission Bonus',
                          style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Earn extra ₹1,00,000+ on select projects this month',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.celebration_outlined, color: Colors.white, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Hot Projects', onSeeAll: () {}),
            const SizedBox(height: 12),
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mockHotProjects.length,
                itemBuilder: (context, i) => ProjectCard(project: mockHotProjects[i], width: 220),
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'High Commission Projects', onSeeAll: () {}),
            const SizedBox(height: 12),
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mockHighCommissionProjects.length,
                itemBuilder: (context, i) => ProjectCard(project: mockHighCommissionProjects[i], width: 220),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
    );
  }
}
