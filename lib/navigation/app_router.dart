import 'package:flutter/material.dart';

import '../models/rain_station.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/place_search/place_search_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/routes/route_compare_screen.dart';
import '../screens/routes/route_detail_screen.dart';
import '../screens/routes/save_route_screen.dart';
import '../screens/saved_routes/saved_routes_screen.dart';
import '../screens/sources/sources_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/stations/station_detail_screen.dart';
import '../screens/stations/stations_screen.dart';
import 'app_routes.dart';
import 'route_args.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final Widget? page = switch (settings.name) {
      AppRoutes.splash => const SplashScreen(),
      AppRoutes.onboarding => OnboardingScreen(args: args is OnboardingArgs ? args : const OnboardingArgs()),
      AppRoutes.home => const HomeScreen(),
      AppRoutes.placeSearch => args is PlaceSearchArgs ? PlaceSearchScreen(args: args) : null,
      AppRoutes.routeCompare => args is TripArgs ? RouteCompareScreen(trip: args) : null,
      AppRoutes.routeDetail => args is RouteDetailArgs ? RouteDetailScreen(args: args) : null,
      AppRoutes.saveRoute => args is TripArgs ? SaveRouteScreen(trip: args) : null,
      AppRoutes.stations => const StationsScreen(),
      AppRoutes.stationDetail => args is RainStation ? StationDetailScreen(station: args) : null,
      AppRoutes.savedRoutes => const SavedRoutesScreen(),
      AppRoutes.profile => const ProfileScreen(),
      AppRoutes.sources => const SourcesScreen(),
      _ => null,
    };
    return MaterialPageRoute<dynamic>(
      settings: page == null ? const RouteSettings(name: AppRoutes.home) : settings,
      builder: (_) => page ?? const HomeScreen(),
    );
  }

  static List<Route<dynamic>> onGenerateInitialRoutes(String _) => [
    onGenerateRoute(const RouteSettings(name: AppRoutes.splash)),
  ];
}
