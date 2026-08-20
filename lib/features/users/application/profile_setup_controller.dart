import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../auth/application/auth_controller.dart';
import '../data/users_providers.dart';

enum Specialization { residential, commercial, both }

extension SpecializationApiValue on Specialization {
  String get apiValue => switch (this) {
        Specialization.residential => 'residential',
        Specialization.commercial => 'commercial',
        Specialization.both => 'both',
      };
}

final profileSetupControllerProvider = AsyncNotifierProvider<ProfileSetupController, void>(ProfileSetupController.new);

class ProfileSetupController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> submit({
    required String fullName,
    required String email,
    required String reraNumber,
    required String companyName,
    required Specialization specialization,
    File? photo,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // TEMPORARY (see Env.useMockAuth): mock-session users have no real
      // backend record to save against — just advance the flow locally.
      if (Env.useMockAuth && ref.read(authControllerProvider).user?.id == 'mock-user') {
        ref.read(authControllerProvider.notifier).markProfileComplete();
        return;
      }

      final repo = ref.read(usersRepositoryProvider);
      await repo.completeProfile(
        fullName: fullName,
        email: email,
        reraNumber: reraNumber,
        companyName: companyName,
        specialization: specialization.apiValue,
        role: 'BROKER',
      );
      if (photo != null) {
        await repo.uploadProfilePhoto(photo);
      }
      ref.read(authControllerProvider.notifier).markProfileComplete();
    });
  }
}
