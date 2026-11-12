import 'package:flutter/material.dart';

import 'app_routes.dart';

class AppNavigation {
  const AppNavigation._();

  static void openSection(BuildContext context, String route) => openSectionWith(Navigator.of(context), route);

  static void openSectionWith(NavigatorState navigator, String route) {
    if (!navigator.mounted) return;
    if (route == AppRoutes.home) {
      navigator.popUntil(ModalRoute.withName(AppRoutes.home));
      return;
    }
    navigator.pushNamedAndRemoveUntil(route, ModalRoute.withName(AppRoutes.home));
  }
}
