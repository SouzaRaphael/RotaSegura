import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/app_colors.dart';

enum NoticeTone { info, warning, success, error }

class NoticeBox extends StatelessWidget {
  const NoticeBox({super.key, required this.text, this.tone = NoticeTone.info, this.icon, this.title});

  final String text;
  final String? title;
  final NoticeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground, IconData defaultIcon) = switch (tone) {
      NoticeTone.info => (AppColors.noticeBg, AppColors.muted, LucideIcons.info),
      NoticeTone.warning => (AppColors.warningBg, AppColors.warningText, LucideIcons.triangleAlert),
      NoticeTone.success => (AppColors.successBg, AppColors.successText, LucideIcons.circleCheck),
      NoticeTone.error => (AppColors.errorBg, AppColors.error, LucideIcons.circleAlert),
    };
    return Semantics(
      liveRegion: tone != NoticeTone.info,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon ?? defaultIcon, size: 17, color: foreground),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    if (title != null) TextSpan(text: '$title ', style: const TextStyle(fontWeight: FontWeight.w800)),
                    TextSpan(text: text),
                  ],
                ),
                style: TextStyle(fontSize: 12.5, height: 1.5, color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
