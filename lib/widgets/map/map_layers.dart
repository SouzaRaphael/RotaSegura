import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/driving_route.dart';
import '../../models/rain_station.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../stations/rain_level_style.dart';

MarkerLayer stationMarkerLayer(List<RainStation> stations, {required ValueChanged<RainStation> onTap}) {
  final ordered = [...stations]..sort((a, b) => a.rainfall.compareTo(b.rainfall));
  return MarkerLayer(
    markers: [
      for (final station in ordered)
        Marker(
          point: station.point,
          width: station.isRaining ? 46 : 18,
          height: station.isRaining ? 30 : 18,
          child: _StationMarker(station: station, onTap: () => onTap(station)),
        ),
    ],
  );
}

class _StationMarker extends StatelessWidget {
  const _StationMarker({required this.station, required this.onTap});

  final RainStation station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = station.level.color;
    return Semantics(
      button: true,
      label: '${station.name}: ${Formatters.millimeters(station.rainfall)} na última hora',
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.white, width: 2),
              boxShadow: const [BoxShadow(color: Color(0x40102F62), blurRadius: 5, offset: Offset(0, 2))],
            ),
            child: station.isRaining
                ? FittedBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        Formatters.decimal(station.rainfall),
                        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

PolylineLayer routePolylineLayer(List<DrivingRoute> routes, int selected) => PolylineLayer(
  drawInSingleWorld: true,
  polylines: [
    for (var i = 0; i < routes.length; i++)
      if (i != selected)
        Polyline(
          points: routes[i].points,
          color: AppColors.routeOther,
          strokeWidth: 5,
          borderColor: AppColors.white,
          borderStrokeWidth: 2,
        ),
    if (selected >= 0 && selected < routes.length)
      Polyline(
        points: routes[selected].points,
        color: AppColors.routeSelected,
        strokeWidth: 7,
        borderColor: AppColors.white,
        borderStrokeWidth: 3,
      ),
  ],
);

MarkerLayer endpointMarkerLayer(LatLng origin, LatLng destination) => MarkerLayer(
  markers: [
    Marker(point: origin, width: 22, height: 22, child: const _Endpoint(color: AppColors.blue, label: 'Origem')),
    Marker(
      point: destination,
      width: 22,
      height: 22,
      child: const _Endpoint(color: AppColors.destination, label: 'Destino'),
    ),
  ],
);

class _Endpoint extends StatelessWidget {
  const _Endpoint({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 4),
        boxShadow: const [BoxShadow(color: Color(0x40102F62), blurRadius: 5)],
      ),
    ),
  );
}
