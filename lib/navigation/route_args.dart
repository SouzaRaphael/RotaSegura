import '../models/place.dart';
import '../models/route_analysis.dart';

class TripArgs {
  const TripArgs({required this.origin, required this.destination});

  final Place origin;
  final Place destination;
}

class PlaceSearchArgs {
  const PlaceSearchArgs({required this.fieldLabel, this.initialQuery = ''});

  final String fieldLabel;
  final String initialQuery;
}

class RouteDetailArgs {
  const RouteDetailArgs({required this.trip, required this.comparison, required this.index});

  final TripArgs trip;
  final RouteComparison comparison;
  final int index;

  RouteAnalysis get analysis => comparison.routes[index];
}

class OnboardingArgs {
  const OnboardingArgs({this.fromProfile = false});

  final bool fromProfile;
}
