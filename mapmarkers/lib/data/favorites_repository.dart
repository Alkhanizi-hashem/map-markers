import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_place.dart';

class FavoritesRepository {
  FavoritesRepository(this._preferences);

  static const _storageKey = 'favorite_places_v1';

  final SharedPreferences _preferences;

  List<FavoritePlace> readAll() {
    final value = _preferences.getString(_storageKey);
    if (value == null || value.isEmpty) return const [];

    try {
      final records = jsonDecode(value) as List<dynamic>;
      return records
          .map(
            (record) => FavoritePlace.fromJson(
              Map<String, dynamic>.from(record as Map),
            ),
          )
          .toList();
    } on FormatException {
      return const [];
    } on TypeError {
      return const [];
    }
  }

  Future<void> writeAll(List<FavoritePlace> places) async {
    final value = jsonEncode(places.map((place) => place.toJson()).toList());
    final saved = await _preferences.setString(_storageKey, value);
    if (!saved) throw StateError('Could not save favorite places.');
  }
}
