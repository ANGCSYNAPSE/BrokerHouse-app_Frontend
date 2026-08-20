import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'brand_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const BrandLogo(width: 220),
              const Spacer(flex: 2),
              Text(
                'Your Gateway to Premium Real\nEstate Deals',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Container(width: 48, height: 2, color: AppColors.gold),
              const Spacer(flex: 3),
              Text(
                'Exclusively for Certified Builders & Registered Brokers',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.slate.withValues(alpha: 0.8), fontSize: 12),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
