import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../application/auth_controller.dart';
import '../data/auth_providers.dart';
import '../data/social_auth_service.dart';
import 'widgets/auth_hero_banner.dart';

class PhoneEntryScreen extends ConsumerStatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  final _countryCode = '+91';
  bool _isSubmitting = false;
  String? _socialLoadingProvider;

  bool get _isPhoneValid => RegExp(r'^\d{10}$').hasMatch(_phoneController.text.trim());

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isPhoneValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid 10-digit mobile number')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).sendOtp(phone: _phoneController.text.trim(), countryCode: _countryCode);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.description)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _socialSignIn(String provider) async {
    setState(() => _socialLoadingProvider = provider);
    try {
      final social = ref.read(socialAuthServiceProvider);
      final idToken = provider == 'GOOGLE' ? await social.signInWithGoogle() : await social.signInWithApple();
      final isNewUser = await ref.read(authControllerProvider.notifier).socialLogin(provider: provider, idToken: idToken);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isNewUser ? 'Successfully registered!' : 'Welcome back!')),
        );
      }
    } on SocialSignInCancelled {
      // User backed out of the native picker/sheet — not an error.
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.description)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$provider sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _socialLoadingProvider = null);
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
            headline: 'Connect. Transact. Earn.',
            subtitle: 'Unlock direct access to top-tier builders & maximum commissions.',
          ),
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter your mobile number to begin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CountryCodeChip(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '98765 43210',
                            suffixIcon: _isPhoneValid ? const Icon(Icons.check_circle, color: AppColors.success) : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                      : const Text('Continue with OTP'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => context.push('/login-email'),
                    child: const Text('Login with Email instead', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR SIGN IN WITH', style: TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.5)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _socialLoadingProvider == null ? () => _socialSignIn('GOOGLE') : null,
                        icon: _socialLoadingProvider == 'GOOGLE'
                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('G', style: TextStyle(fontWeight: FontWeight.bold)),
                        label: const Text('Google'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _socialLoadingProvider == null ? () => _socialSignIn('APPLE') : null,
                        icon: _socialLoadingProvider == 'APPLE'
                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.apple, size: 18),
                        label: const Text('Apple'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('New to Broker House? ', style: TextStyle(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: const Text('Sign Up', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
