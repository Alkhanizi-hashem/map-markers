import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/favorites_repository.dart';
import 'state/favorites_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final favorites = FavoritesController(FavoritesRepository(preferences));
  await favorites.load();

  runApp(MapMarkersApp(favorites: favorites));
}
