import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../navigation/app_navigation.dart';
import '../../navigation/app_routes.dart';
import '../../theme/app_colors.dart';
import '../common/logo.dart';

class MenuEntry {
  const MenuEntry(this.route, this.label, this.icon);

  final String route;
  final String label;
  final IconData icon;
}

const menuEntries = <MenuEntry>[
  MenuEntry(AppRoutes.home, 'Mapa e rotas', LucideIcons.mapPinned),
  MenuEntry(AppRoutes.stations, 'Chuva agora', LucideIcons.cloudRain),
  MenuEntry(AppRoutes.savedRoutes, 'Minhas rotas', LucideIcons.bookmark),
  MenuEntry(AppRoutes.profile, 'Perfil e preferências', LucideIcons.user),
  MenuEntry(AppRoutes.sources, 'Fontes e metodologia', LucideIcons.bookOpen),
];

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key, required this.section});

  final String section;

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.white,
    child: SafeArea(
      bottom: false,
      child: Container(
        height: 62,
        padding: const EdgeInsets.only(left: 20, right: 8),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: section == AppRoutes.home ? null : () => AppNavigation.openSection(context, AppRoutes.home),
              child: const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: AppLogo()),
            ),
            const Spacer(),
            _MainMenuButton(section: section),
          ],
        ),
      ),
    ),
  );
}

class _MainMenuButton extends StatelessWidget {
  const _MainMenuButton({required this.section});

  final String section;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: 'Abrir menu',
    icon: const Icon(LucideIcons.menu, color: AppColors.navy),
    offset: const Offset(0, 52),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 8,
    onSelected: (route) {
      if (route != section) AppNavigation.openSection(context, route);
    },
    itemBuilder: (context) => [
      for (final entry in menuEntries)
        PopupMenuItem<String>(
          value: entry.route,
          height: 48,
          child: _MenuItemContent(entry: entry, active: entry.route == section),
        ),
    ],
  );
}

class _MenuItemContent extends StatelessWidget {
  const _MenuItemContent({required this.entry, required this.active});

  final MenuEntry entry;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.blue : AppColors.navy;
    return Semantics(
      selected: active,
      child: Row(
        children: [
          Icon(entry.icon, size: 19, color: color),
          const SizedBox(width: 12),
          Text(
            entry.label,
            style: TextStyle(fontSize: 14, fontWeight: active ? FontWeight.w800 : FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
