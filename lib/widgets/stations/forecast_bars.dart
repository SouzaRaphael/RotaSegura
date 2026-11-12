import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/rain_forecast.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/formatters.dart';

class ForecastBars extends StatelessWidget {
  const ForecastBars({super.key, required this.forecast});

  final RainForecast forecast;

  static const _barAreaHeight = 90.0;

  @override
  Widget build(BuildContext context) {
    final hours = forecast.hours;
    final maxValue = math.max(2.0, hours.fold<double>(0, (m, hour) => math.max(m, hour.precipitation)));
    return Semantics(
      label: hours
          .map((hour) => '${Formatters.hourLabel(hour.time)}: ${Formatters.millimeters(hour.precipitation)}')
          .join(', '),
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final hour in hours)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hour.precipitation > 0 ? Formatters.decimal(hour.precipitation) : '',
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.label),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      height: math.max(3, _barAreaHeight * hour.precipitation / maxValue),
                      decoration: BoxDecoration(
                        color: hour.precipitation > 0 ? AppColors.rainLight : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(Formatters.hourLabel(hour.time), style: AppText.footnote.copyWith(fontSize: 9.5)),
                    if (hour.probability != null)
                      Text(
                        '${hour.probability}%',
                        style: AppText.footnote.copyWith(fontSize: 9, color: AppColors.subtle),
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
