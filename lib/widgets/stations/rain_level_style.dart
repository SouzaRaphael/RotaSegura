import 'package:flutter/material.dart';

import '../../models/rain_level.dart';
import '../../theme/app_colors.dart';

extension RainLevelStyle on RainLevel {
  Color get color => switch (this) {
    RainLevel.none => AppColors.rainNone,
    RainLevel.light => AppColors.rainLight,
    RainLevel.moderate => AppColors.rainModerate,
    RainLevel.heavy => AppColors.rainHeavy,
    RainLevel.veryHeavy => AppColors.rainVeryHeavy,
  };
}

class RainLevelBadge extends StatelessWidget {
  const RainLevelBadge({super.key, required this.level});

  final RainLevel level;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: level.color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: level.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          level.label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: Color.lerp(level.color, AppColors.navy, 0.35),
          ),
        ),
      ],
    ),
  );
}

class StaleBadge extends StatelessWidget {
  const StaleBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(20)),
    child: const Text(
      'Leitura antiga',
      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.warningText),
    ),
  );
}
