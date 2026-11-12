import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/rain_station.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/formatters.dart';
import '../common/favorite_button.dart';
import 'rain_level_style.dart';

class StationTile extends StatelessWidget {
  const StationTile({
    super.key,
    required this.station,
    required this.now,
    required this.onTap,
    this.isFavorite,
    this.onToggleFavorite,
    this.distanceMeters,
  });

  final RainStation station;
  final DateTime now;
  final VoidCallback onTap;

  final bool? isFavorite;
  final VoidCallback? onToggleFavorite;

  final double? distanceMeters;

  @override
  Widget build(BuildContext context) {
    final stale = station.isStale(now);
    final subtitle = [
      if (distanceMeters != null) 'a ${Formatters.meters(distanceMeters!)} do trajeto',
      if (station.basin.isNotEmpty) station.basin,
      'até ${Formatters.time(station.periodEnd)}',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Row(
              children: [
                _RainValue(station: station),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(station.name, style: AppText.strong, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(subtitle, style: AppText.small, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [RainLevelBadge(level: station.level), if (stale) const StaleBadge()],
                      ),
                    ],
                  ),
                ),
                if (isFavorite != null && onToggleFavorite != null)
                  FavoriteButton(isFavorite: isFavorite!, onPressed: onToggleFavorite!)
                else
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(LucideIcons.chevronRight, size: 18, color: AppColors.placeholder),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RainValue extends StatelessWidget {
  const _RainValue({required this.station});

  final RainStation station;

  @override
  Widget build(BuildContext context) {
    final color = station.level.color;
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            Formatters.decimal(station.rainfall),
            style: AppText.stat(size: 18, color: Color.lerp(color, AppColors.navy, 0.3)!),
          ),
          const Text('mm/h', style: TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
