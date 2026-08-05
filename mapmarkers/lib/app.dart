import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'state/favorites_controller.dart';

class MapMarkersApp extends StatelessWidget {
  const MapMarkersApp({required this.favorites, super.key});

  final FavoritesController favorites;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF006C68);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Map Markers',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: HomeScreen(favorites: favorites),
    );
  }
}
