# BrokrsHouse — Flutter App

Cross-platform (Android + iOS) client for the BrokrsHouse real-estate platform, targeting Play Store and App Store release.

## Stack

- **Framework**: Flutter 3.47.0 (stable), Dart 3.13
- **State management**: Riverpod (`flutter_riverpod`)
- **Networking**: Dio, with an interceptor that attaches the JWT access token to every request and transparently refreshes it (via `POST /api/auth/refresh-token`) on a 401, matching the backend's rotate-on-refresh flow
- **Routing**: `go_router`, redirecting based on auth state (splash → login → OTP → home)
- **Token storage**: `flutter_secure_storage` (encrypted at rest — never SharedPreferences for tokens)
- **Backend**: [`BrokerHouse_Backend`](../BrokerHouse_Backend) — see that project's README for API docs (Swagger at `/api-docs`)

## Getting started

```bash
# One-time: make sure Flutter is on PATH
flutter doctor -v

flutter pub get
flutter run
```

The API base URL is resolved automatically per platform in `lib/core/config/env.dart`:
- Android emulator → `http://10.0.2.2:5000/api` (the special alias for the host machine)
- iOS simulator / desktop → `http://localhost:5000/api`
- Override for a physical device or production: `flutter run --dart-define=API_BASE_URL=https://your-api.example.com/api`

Make sure the backend (`BrokerHouse_Backend`) is running on port 5000 before you launch the app — `cd ../BrokerHouse_Backend && npm run dev`.

## Project layout

```
lib/
  main.dart                    ProviderScope + MaterialApp.router wiring
  core/
    config/env.dart            per-platform API base URL
    network/
      api_client.dart          Dio + JWT attach/refresh interceptor
      token_storage.dart       secure storage wrapper
      api_exception.dart       typed error matching {success,description,errors}
      providers.dart           Riverpod providers for the above
    router/app_router.dart     go_router, redirects driven by auth state
    theme/app_theme.dart       light/dark theme (placeholder brand tokens)
    widgets/                   shared widgets (splash screen, etc.)
  features/
    auth/                      ✅ fully built — phone+OTP login against the real API
      data/                    repository + models
      application/             Riverpod controller + state
      presentation/            screens
    home/                      ✅ placeholder post-login screen
    users/ subscriptions/ payments/ projects/ builder_projects/
    builder_onboarding/ leads/ builder_leads/ site_visits/ bookings/
    earnings/ referrals/ notifications/ customer/ b2b/ crm/ admin/
    verification_center/       📋 scaffolded folders, each with a README
                                mapping it to its backend module — ready for
                                Figma screens to be dropped in following the
                                same data/application/presentation structure
                                as `features/auth`
```

The `auth` module is fully wired end-to-end against the live backend (send-otp → verify-otp → JWT issued → `/api/auth/me` → home) as a working reference implementation for the rest of the app.

## Known environment issue — Android builds

Building/running on Android currently fails with:
```
java.io.IOException: Unable to establish loopback connection
```
This is a **machine-level bug**, not a code or Flutter issue — Java's `Pipe`/`Selector` implementation can't establish its internal AF_UNIX loopback socket on this Windows install, which blocks every Gradle invocation (confirmed independently of Flutter/React Native, with a minimal Java reproduction). The fix (needs to be run once, as Administrator):

```powershell
netsh winsock reset
```
...then **reboot**. Once that's done, `flutter run` (with an emulator running, e.g. `emulator -avd Pixel_8`) or `flutter build apk` should work normally.

## iOS

iOS builds require Xcode, which only runs on macOS — not available on this Windows machine. The project is fully scaffolded for iOS (`ios/` directory, bundle ID `com.brokerhouse.brokerhouseApp`); building/testing/signing for TestFlight and the App Store will need a Mac (physical, a cloud Mac service like Codemagic/Ionic Appflow, or a CI macOS runner).

## Testing

```bash
flutter analyze   # static analysis — currently 0 issues
flutter test      # widget tests
```

## Next steps

Ready for Figma screens — share them and each feature module gets built out following the same `data/application/presentation` pattern already established in `features/auth`.
