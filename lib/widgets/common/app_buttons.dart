import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.loading = false});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 50,
    child: FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.blue,
        disabledBackgroundColor: AppColors.blue.withValues(alpha: 0.45),
        foregroundColor: AppColors.white,
        disabledForegroundColor: AppColors.white,
        textStyle: AppText.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: loading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.white),
            )
          : _ButtonContent(label: label, icon: icon),
    ),
  );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon, this.danger = false});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.blue;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: AppColors.white,
          side: BorderSide(color: danger ? AppColors.error.withValues(alpha: 0.35) : AppColors.secondaryBorder),
          textStyle: AppText.button,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _ButtonContent(label: label, icon: icon),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
      Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
    ],
  );
}

class BackLink extends StatelessWidget {
  const BackLink({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: TextButton.icon(
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      icon: const Icon(LucideIcons.arrowLeft, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.blue,
        textStyle: AppText.button,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        minimumSize: const Size(44, 44),
      ),
    ),
  );
}

class LinkButton extends StatelessWidget {
  const LinkButton({super.key, required this.label, required this.onPressed, this.icon = LucideIcons.arrowRight});

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: AppColors.blue,
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      minimumSize: const Size(44, 44),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [Text(label), const SizedBox(width: 4), Icon(icon, size: 16)],
    ),
  );
}
