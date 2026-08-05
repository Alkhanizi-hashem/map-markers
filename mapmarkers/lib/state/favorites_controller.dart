import 'package:flutter/foundation.dart';

import '../data/favorites_repository.dart';
import '../models/favorite_place.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController(this._repository);

  final FavoritesRepository _repository;
  List<FavoritePlace> _places = const [];

  List<FavoritePlace> get places => List.unmodifiable(_places);

  Future<void> load() async {
    _places = _repository.readAll();
    notifyListeners();
  }

  Future<void> add(FavoritePlace place) async {
    final previous = _places;
    _places = [..._places, place];
    notifyListeners();
    try {
      await _repository.writeAll(_places);
    } catch (_) {
      _places = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    final previous = _places;
    _places = _places.where((place) => place.id != id).toList();
    notifyListeners();
    try {
      await _repository.writeAll(_places);
    } catch (_) {
      _places = previous;
      notifyListeners();
      rethrow;
    }
  }
}
