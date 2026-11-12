import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../config/api_config.dart';
import '../../theme/app_colors.dart';

class BaseMap extends StatelessWidget {
  const BaseMap({
    super.key,
    required this.layers,
    this.controller,
    this.center = ApiConfig.saoPauloCenter,
    this.zoom = 11,
    this.onReady,
    this.interactive = true,
  });

  final List<Widget> layers;
  final MapController? controller;
  final LatLng center;
  final double zoom;
  final VoidCallback? onReady;
  final bool interactive;

  @override
  Widget build(BuildContext context) => FlutterMap(
    mapController: controller,
    options: MapOptions(
      initialCenter: center,
      initialZoom: zoom,
      minZoom: 9,
      maxZoom: 18,
      backgroundColor: AppColors.mapBackground,
      onMapReady: onReady,
      interactionOptions: InteractionOptions(
        flags: interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
      ),
    ),
    children: [
      TileLayer(
        urlTemplate: ApiConfig.tilesUrl,
        maxNativeZoom: 16,
        userAgentPackageName: 'br.com.fiap.rota_segura',
      ),
      ...layers,
      const Align(
        alignment: Alignment.bottomRight,
        child: ColoredBox(
          color: Color(0xCCFFFFFF),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text('© ${ApiConfig.tilesAttribution}', style: TextStyle(fontSize: 10, color: AppColors.muted)),
          ),
        ),
      ),
    ],
  );
}
