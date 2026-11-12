import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/load_status.dart';
import '../../models/rain_station.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/formatters.dart';
import 'rain_level_style.dart';

class RainSummaryCard extends StatelessWidget {
  const RainSummaryCard({
    super.key,
    required this.status,
    required this.stations,
    required this.errorMessage,
    required this.onRetry,
    required this.onOpen,
  });

  final LoadStatus status;
  final List<RainStation> stations;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      LoadStatus.initial || LoadStatus.loading => const _Shell(
        icon: LucideIcons.cloudRain,
        title: 'Consultando as estações…',
        subtitle: 'Chuva da última hora, SIBH / SP Águas',
        trailing: SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      LoadStatus.error => _Shell(
        icon: LucideIcons.cloudOff,
        iconColor: AppColors.error,
        title: 'Chuva agora indisponível',
        subtitle: errorMessage ?? 'Não foi possível consultar as estações.',
        trailing: TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
      ),
      LoadStatus.success => _success(),
    };
  }

  Widget _success() {
    final raining = stations.where((station) => station.isRaining).toList();
    final top = raining.isEmpty ? null : raining.first;
    return _Shell(
      icon: raining.isEmpty ? LucideIcons.cloud : LucideIcons.cloudRain,
      iconColor: top?.level.color ?? AppColors.blue,
      title: raining.isEmpty
          ? 'Sem chuva nas estações agora'
          : '${raining.length} de ${stations.length} estações com chuva',
      subtitle: top == null
          ? '${stations.length} estações consultadas na última hora'
          : 'Maior acumulado: ${top.name} (${Formatters.millimeters(top.rainfall)})',
      trailing: const Icon(LucideIcons.chevronRight, size: 19, color: AppColors.subtle),
      onTap: onOpen,
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.iconColor = AppColors.blue,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 21, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.strong),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.small, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    ),
  );
}
