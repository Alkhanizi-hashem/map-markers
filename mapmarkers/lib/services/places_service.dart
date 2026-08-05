import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

class PlacePrediction {
  const PlacePrediction({
    required this.placeId,
    required this.title,
    required this.description,
  });

  final String placeId;
  final String title;
  final String description;
}

class PlaceDetails {
  const PlaceDetails({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String address;
  final double latitude;
  final double longitude;
}

class PlacesService {
  PlacesService({http.Client? client}) : _client = client ?? http.Client();

  static const _apiKey = String.fromEnvironment('PLACES_API_KEY');
  static const _host = 'maps.googleapis.com';

  final http.Client _client;
  String _sessionToken = _newSessionToken();

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<List<PlacePrediction>> autocomplete(String input) async {
    if (!isConfigured || input.trim().length < 2) return const [];

    final uri = Uri.https(_host, '/maps/api/place/autocomplete/json', {
      'input': input.trim(),
      'key': _apiKey,
      'sessiontoken': _sessionToken,
    });
    final response = await _client.get(uri);
    final payload = _decodeResponse(response);
    _checkApiStatus(payload);

    final predictions = payload['predictions'] as List<dynamic>? ?? const [];
    return predictions.map((item) {
      final prediction = item as Map<String, dynamic>;
      final formatting =
          prediction['structured_formatting'] as Map<String, dynamic>?;
      return PlacePrediction(
        placeId: prediction['place_id'] as String,
        title:
            formatting?['main_text'] as String? ??
            prediction['description'] as String,
        description: prediction['description'] as String,
      );
    }).toList();
  }

  Future<PlaceDetails> details(String placeId) async {
    final uri = Uri.https(_host, '/maps/api/place/details/json', {
      'place_id': placeId,
      'fields': 'name,formatted_address,geometry',
      'key': _apiKey,
      'sessiontoken': _sessionToken,
    });
    final response = await _client.get(uri);
    final payload = _decodeResponse(response);
    _checkApiStatus(payload);
    _sessionToken = _newSessionToken();

    final result = payload['result'] as Map<String, dynamic>;
    final geometry = result['geometry'] as Map<String, dynamic>;
    final location = geometry['location'] as Map<String, dynamic>;
    return PlaceDetails(
      name: result['name'] as String? ?? 'Saved place',
      address: result['formatted_address'] as String? ?? '',
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
    );
  }

  Future<PlaceDetails?> nearestPlace({
    required double latitude,
    required double longitude,
  }) async {
    if (!isConfigured) return null;

    final uri = Uri.https(_host, '/maps/api/place/nearbysearch/json', {
      'location': '$latitude,$longitude',
      'rankby': 'distance',
      'key': _apiKey,
    });
    final response = await _client.get(uri);
    final payload = _decodeResponse(response);
    _checkApiStatus(payload);

    final results = payload['results'] as List<dynamic>? ?? const [];
    if (results.isEmpty) return null;

    final result = results.first as Map<String, dynamic>;
    final geometry = result['geometry'] as Map<String, dynamic>;
    final location = geometry['location'] as Map<String, dynamic>;
    return PlaceDetails(
      name: result['name'] as String? ?? 'Selected place',
      address: result['vicinity'] as String? ?? '',
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const PlacesException('Places search is temporarily unavailable.');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _checkApiStatus(Map<String, dynamic> payload) {
    final status = payload['status'] as String?;
    if (status == 'OK' || status == 'ZERO_RESULTS') return;
    throw PlacesException(
      payload['error_message'] as String? ?? 'Google Places request failed.',
    );
  }

  static String _newSessionToken() {
    final random = Random.secure();
    return '${DateTime.now().microsecondsSinceEpoch}-${random.nextInt(1 << 32)}';
  }

  void dispose() => _client.close();
}

class PlacesException implements Exception {
  const PlacesException(this.message);

  final String message;

  @override
  String toString() => message;
}
