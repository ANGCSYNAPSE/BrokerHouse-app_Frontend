import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/config/env.dart';

/// Thrown when the user closes the native sign-in sheet without completing
/// it — distinct from a real failure so the UI can stay silent instead of
/// showing an error snackbar.
class SocialSignInCancelled implements Exception {}

/// Wraps the native Google/Apple SDKs and returns just what
/// `POST /auth/social-login` needs: the provider name and an ID token for
/// the backend to verify server-side (see socialAuth.ts). Neither SDK call
/// touches our backend directly — the ID token is the only thing that
/// crosses the wire to us.
class SocialAuthService {
  final _googleSignIn = GoogleSignIn(
    scopes: const ['email'],
    // Requests an ID token addressed to this Web client ID so the backend
    // can verify it regardless of whether sign-in happened on Android or
    // iOS. Empty (unconfigured) client ID makes google_sign_in itself throw
    // a clear "developer error" — see Env.googleServerClientId doc comment.
    serverClientId: Env.googleServerClientId.isEmpty ? null : Env.googleServerClientId,
  );

  /// Returns the Google ID token, or throws [SocialSignInCancelled] if the
  /// user backs out of the picker.
  Future<String> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw SocialSignInCancelled();
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw StateError('Google did not return an ID token — check GOOGLE_SERVER_CLIENT_ID is a Web client ID');
    }
    return idToken;
  }

  /// Returns the Apple identity token (a JWT), or throws
  /// [SocialSignInCancelled] if the user backs out of the sheet. On Android
  /// this drives Apple's web-based OAuth flow, so it requires
  /// [Env.appleServiceId]/[Env.appleRedirectUri] to be configured — see
  /// their doc comments in env.dart.
  Future<String> signInWithApple() async {
    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: hashedNonce,
        webAuthenticationOptions: Env.appleServiceId.isEmpty
            ? null
            : WebAuthenticationOptions(clientId: Env.appleServiceId, redirectUri: Uri.parse(Env.appleRedirectUri)),
      );
      return credential.identityToken ?? (throw StateError('Apple did not return an identity token'));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) throw SocialSignInCancelled();
      rethrow;
    }
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }
}
