import 'package:flutter/material.dart';

import '../state/favorites_controller.dart';
import 'favorites_screen.dart';
import 'info_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.favorites, super.key});

  final FavoritesController favorites;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Map Markers',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.map_outlined), text: 'Map'),
              Tab(icon: Icon(Icons.favorite_outline), text: 'Favorites'),
              Tab(icon: Icon(Icons.info_outline), text: 'Info'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            MapScreen(favorites: favorites),
            FavoritesScreen(favorites: favorites),
            const InfoScreen(),
          ],
        ),
      ),
    );
  }
}
