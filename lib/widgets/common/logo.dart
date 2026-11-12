import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.scale = 1, this.showName = true});

  final double scale;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final size = 32.0 * scale;
    return Semantics(
      label: 'Rota Segura',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: -math.pi / 4,
            child: Container(
              width: size,
              height: size * 1.06,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF49A6FF), Color(0xFF0751DD)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.55),
                  topRight: Radius.circular(size * 0.55),
                  bottomRight: Radius.circular(size * 0.55),
                  bottomLeft: Radius.circular(size * 0.12),
                ),
              ),
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Icon(LucideIcons.droplets, size: 18 * scale, color: AppColors.white),
              ),
            ),
          ),
          if (showName) ...[
            SizedBox(width: 10 * scale),
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(text: 'Rota '),
                  TextSpan(text: 'Segura', style: TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              style: TextStyle(
                fontFamily: AppText.headingFamily,
                fontSize: 19 * scale,
                letterSpacing: -1,
                color: AppColors.navy,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
