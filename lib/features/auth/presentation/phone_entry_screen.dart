import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/brand_logo.dart';
import '../application/auth_controller.dart';

class PhoneEntryScreen extends ConsumerStatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  final _countryCode = '+91';
  bool _isSubmitting = false;

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

  void _socialComingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$provider sign-in is coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 402 / 240,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/login-hero-photo.png', fit: BoxFit.cover),
                Container(color: AppColors.navy.withValues(alpha: 0.85)),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BrandLogo(width: 150),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connect. Transact. Earn.',
                              style: GoogleFonts.playfairDisplay(
                                color: AppColors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Unlock direct access to top-tier builders & maximum commissions.',
                              style: TextStyle(color: AppColors.slate.withValues(alpha: 0.9), fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
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
                          Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                SizedBox(width: 6),
                                Text('+91', style: TextStyle(fontWeight: FontWeight.w600)),
                                Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textMuted),
                              ],
                            ),
                          ),
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
                                  suffixIcon: _isPhoneValid
                                      ? const Icon(Icons.check_circle, color: AppColors.success)
                                      : null,
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
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy),
                              )
                            : const Text('Continue with OTP'),
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
                              onPressed: () => _socialComingSoon('Google'),
                              icon: const Text('G', style: TextStyle(fontWeight: FontWeight.bold)),
                              label: const Text('Google'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _socialComingSoon('Apple'),
                              icon: const Icon(Icons.apple, size: 18),
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
                            onTap: _isSubmitting ? null : _submit,
                            child: const Text('Sign Up', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
