import 'package:latlong2/latlong.dart';

class ApiConfig {
  const ApiConfig._();

  static final rainStations = Uri.https('apps.spaguas.sp.gov.br', '/sibh/api/v2/measurements/now', {
    'station_type_id': '2',
    'hours': '1',
    'show_all': 'false',
    'serializer': 'complete',
    'public': 'true',
  });

  static const nominatimHost = 'nominatim.openstreetmap.org';

  static const osrmHost = 'router.project-osrm.org';

  static const openMeteoHost = 'api.open-meteo.com';

  static const tilesUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}';
  static const tilesAttribution = 'Esri, OpenStreetMap';

  static const saoPauloCenter = LatLng(-23.59, -46.65);
  static const saoPauloWest = -46.83;
  static const saoPauloEast = -46.36;
  static const saoPauloNorth = -23.36;
  static const saoPauloSouth = -24.01;

  static const cityViewSouthWest = LatLng(-23.70, -46.78);
  static const cityViewNorthEast = LatLng(-23.47, -46.52);

  static bool isInsideSaoPaulo(LatLng point) =>
      point.longitude >= saoPauloWest &&
      point.longitude <= saoPauloEast &&
      point.latitude <= saoPauloNorth &&
      point.latitude >= saoPauloSouth;
}
