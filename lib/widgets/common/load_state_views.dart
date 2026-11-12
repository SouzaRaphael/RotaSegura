import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import 'app_buttons.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          const SizedBox.square(dimension: 34, child: CircularProgressIndicator(strokeWidth: 3)),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: AppText.intro),
        ],
      ),
    ),
  );
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.title, required this.message, required this.onRetry});

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.cloudOff, size: 32, color: AppColors.error),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: AppText.strong.copyWith(color: AppColors.error)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: AppText.body.copyWith(color: AppColors.error)),
          const SizedBox(height: 16),
          SecondaryButton(label: 'Tentar novamente', icon: LucideIcons.refreshCw, onPressed: onRetry),
        ],
      ),
    ),
  );
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.icon, required this.title, required this.message, this.action});

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 12),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.lightBlueBg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(color: AppColors.iconBlueBg, borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: AppColors.blue, size: 26),
        ),
        const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center, style: AppText.h3),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center, style: AppText.intro),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    ),
  );
}
