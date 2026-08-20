import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import 'auth_repository.dart';
import 'social_auth_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider), ref.watch(tokenStorageProvider));
});

final socialAuthServiceProvider = Provider<SocialAuthService>((ref) => SocialAuthService());
