import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../application/auth_controller.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _otpController = TextEditingController(text: Env.useMockAuth ? Env.mockOtp : null);
  bool _isSubmitting = false;
  bool _isResending = false;
  Timer? _timer;
  int _secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    if (code.length < 4) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).verifyOtp(code);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.description)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      await ref.read(authControllerProvider.notifier).resendOtp();
      _startTimer();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP resent')));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.description)));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  String get _timerLabel => '00:${_secondsLeft.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final phoneLabel = '${authState.pendingCountryCode ?? ''} ${authState.pendingPhone ?? ''}';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        titleSpacing: 24,
        title: InkWell(
          onTap: () => ref.read(authControllerProvider.notifier).backToPhoneEntry(),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, size: 18, color: AppColors.textPrimary),
              SizedBox(width: 8),
              Text('Back to Login', style: TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Text('Verification Code', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  children: [
                    TextSpan(text: 'We sent a 4-digit OTP to $phoneLabel '),
                    TextSpan(
                      text: 'Edit Number',
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => ref.read(authControllerProvider.notifier).backToPhoneEntry(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PinCodeTextField(
                appContext: context,
                length: 4,
                controller: _otpController,
                keyboardType: TextInputType.number,
                autoFocus: true,
                animationType: AnimationType.none,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 52,
                  fieldWidth: 52,
                  activeColor: AppColors.gold,
                  selectedColor: AppColors.gold,
                  inactiveColor: AppColors.border,
                  activeFillColor: AppColors.white,
                  selectedFillColor: AppColors.white,
                  inactiveFillColor: AppColors.white,
                ),
                enableActiveFill: true,
                onChanged: (_) {},
                onCompleted: _verify,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : () => _verify(_otpController.text),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                    : const Text('Verify OTP'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Didn't receive code?", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  if (_secondsLeft > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text('Resend in $_timerLabel', style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    )
                  else
                    TextButton(
                      onPressed: _isResending ? null : _resend,
                      child: Text(_isResending ? 'Resending…' : 'Resend OTP'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
