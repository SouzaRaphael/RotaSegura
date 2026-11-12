import 'package:flutter/material.dart';

import '../../theme/app_text.dart';

class PageTitle extends StatelessWidget {
  const PageTitle({super.key, this.overline, required this.title, this.intro, this.trailing});

  final String? overline;
  final String title;
  final String? intro;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overline != null) ...[Text(overline!, style: AppText.overline), const SizedBox(height: 6)],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Semantics(header: true, child: Text(title, style: AppText.h1)),
            ),
            ?trailing,
          ],
        ),
        if (intro != null) ...[const SizedBox(height: 8), Text(intro!, style: AppText.intro)],
      ],
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, this.overline, required this.title, this.action});

  final String? overline;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overline != null) ...[Text(overline!, style: AppText.overline), const SizedBox(height: 3)],
              Semantics(header: true, child: Text(title, style: AppText.h2)),
            ],
          ),
        ),
        ?action,
      ],
    ),
  );
}
