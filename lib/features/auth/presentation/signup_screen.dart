import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../application/auth_controller.dart';
import 'widgets/auth_hero_banner.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryCode = '+91';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).signup(
            phone: _phoneController.text.trim(),
            countryCode: _countryCode,
            email: _emailController.text.trim(),
          );
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.description)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeroBanner(
            headline: 'Join Broker House.',
            subtitle: 'Create your account to start connecting with top-tier builders.',
          ),
          AuthCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create your account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  const _FieldLabel('MOBILE NUMBER'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CountryCodeChip(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            decoration: const InputDecoration(counterText: '', hintText: '98765 43210'),
                            validator: (v) => RegExp(r'^\d{10}$').hasMatch(v?.trim() ?? '') ? null : 'Enter a valid 10-digit mobile number',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _FieldLabel('EMAIL ADDRESS'),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'vikram@royalbrokers.in'),
                    validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '') ? null : 'Enter a valid email address',
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                        : const Text('Create Account'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary)),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text('Log In', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
