import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/application/auth_controller.dart';
import '../application/profile_setup_controller.dart';

class BrokerProfileSetupScreen extends ConsumerStatefulWidget {
  const BrokerProfileSetupScreen({super.key});

  @override
  ConsumerState<BrokerProfileSetupScreen> createState() => _BrokerProfileSetupScreenState();
}

class _BrokerProfileSetupScreenState extends ConsumerState<BrokerProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _reraController = TextEditingController();
  final _companyController = TextEditingController();
  Specialization _specialization = Specialization.both;
  File? _photo;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _reraController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(profileSetupControllerProvider.notifier).submit(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          reraNumber: _reraController.text.trim(),
          companyName: _companyController.text.trim(),
          specialization: _specialization,
          photo: _photo,
        );
    final error = ref.read(profileSetupControllerProvider).error;
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(authControllerProvider).user?.phone;
    final countryCode = ref.watch(authControllerProvider).user?.countryCode;
    final isSubmitting = ref.watch(profileSetupControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Complete Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const Text('Step 1 of 3', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: 1 / 3,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.surfaceMuted,
                        backgroundImage: _photo != null ? FileImage(_photo!) : null,
                        child: _photo == null ? const Icon(Icons.person_add_alt, color: AppColors.gold) : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Upload Professional Photo', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(
                            'Helps premium builders recognize your registered agency profile.',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _FieldLabel('FULL NAME'),
                TextFormField(
                  controller: _fullNameController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                ),
                const SizedBox(height: 18),
                _FieldLabel('EMAIL ADDRESS'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'vikram@royalbrokers.in'),
                ),
                const SizedBox(height: 18),
                _FieldLabel('PHONE NUMBER'),
                TextFormField(
                  enabled: false,
                  initialValue: phone != null ? '$countryCode $phone' : '',
                  decoration: const InputDecoration(suffixIcon: Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted)),
                ),
                const SizedBox(height: 18),
                _FieldLabel('RERA REGISTRATION NUMBER'),
                TextFormField(
                  controller: _reraController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(hintText: 'RERA-MH-12345678'),
                ),
                const SizedBox(height: 18),
                _FieldLabel('COMPANY / AGENCY NAME'),
                TextFormField(controller: _companyController),
                const SizedBox(height: 18),
                _FieldLabel('SPECIALIZATION'),
                Row(
                  children: [
                    Expanded(child: _SpecializationChip(label: 'Residential', value: Specialization.residential, group: _specialization, onSelect: (v) => setState(() => _specialization = v))),
                    const SizedBox(width: 8),
                    Expanded(child: _SpecializationChip(label: 'Commercial', value: Specialization.commercial, group: _specialization, onSelect: (v) => setState(() => _specialization = v))),
                    const SizedBox(width: 8),
                    Expanded(child: _SpecializationChip(label: 'Both', value: Specialization.both, group: _specialization, onSelect: (v) => setState(() => _specialization = v))),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  child: isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                      : const Text('Complete Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.4)),
    );
  }
}

class _SpecializationChip extends StatelessWidget {
  const _SpecializationChip({required this.label, required this.value, required this.group, required this.onSelect});

  final String label;
  final Specialization value;
  final Specialization group;
  final ValueChanged<Specialization> onSelect;

  @override
  Widget build(BuildContext context) {
    final selected = value == group;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : AppColors.white,
          border: Border.all(color: selected ? AppColors.navy : AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? AppColors.white : AppColors.textPrimary),
        ),
      ),
    );
  }
}
