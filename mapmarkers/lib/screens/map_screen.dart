import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/favorite_place.dart';
import '../services/places_service.dart';
import '../state/favorites_controller.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({required this.favorites, super.key});

  final FavoritesController favorites;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  static const _initialCamera = CameraPosition(
    target: LatLng(26.2235, 50.5876),
    zoom: 11,
  );

  final _searchController = TextEditingController();
  final _placesService = PlacesService();
  GoogleMapController? _mapController;
  Timer? _debounce;
  List<PlacePrediction> _predictions = const [];
  bool _searching = false;
  bool _resolvingTap = false;
  bool _locationEnabled = false;
  double _zoom = _initialCamera.zoom;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.favorites.addListener(_favoritesChanged);
    _readLocationPermission();
  }

  @override
  void dispose() {
    widget.favorites.removeListener(_favoritesChanged);
    _debounce?.cancel();
    _searchController.dispose();
    _placesService.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _favoritesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _readLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (!mounted) return;
    setState(() {
      _locationEnabled =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    });
  }

  Set<Marker> get _markers => widget.favorites.places.map((place) {
    return Marker(
      markerId: MarkerId(place.id),
      position: LatLng(place.latitude, place.longitude),
      onTap: () => _showPlace(place),
    );
  }).toSet();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _initialCamera,
          markers: _markers,
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
          },
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
          myLocationEnabled: _locationEnabled,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          mapToolbarEnabled: false,
          onMapCreated: (controller) => _mapController = controller,
          onCameraMove: (position) => _zoom = position.zoom,
          onTap: _savePlaceAt,
          onLongPress: (position) => _promptToSave(
            name: 'Pinned place',
            address:
                '${position.latitude.toStringAsFixed(5)}, '
                '${position.longitude.toStringAsFixed(5)}',
            position: position,
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(16),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search places and addresses',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : _searchController.text.isNotEmpty
                          ? IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(Icons.close),
                              onPressed: _clearSearch,
                            )
                          : null,
                    ),
                  ),
                ),
                if (!_placesService.isConfigured)
                  const _SearchMessage(
                    text: 'Add PLACES_API_KEY to enable search.',
                  ),
                if (_placesService.isConfigured && _predictions.isEmpty)
                  const _SearchMessage(
                    text: 'Tap a place on the map to save it.',
                  ),
                if (_predictions.isNotEmpty)
                  Material(
                    elevation: 4,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _predictions.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final prediction = _predictions[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on_outlined),
                            title: Text(prediction.title),
                            subtitle: Text(
                              prediction.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectPrediction(prediction),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_resolvingTap)
          const Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Finding this place...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 20,
          child: Column(
            children: [
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    IconButton(
                      tooltip: 'Zoom in',
                      onPressed: () => _changeZoom(1),
                      icon: const Icon(Icons.add),
                    ),
                    const SizedBox(width: 44, child: Divider(height: 1)),
                    IconButton(
                      tooltip: 'Zoom out',
                      onPressed: () => _changeZoom(-1),
                      icon: const Icon(Icons.remove),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.small(
                heroTag: 'current-location',
                tooltip: 'Go to my location',
                onPressed: _goToCurrentLocation,
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() => _predictions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!_placesService.isConfigured) return;
      setState(() => _searching = true);
      try {
        final predictions = await _placesService.autocomplete(value);
        if (!mounted || _searchController.text != value) return;
        setState(() => _predictions = predictions);
      } on PlacesException catch (error) {
        if (mounted) _showMessage(error.message);
      } finally {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() => _predictions = const []);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _changeZoom(double amount) async {
    final nextZoom = (_zoom + amount).clamp(2.0, 21.0);
    _zoom = nextZoom;
    await _mapController?.animateCamera(CameraUpdate.zoomTo(nextZoom));
  }

  Future<void> _savePlaceAt(LatLng position) async {
    if (_resolvingTap) return;
    setState(() => _resolvingTap = true);

    try {
      final details = await _placesService.nearestPlace(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (!mounted) return;
      final isNearby =
          details != null &&
          Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                details.latitude,
                details.longitude,
              ) <=
              250;
      final selectedPlace = isNearby ? details : null;

      await _promptToSave(
        name: selectedPlace?.name ?? 'Selected place',
        address:
            selectedPlace?.address ??
            '${position.latitude.toStringAsFixed(5)}, '
                '${position.longitude.toStringAsFixed(5)}',
        position: selectedPlace == null
            ? position
            : LatLng(selectedPlace.latitude, selectedPlace.longitude),
      );
    } on PlacesException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
      await _promptToSave(
        name: 'Selected place',
        address:
            '${position.latitude.toStringAsFixed(5)}, '
            '${position.longitude.toStringAsFixed(5)}',
        position: position,
      );
    } finally {
      if (mounted) setState(() => _resolvingTap = false);
    }
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _searching = true;
      _predictions = const [];
    });
    try {
      final details = await _placesService.details(prediction.placeId);
      final position = LatLng(details.latitude, details.longitude);
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(position, 16),
      );
      if (!mounted) return;
      _searchController.text = details.name;
      await _promptToSave(
        name: details.name,
        address: details.address,
        position: position,
      );
    } on PlacesException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _promptToSave({
    required String name,
    required String address,
    required LatLng position,
  }) async {
    var title = name;
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Save favorite place'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: name,
              autofocus: name == 'Pinned place',
              onChanged: (value) => title = value,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Place name'),
            ),
            const SizedBox(height: 12),
            Text(address, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    title = title.trim();
    if (save != true || title.isEmpty || !mounted) return;

    final now = DateTime.now();
    final place = FavoritePlace(
      id: '${now.microsecondsSinceEpoch}',
      name: title,
      address: address,
      latitude: position.latitude,
      longitude: position.longitude,
      createdAt: now,
    );
    try {
      await widget.favorites.add(place);
      if (mounted) _showMessage('$title saved to favorites.');
    } catch (_) {
      if (mounted) _showMessage('Could not save this favorite.');
    }
  }

  Future<void> _showPlace(FavoritePlace place) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.place),
        title: Text(place.name),
        content: place.address.isEmpty ? null : Text(place.address),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _showMessage('Turn on location services to use this feature.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      _showMessage('Location permission was denied.');
      return;
    }
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      final openSettings = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Location permission required'),
          content: const Text(
            'Enable location access for Map Markers in system settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Open settings'),
            ),
          ],
        ),
      );
      if (openSettings == true) await Geolocator.openAppSettings();
      return;
    }

    setState(() => _locationEnabled = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          16,
        ),
      );
    } on TimeoutException {
      _showMessage('Your location could not be determined in time.');
    } catch (_) {
      _showMessage('Your location is currently unavailable.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.key_outlined, size: 18),
          const SizedBox(width: 8),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }
}
