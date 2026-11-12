import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class FactorTile extends StatelessWidget {
  const FactorTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.details,
    required this.expanded,
    required this.onTap,
    this.warning = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<String> details;
  final bool expanded;
  final VoidCallback onTap;

  final bool warning;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Semantics(
      button: true,
      expanded: expanded,
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: expanded ? AppColors.secondaryBorder : AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: warning ? AppColors.amberIconBg : AppColors.iconBlueBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 20, color: warning ? AppColors.amber : AppColors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppText.strong),
                      const SizedBox(height: 3),
                      Text(description, style: AppText.small.copyWith(color: AppColors.label)),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment.topLeft,
                        child: expanded
                            ? Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.noticeBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final detail in details)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text(detail, style: AppText.small),
                                      ),
                                  ],
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.subtle),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
