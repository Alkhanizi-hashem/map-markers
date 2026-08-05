import 'package:flutter_test/flutter_test.dart';
import 'package:mapmarkers/models/favorite_place.dart';

void main() {
  test('favorite place JSON round-trip preserves its fields', () {
    final createdAt = DateTime.utc(2026, 8, 5, 12, 30);
    final place = FavoritePlace(
      id: 'place-1',
      name: 'Bahrain National Museum',
      address: 'Manama, Bahrain',
      latitude: 26.2417,
      longitude: 50.5975,
      createdAt: createdAt,
    );

    final restored = FavoritePlace.fromJson(place.toJson());

    expect(restored.id, place.id);
    expect(restored.name, place.name);
    expect(restored.address, place.address);
    expect(restored.latitude, place.latitude);
    expect(restored.longitude, place.longitude);
    expect(restored.createdAt, createdAt);
  });
}
