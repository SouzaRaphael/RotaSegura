class AppPreferences {
  const AppPreferences({this.stationRadiusKm = 2, this.showDryStations = true});

  static const radiusOptions = [1, 2, 3];

  final int stationRadiusKm;

  final bool showDryStations;

  AppPreferences copyWith({int? stationRadiusKm, bool? showDryStations}) => AppPreferences(
    stationRadiusKm: stationRadiusKm ?? this.stationRadiusKm,
    showDryStations: showDryStations ?? this.showDryStations,
  );

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    final radius = json['stationRadiusKm'];
    return AppPreferences(
      stationRadiusKm: radius is int && radiusOptions.contains(radius) ? radius : 2,
      showDryStations: json['showDryStations'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'stationRadiusKm': stationRadiusKm,
    'showDryStations': showDryStations,
  };
}
