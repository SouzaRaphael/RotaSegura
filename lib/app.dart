import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'navigation/app_router.dart';
import 'navigation/app_routes.dart';
import 'navigation/route_observer.dart';
import 'theme/app_theme.dart';
import 'widgets/shell/phone_frame.dart';

class RotaSeguraApp extends StatelessWidget {
  const RotaSeguraApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Rota Segura',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    scrollBehavior: const _TouchLikeScrollBehavior(),
    initialRoute: AppRoutes.splash,
    onGenerateRoute: AppRouter.onGenerateRoute,
    onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
    navigatorObservers: [appRouteObserver],
    builder: (context, child) => PhoneFrame(child: child ?? const SizedBox.shrink()),
  );
}

class _TouchLikeScrollBehavior extends MaterialScrollBehavior {
  const _TouchLikeScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
