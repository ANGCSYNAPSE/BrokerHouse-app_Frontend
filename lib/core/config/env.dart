import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Central place for environment-dependent config. The API base URL is
/// resolved automatically per platform so `flutter run` "just works" against
/// the local backend without any manual editing:
///  - Android emulator can't reach the host via `localhost` — it must use
///    the special `10.0.2.2` alias instead.
///  - iOS simulator and desktop/web can use `localhost` directly.
///  - A physical device needs your machine's LAN IP, or (for production)
///    the real deployed API URL — override with `--dart-define=API_BASE_URL=...`.
class Env {
  Env._();

  static const _override = String.fromEnvironment('API_BASE_URL');

  static const _devPort = 5000;

  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;

    if (kIsWeb) return 'http://localhost:$_devPort/api';

    if (Platform.isAndroid) return 'http://10.0.2.2:$_devPort/api';

    // iOS simulator, desktop, etc.
    return 'http://localhost:$_devPort/api';
  }

  // Social sign-in — public client identifiers (not secrets), but real
  // values from Google Cloud Console / Apple Developer are required before
  // either button will actually work. Override with
  // --dart-define=GOOGLE_SERVER_CLIENT_ID=..., etc. See auth.routes.ts and
  // .env.example on the backend for what each ID is and where to get it.
  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
  static const appleServiceId = String.fromEnvironment('APPLE_SERVICE_ID');
  static const appleRedirectUri = String.fromEnvironment('APPLE_REDIRECT_URI');

  static const isProduction = bool.fromEnvironment('dart.vm.product');

  /// Dev convenience: send-otp/signup/resend calls swallow network errors
  /// instead of throwing, so screen flow can be reviewed even with the
  /// backend unreachable. OTP *verification* always hits the real API
  /// regardless of this flag — there is no client-side OTP bypass. Tied to
  /// `!isProduction`, a compile-time constant derived from
  /// `dart.vm.product`, so a real `flutter build --release` always compiles
  /// this to `false`.
  static const useMockAuth = !isProduction;
}
