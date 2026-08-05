import 'package:flutter/material.dart';

import '../models/favorite_place.dart';
import '../state/favorites_controller.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({required this.favorites, super.key});

  final FavoritesController favorites;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: favorites,
      builder: (context, _) {
        if (favorites.places.isEmpty) {
          return const _EmptyFavorites();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.places.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final place = favorites.places[index];
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                  child: const Icon(Icons.place_outlined),
                ),
                title: Text(
                  place.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  place.address.isEmpty
                      ? '${place.latitude.toStringAsFixed(5)}, '
                            '${place.longitude.toStringAsFixed(5)}'
                      : place.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  tooltip: 'Delete ${place.name}',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context, place),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, FavoritePlace place) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove favorite?'),
        content: Text('${place.name} will also be removed from the map.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !context.mounted) return;

    try {
      await favorites.remove(place.id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove this favorite.')),
      );
    }
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_add_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorite places yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Search for a place or long-press the map to save your first '
              'favorite.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
