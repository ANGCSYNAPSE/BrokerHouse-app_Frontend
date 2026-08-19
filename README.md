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
    home/                      ✅ bottom-nav shell (MainShell) + Home tab
    projects/                  ✅ Explore tab (property grid — mock data)
    leads/                     ✅ Leads tab (status-tabbed pipeline — mock data)
    users/                     ✅ Profile tab (real logout, rest is mock data)
    subscriptions/ payments/ builder_projects/
    builder_onboarding/ builder_leads/ site_visits/ bookings/
    earnings/ referrals/ notifications/ customer/ b2b/ crm/ admin/
    verification_center/       📋 scaffolded folders, each with a README
                                mapping it to its backend module — ready for
                                Figma screens to be dropped in following the
                                same data/application/presentation structure
                                as `features/auth`
```

The `auth` module is fully wired end-to-end against the live backend (send-otp → verify-otp → JWT issued → `/api/auth/me` → home) as a working reference implementation for the rest of the app.

## Known environment issue — Android builds (Windows dev machine)

Building/running on Android currently fails with:
```
java.io.IOException: Unable to establish loopback connection
```
This is a **machine-level bug**, not a code or Flutter issue — Java's `Pipe`/`Selector` implementation can't establish its internal AF_UNIX loopback socket on this Windows install, which blocks every Gradle invocation (confirmed independently of Flutter/React Native, with a minimal Java reproduction). `netsh winsock reset` + reboot — the standard fix for this class of error — did **not** resolve it, so the working plan is to run the Android/Gradle build step inside **WSL2** instead (a real Linux environment sidesteps the bug entirely; the emulator itself still runs on Windows). See project notes for current status.

## iOS — build & test on the Mac

The project is fully scaffolded for iOS (`ios/` directory, bundle ID `com.brokerhouse.brokerhouseApp`) and kept in sync with every screen as it's built — nothing iOS-specific needs to be written separately. To build/test on the Mac:

```bash
# 1. Clone the repo
git clone https://github.com/ANGCSYNAPSE/BrokerHouse-app_Frontend.git
cd BrokerHouse-app_Frontend

# 2. Install Flutter (if not already) — https://docs.flutter.dev/get-started/install/macos
flutter doctor -v   # make sure Xcode + CocoaPods show a checkmark

# 3. Get packages and install iOS pods
flutter pub get
cd ios && pod install && cd ..

# 4. Run on the iOS Simulator (or a plugged-in iPhone)
flutter run
```

The backend API needs to be reachable from the Mac too — either run `BrokerHouse_Backend` on the Mac itself, or point the app at wherever it's running via `flutter run --dart-define=API_BASE_URL=http://<windows-machine-LAN-IP>:5000/api` (the default `localhost` only works when frontend and backend run on the same machine).

Whenever new screens are added on the Windows side, `git pull` on the Mac picks them up immediately — same source, no port required.

## Testing

```bash
flutter analyze   # static analysis — currently 0 issues
flutter test      # widget tests
```

## Next steps

Ready for Figma screens — share them and each feature module gets built out following the same `data/application/presentation` pattern already established in `features/auth`.
