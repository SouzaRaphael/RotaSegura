import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../config/api_config.dart';
import '../../models/app_preferences.dart';
import '../../models/load_status.dart';
import '../../models/place.dart';
import '../../models/rain_station.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/route_args.dart';
import '../../navigation/route_observer.dart';
import '../../services/api/api_client.dart';
import '../../services/api/rain_station_service.dart';
import '../../services/storage/preferences_storage.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_buttons.dart';
import '../../widgets/common/notice_box.dart';
import '../../widgets/common/page_title.dart';
import '../../widgets/map/base_map.dart';
import '../../widgets/map/map_controls.dart';
import '../../widgets/map/map_layers.dart';
import '../../widgets/routes/trip_fields.dart';
import '../../widgets/shell/map_sheet_scaffold.dart';
import '../../widgets/stations/rain_summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final _stationService = RainStationService();
  final _preferencesStorage = const PreferencesStorage();
  final _mapController = MapController();

  Place? _origin;
  Place? _destination;
  AppPreferences _preferences = const AppPreferences();

  LoadStatus _stationsStatus = LoadStatus.initial;
  List<RainStation> _stations = const [];
  String? _stationsError;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadStations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) appRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() => _loadPreferences();

  Future<void> _loadPreferences() async {
    final preferences = await _preferencesStorage.load();
    if (mounted) setState(() => _preferences = preferences);
  }

  Future<void> _loadStations() async {
    setState(() {
      _stationsStatus = LoadStatus.loading;
      _stationsError = null;
    });
    try {
      final stations = await _stationService.fetchStations();
      if (!mounted) return;
      setState(() {
        _stations = stations;
        _stationsStatus = LoadStatus.success;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _stationsError = error.message;
        _stationsStatus = LoadStatus.error;
      });
    }
  }

  Future<void> _pickPlace({required bool isOrigin}) async {
    final current = isOrigin ? _origin : _destination;
    final place = await Navigator.of(context).pushNamed<Object?>(
      AppRoutes.placeSearch,
      arguments: PlaceSearchArgs(fieldLabel: isOrigin ? 'Origem' : 'Destino', initialQuery: current?.name ?? ''),
    );
    if (place is! Place || !mounted) return;
    setState(() => isOrigin ? _origin = place : _destination = place);
  }

  void _swap() => setState(() {
    final origin = _origin;
    _origin = _destination;
    _destination = origin;
  });

  void _clearTrip() => setState(() {
    _origin = null;
    _destination = null;
  });

  void _compare() {
    final origin = _origin, destination = _destination;
    final message = switch ((origin, destination)) {
      (null, _) => 'Escolha o local de origem.',
      (_, null) => 'Escolha o local de destino.',
      (final Place a, final Place b) when a.isSameLocation(b) => 'A origem e o destino precisam ser diferentes.',
      _ => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    Navigator.of(context).pushNamed(AppRoutes.routeCompare, arguments: TripArgs(origin: origin!, destination: destination!));
  }

  void _openStation(RainStation station) =>
      Navigator.of(context).pushNamed(AppRoutes.stationDetail, arguments: station);

  void _open(String route) => Navigator.of(context).pushNamed(route);

  void _centerCity() => _mapController.fitCamera(
    CameraFit.bounds(
      bounds: LatLngBounds(ApiConfig.cityViewSouthWest, ApiConfig.cityViewNorthEast),
      padding: MapSheetScaffold.visibleMapPadding(context),
    ),
  );

  List<RainStation> get _visibleStations =>
      _preferences.showDryStations ? _stations : _stations.where((station) => station.isRaining).toList();

  String get _mapStatus => switch (_stationsStatus) {
    LoadStatus.initial || LoadStatus.loading => 'Consultando a chuva nas estações…',
    LoadStatus.error => 'Chuva agora indisponível',
    LoadStatus.success => _stations.any((station) => station.isRaining)
        ? 'Chuva agora: ${_stations.where((station) => station.isRaining).length} estações com chuva'
        : 'Chuva agora: sem chuva nas estações',
  };

  @override
  Widget build(BuildContext context) => MapSheetScaffold(
    section: AppRoutes.home,
    map: BaseMap(
      controller: _mapController,
      onReady: _centerCity,
      layers: [stationMarkerLayer(_visibleStations, onTap: _openStation)],
    ),
    mapTopOverlay: MapStatusChip(
      icon: LucideIcons.cloudRain,
      text: _mapStatus,
      loading: _stationsStatus == LoadStatus.loading,
    ),
    mapActions: MapRoundButton(
      icon: LucideIcons.locateFixed,
      tooltip: 'Centralizar mapa',
      onPressed: _centerCity,
    ),
    panelChildren: [
      const _Eyebrow(),
      const PageTitle(
        title: 'Um caminho melhor começa com informação.',
        intro: 'Compare rotas e conheça os riscos relacionados à chuva no seu trajeto.',
      ),
      TripFields(
        origin: _origin,
        destination: _destination,
        onPickOrigin: () => _pickPlace(isOrigin: true),
        onPickDestination: () => _pickPlace(isOrigin: false),
        onSwap: _origin == null && _destination == null ? null : _swap,
        onClear: _origin == null && _destination == null ? null : _clearTrip,
      ),
      const SizedBox(height: 8),
      PrimaryButton(label: 'Comparar rotas', icon: LucideIcons.search, onPressed: _compare),
      SectionHeading(
        overline: 'Na sua cidade',
        title: 'Chuva agora',
        action: LinkButton(label: 'Ver estações', onPressed: () => _open(AppRoutes.stations)),
      ),
      RainSummaryCard(
        status: _stationsStatus,
        stations: _stations,
        errorMessage: _stationsError,
        onRetry: _loadStations,
        onOpen: () => _open(AppRoutes.stations),
      ),
      const SizedBox(height: 18),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _QuickAction(label: 'Rotas frequentes', icon: LucideIcons.bookmark, onTap: () => _open(AppRoutes.savedRoutes)),
          _QuickAction(label: 'Fontes e metodologia', icon: LucideIcons.bookOpen, onTap: () => _open(AppRoutes.sources)),
          _QuickAction(label: 'Preferências', icon: LucideIcons.settings, onTap: () => _open(AppRoutes.profile)),
        ],
      ),
      const SizedBox(height: 18),
      const NoticeBox(
        text:
            'Rotas, chuva observada e previsão vêm de serviços públicos, com cobertura limitada. '
            'O Rota Segura apoia sua decisão e não garante que um caminho esteja seguro.',
      ),
    ],
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('Mobilidade mais informada', style: AppText.overline.copyWith(color: AppColors.eyebrowGreen)),
      ],
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
    onPressed: onTap,
    avatar: Icon(icon, size: 16, color: AppColors.blue),
    label: Text(label),
    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.navy),
    side: const BorderSide(color: AppColors.secondaryBorder),
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );
}
