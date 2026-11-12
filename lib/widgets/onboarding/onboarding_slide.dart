import 'package:flutter/material.dart';

import '../../data/onboarding_pages.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({super.key, required this.page});

  final OnboardingPageData page;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF49A6FF), Color(0xFF0751DD)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [BoxShadow(color: Color(0x401763E9), blurRadius: 24, offset: Offset(0, 12))],
          ),
          child: Icon(page.icon, size: 44, color: AppColors.white),
        ),
        const SizedBox(height: 36),
        Semantics(header: true, child: Text(page.title, style: AppText.h1.copyWith(fontSize: 28))),
        const SizedBox(height: 14),
        Text(page.description, style: AppText.intro.copyWith(fontSize: 15.5)),
      ],
    ),
  );
}

class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Página ${current + 1} de $count',
    excludeSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == current ? AppColors.blue : AppColors.handle,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    ),
  );
}
