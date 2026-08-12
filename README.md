# Map Markers

Map Markers is a Flutter application for searching, saving, and revisiting places on Google Maps. Favorites are rendered as map markers and persisted locally between app launches.

## Features

- Interactive Google Map with pan, zoom, rotate, tilt, compass, and custom zoom controls
- Google Places autocomplete, place details, and nearby-place lookup
- Tap or long-press map locations to create named favorites
- Optional current-location navigation with permission and settings recovery flows
- Persistent favorite names, addresses, coordinates, and creation timestamps
- Synchronized Map, Favorites, and Info tabs
- Marker detail dialogs and confirmed favorite deletion
- Search degradation when the Places key is absent while manual pinning remains available

## Tech Stack

- Flutter and Dart 3.12+
- Google Maps Flutter for native map rendering
- Geolocator for location permission, positioning, and distance checks
- Google Places HTTP APIs through the `http` package
- SharedPreferences with JSON serialization for local persistence
- `ChangeNotifier` and `ListenableBuilder` for shared favorite state

## Project Structure

```text
mapmarkers/
|-- lib/
|   |-- data/       SharedPreferences repository
|   |-- models/     FavoritePlace model and JSON mapping
|   |-- screens/    Map, favorites, info, and tab-shell screens
|   |-- services/   Google Places API client
|   |-- state/      FavoritesController
|   |-- app.dart    Theme and root widget
|   `-- main.dart   Persistence initialization
|-- android/        Maps SDK key injection and Android host
|-- ios/            Maps SDK key injection and iOS host
`-- test/           Favorite serialization test
```

## Getting Started

### Prerequisites

- A Flutter SDK that includes Dart 3.12.2 or newer
- Android Studio and an Android SDK, or macOS with Xcode and CocoaPods
- A Google Cloud project with billing enabled
- Maps SDK for Android and/or Maps SDK for iOS enabled
- The Google Places API compatible with the legacy autocomplete, details, and nearby-search endpoints, enabled for search and automatic place resolution

Use application- and API-restricted keys in deployed builds. Do not commit API keys.

### Install Dependencies

From the repository root:

```sh
cd mapmarkers
flutter pub get
```

### Android Configuration

Add the native Maps SDK key to the existing ignored `android/local.properties` file. Preserve any Flutter SDK entry already present:

```properties
MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```

Run the app and pass the Places key as a compile-time Dart define:

```sh
flutter run --dart-define=PLACES_API_KEY=YOUR_GOOGLE_PLACES_API_KEY
```

The Maps key is required to render the map. The Places key is optional; without it, search and nearby-name resolution are disabled, but coordinates can still be saved from the map.

### iOS Configuration

Create the ignored secrets file and set `MAPS_API_KEY`:

```sh
cp ios/Flutter/Secrets.xcconfig.example ios/Flutter/Secrets.xcconfig
```

`Secrets.xcconfig.example` also contains a `DART_DEFINES` placeholder. Choose one of these approaches for the Places key:

- Replace that placeholder with the base64 value below, then run `flutter run` normally.
- Remove the `DART_DEFINES` line from the copied secrets file, then pass `--dart-define=PLACES_API_KEY=...` to `flutter run`.

Generate the value for the first approach with:

```sh
printf 'PLACES_API_KEY=YOUR_GOOGLE_PLACES_API_KEY' | base64
```

The resulting local configuration has this shape:

```properties
MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
DART_DEFINES=BASE64_OUTPUT_FROM_THE_COMMAND
```

This `DART_DEFINES` form is also required when launching directly from Xcode. Remove the line instead if Places features are intentionally disabled.

Install pods and open the workspace rather than the project file:

```sh
cd ios
pod install
open Runner.xcworkspace
```

Select a Development Team for the Runner target before running on an iPhone.

## Usage

1. Search for a place and choose a suggestion, or tap/long-press the map.
2. Review the resolved address or coordinates and edit the favorite name.
3. Confirm **Save** to add a persistent marker.
4. Tap a marker to view its stored details.
5. Use the location button to request access and center the map on the device.
6. Remove an item from Favorites to delete both its record and marker.

The initial map camera is centered near Manama, Bahrain. Favorite data remains on the current installation and is not synchronized to an account or remote service.

## Quality Checks

```sh
cd mapmarkers
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```
