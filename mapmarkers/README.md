# Map Markers

Map Markers is a Flutter app for searching, bookmarking, and revisiting favorite
places on Google Maps. It targets Android and iOS and keeps favorites on-device
between sessions.

## Features

- Three-screen `TabBar` interface for the map, favorites, and app information
- Google Maps markers synchronized with a persistent favorites list
- Google Places autocomplete and place details search
- Current-location navigation with graceful permission handling
- Marker details dialogs and long-press map pinning
- Local JSON persistence using `shared_preferences`

## Prerequisites

- Flutter 3.44 or newer
- Xcode 16 or newer for iOS development
- An iOS 14 or newer deployment target
- Android Studio with a current Android SDK for Android development
- A Google Cloud project with billing enabled
- Maps SDK for Android, Maps SDK for iOS, and Places API enabled

Restrict production keys by application ID/bundle ID and API. Do not commit
keys to source control.

## Install

```sh
flutter pub get
```

### Android keys

Add the Maps key to the existing ignored `android/local.properties` file:

```properties
MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```

Pass the Places key when running Flutter:

```sh
flutter run --dart-define=PLACES_API_KEY=YOUR_GOOGLE_PLACES_API_KEY
```

### iOS keys and Xcode

Create the ignored secrets configuration:

```sh
cp ios/Flutter/Secrets.xcconfig.example ios/Flutter/Secrets.xcconfig
```

Set `MAPS_API_KEY` in `Secrets.xcconfig`. To make Places search work when
launching directly from Xcode, base64-encode the Dart define:

```sh
printf 'PLACES_API_KEY=YOUR_GOOGLE_PLACES_API_KEY' | base64
```

Paste that output after `DART_DEFINES=` in `Secrets.xcconfig`. Then install iOS
dependencies and open the workspace, not the project file:

```sh
flutter pub get
cd ios && pod install
open Runner.xcworkspace
```

In Xcode, select the `Runner` target, choose a Development Team under **Signing
& Capabilities**, select a simulator or connected iPhone, and press Run. Device
location is most reliable on physical hardware. The map requires a valid iOS
Maps key even if Places search is not configured.

## Usage

1. Search for a place and select a suggestion, then confirm **Save**.
2. Alternatively, long-press anywhere on the map and name the pinned place.
3. Tap a saved marker to view its name and address.
4. Use the location button to move to the device's current position.
5. Delete a place from the Favorites tab to remove its map marker and stored
   record.

## Quality checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build ios --simulator --no-codesign
```

## Project structure

```text
lib/
  data/       Persistent storage adapters
  models/     Domain models
  screens/    Map, favorites, info, and tab shell UI
  services/   Google Places HTTP integration
  state/      Shared favorites controller
```

## Authors

- Hashem, contact@mapmarkers.app

Developed in 2026 with Flutter. Replace the contact address in
`lib/screens/info_screen.dart` and this file with the final project email before
submission.
