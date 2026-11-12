import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/route_analysis.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/formatters.dart';

class RouteCard extends StatelessWidget {
  const RouteCard({
    super.key,
    required this.analysis,
    required this.fastestMinutes,
    required this.selected,
    required this.forecastHours,
    required this.onTap,
  });

  final RouteAnalysis analysis;
  final int fastestMinutes;
  final bool selected;
  final int forecastHours;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final route = analysis.route;
    final recommended = analysis.isRecommended;
    final borderColor = selected
        ? (recommended ? AppColors.blue : AppColors.amber)
        : (recommended ? const Color(0xFFB8D0FA) : AppColors.border);
    final extra = route.minutes - fastestMinutes;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        selected: selected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF8FBFF) : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
            boxShadow: selected
                ? const [BoxShadow(color: Color(0x1A1763E9), blurRadius: 16, offset: Offset(0, 6))]
                : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Radio(selected: selected),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(analysis.label, style: AppText.strong),
                              if (recommended) const _Badge.recommended(),
                              if (analysis.hasHigherExposure) const _Badge.exposure(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(Formatters.minutes(route.minutes), style: AppText.stat(size: 22)),
                              const SizedBox(width: 8),
                              Text(
                                '${Formatters.kilometers(route.kilometers)}'
                                '${extra > 0 ? ' · $extra min a mais' : ''}',
                                style: AppText.small,
                              ),
                            ],
                          ),
                          if (route.summary.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Via ${route.summary}',
                              style: AppText.small,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 10),
                          _ExposureLine(
                            icon: LucideIcons.cloudRain,
                            text: analysis.observedRain == null
                                ? 'Chuva observada indisponível'
                                : analysis.observedRain! > 0
                                ? 'Até ${Formatters.millimeters(analysis.observedRain!)} na última hora perto do trajeto'
                                : 'Sem chuva nas estações próximas',
                          ),
                          _ExposureLine(
                            icon: LucideIcons.cloudSunRain,
                            text: analysis.forecastRain == null
                                ? 'Previsão indisponível'
                                : 'Previsão: ${Formatters.millimeters(analysis.forecastRain!)} '
                                      'nas próximas $forecastHours h (${analysis.forecastProbability ?? 0}%)',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    margin: const EdgeInsets.only(top: 2),
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: selected ? AppColors.blue : const Color(0xFFA4B4CB), width: selected ? 6 : 2),
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge.recommended()
    : text = '✓ Recomendada',
      background = AppColors.recommendedBg,
      foreground = AppColors.recommendedText;

  const _Badge.exposure()
    : text = '⚠ Maior exposição',
      background = AppColors.riskBadgeBg,
      foreground = AppColors.riskBadgeText;

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: foreground)),
  );
}

class _ExposureLine extends StatelessWidget {
  const _ExposureLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 1), child: Icon(icon, size: 14, color: AppColors.subtle)),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: AppText.small.copyWith(color: AppColors.label))),
      ],
    ),
  );
}
