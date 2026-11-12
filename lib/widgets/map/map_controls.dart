import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class MapStatusChip extends StatelessWidget {
  const MapStatusChip({super.key, required this.icon, required this.text, this.loading = false});

  final IconData icon;
  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x20173B6C), blurRadius: 18, offset: Offset(0, 6))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
          else
            Icon(icon, size: 18, color: AppColors.blue),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.navy),
            ),
          ),
        ],
      ),
    ),
  );
}

class MapRoundButton extends StatelessWidget {
  const MapRoundButton({super.key, required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.white,
    shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
    elevation: 3,
    shadowColor: const Color(0x40173B6C),
    child: IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 20, color: AppColors.navy),
    ),
  );
}
