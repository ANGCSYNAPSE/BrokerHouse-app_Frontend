import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/brand_logo.dart';

/// The navy/gold building-photo header shared by the login, signup, and
/// email-login screens (see assets/login-hero-photo.png).
class AuthHeroBanner extends StatelessWidget {
  const AuthHeroBanner({super.key, required this.headline, required this.subtitle});

  final String headline;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
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
                        headline,
                        style: GoogleFonts.playfairDisplay(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(subtitle, style: TextStyle(color: AppColors.slate.withValues(alpha: 0.9), fontSize: 13)),
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

/// The card container below [AuthHeroBanner] — white, rounded top corners,
/// fills the remaining screen height, scrolls its content when needed.
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// The "🇮🇳 +91" country-code chip used next to phone number fields.
class CountryCodeChip extends StatelessWidget {
  const CountryCodeChip({super.key, this.code = '+91'});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇮🇳', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(code, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
