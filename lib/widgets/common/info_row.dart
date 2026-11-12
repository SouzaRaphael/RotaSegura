import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: AppColors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.small),
              const SizedBox(height: 2),
              Text(value, style: AppText.strong),
            ],
          ),
        ),
      ],
    ),
  );
}

class SourceLine extends StatelessWidget {
  const SourceLine({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Icon(icon, size: 15, color: AppColors.subtle),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: AppText.small)),
      ],
    ),
  );
}
