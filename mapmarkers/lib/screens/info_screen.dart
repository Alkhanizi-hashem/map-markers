import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  static const _developers = [
    (name: 'Hashem', email: 'contact@mapmarkers.app'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.travel_explore,
                size: 44,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(height: 20),
              Text(
                'Keep meaningful places close.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Map Markers helps travelers discover, save, and revisit '
                'favorite locations on one interactive map. Favorites remain '
                'available between app sessions.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text('Development team', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ..._developers.map(
          (developer) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(developer.name),
            subtitle: Text(developer.email),
          ),
        ),
        const Divider(height: 32),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.calendar_today_outlined),
          title: Text('Developed in 2026'),
          subtitle: Text('Version 1.0.0 • Built with Flutter'),
        ),
      ],
    );
  }
}
