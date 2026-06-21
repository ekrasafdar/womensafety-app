# SafeGuard – Personal Safety App

A Flutter app with a dark, polished UI implementing your project spec:
SOS button, live location sharing, trusted contacts, AI-style safety
monitoring (risk score), route deviation monitoring, fake call, and
emergency history. Currently runs on **mock/local data** (no Firebase
needed) so it works immediately.

## How to run

1. Open a terminal in this folder (`safeguard_app`).
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Plug in a phone (USB debugging on) or start an emulator/simulator.
4. Run:
   ```
   flutter run
   ```

That's it — no API keys required to see the full UI and features.

## What's real vs. simulated right now

- **Real**: actual device GPS via the `geolocator` package (will ask for
  location permission).
- **Simulated (no setup needed)**: trusted contacts, SOS notifications,
  risk score, route deviation %, alert history — all stored in memory
  using a simple app-wide state class (`lib/data/app_state.dart`).
  Restarting the app resets this data.

## Folder structure

```
lib/
  main.dart                 # app entry + bottom nav
  theme.dart                 # colors & dark theme
  models/models.dart         # TrustedContact, AlertRecord
  data/app_state.dart        # in-memory "backend" (ChangeNotifier)
  screens/
    home_screen.dart         # SOS button + risk score
    safety_screen.dart       # live location, monitoring, route, fake call
    contacts_screen.dart     # trusted contacts CRUD
    history_screen.dart      # emergency history list
```

## Next steps to make it production-real

1. **Firebase**: create a project at console.firebase.google.com, add
   Android/iOS apps, download `google-services.json` /
   `GoogleService-Info.plist`, add `firebase_core`, `firebase_auth`,
   `cloud_firestore`, `firebase_messaging` to `pubspec.yaml`, then swap
   the in-memory lists in `app_state.dart` for Firestore reads/writes.
2. **Google Maps**: get a Maps API key, add `google_maps_flutter`, and
   replace the placeholder map box in `safety_screen.dart` with a real
   `GoogleMap` widget centered on `currentLat`/`currentLng`.
3. **SMS/Push to contacts**: wire `triggerSOS()` in `app_state.dart` to
   call Firebase Cloud Messaging or an SMS API instead of just adding a
   local history record.

I'm happy to do any of these next — just tell me which one (Firebase,
Google Maps, or SMS alerts) and I'll wire it in.
