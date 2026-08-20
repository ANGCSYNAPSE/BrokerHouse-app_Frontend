import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/widgets.dart';

/// The "BROKER HOUSE / PREMIUM B2B ALLIANCE" wordmark, exported from Figma
/// as `assets/brand-logo.svg` (240x47 native size).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.width = 200});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/brand-logo.svg',
      width: width,
      fit: BoxFit.fitWidth,
    );
  }
}
