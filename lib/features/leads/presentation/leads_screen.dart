import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';

class LeadsScreen extends StatelessWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tabs = ['All', 'New', 'Contacted', 'Site Visit', 'Negotiation'];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leads'),
          bottom: TabBar(isScrollable: true, tabs: tabs.map((t) => Tab(text: t)).toList()),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('New Lead'),
        ),
        body: TabBarView(
          children: tabs.map((tab) {
            final leads = tab == 'All' ? mockLeads : mockLeads.where((l) => l.status == tab).toList();
            if (leads.isEmpty) {
              return const Center(child: Text('No leads in this stage yet'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: leads.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _LeadCard(lead: leads[i]),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard({required this.lead});

  final MockLead lead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(lead.clientName[0], style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lead.clientName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(lead.project, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(lead.registeredAt, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(999)),
            child: Text(lead.status, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSecondaryContainer)),
          ),
        ],
      ),
    );
  }
}
