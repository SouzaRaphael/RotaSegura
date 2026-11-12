import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import 'app_header.dart';

class PageScaffold extends StatelessWidget {
  const PageScaffold({super.key, required this.section, required this.children, this.onRefresh});

  final String section;
  final List<Widget> children;

  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
      children: [...children, const AppFooter()],
    );
    return Scaffold(
      appBar: AppHeader(section: section),
      body: SafeArea(top: false, child: onRefresh == null ? list : RefreshIndicator(onRefresh: onRefresh!, child: list)),
    );
  }
}

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 28),
    padding: const EdgeInsets.only(top: 16),
    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
    child: const Text(
      'Feito para decisões mais informadas · São Paulo, SP',
      textAlign: TextAlign.center,
      style: AppText.footnote,
    ),
  );
}
