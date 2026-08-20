import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../application/auth_controller.dart';
import 'widgets/auth_hero_banner.dart';

class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  bool get _isEmailValid => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_emailController.text.trim());

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isEmailValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid email address')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).sendEmailOtp(email: _emailController.text.trim());
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
            headline: 'Welcome back.',
            subtitle: 'Log in with your registered email instead.',
          ),
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter your email to continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'vikram@royalbrokers.in',
                      suffixIcon: _isEmailValid ? const Icon(Icons.check_circle, color: AppColors.success) : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                      : const Text('Continue with OTP'),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: const Text('Login with Mobile Number instead', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
