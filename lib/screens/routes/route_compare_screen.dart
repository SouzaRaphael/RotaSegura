import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/load_status.dart';
import '../../models/rain_station.dart';
import '../../models/route_analysis.dart';
import '../../navigation/app_navigation.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/route_args.dart';
import '../../services/api/api_client.dart';
import '../../services/route_comparison_service.dart';
import '../../services/storage/preferences_storage.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/app_buttons.dart';
import '../../widgets/common/info_row.dart';
import '../../widgets/common/load_state_views.dart';
import '../../widgets/common/notice_box.dart';
import '../../widgets/common/page_title.dart';
import '../../widgets/map/base_map.dart';
import '../../widgets/map/map_controls.dart';
import '../../widgets/map/map_layers.dart';
import '../../widgets/routes/route_card.dart';
import '../../widgets/shell/map_sheet_scaffold.dart';

class RouteCompareScreen extends StatefulWidget {
  const RouteCompareScreen({super.key, required this.trip});

  final TripArgs trip;

  @override
  State<RouteCompareScreen> createState() => _RouteCompareScreenState();
}

class _RouteCompareScreenState extends State<RouteCompareScreen> {
  final _service = RouteComparisonService();
  final _mapController = MapController();

  LoadStatus _status = LoadStatus.initial;
  RouteComparison? _comparison;
  String? _error;
  int _selected = 0;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _status = LoadStatus.loading;
      _error = null;
    });
    try {
      final preferences = await const PreferencesStorage().load();
      final comparison = await _service.compare(
        widget.trip.origin,
        widget.trip.destination,
        radiusKm: preferences.stationRadiusKm,
      );
      if (!mounted) return;
      setState(() {
        _comparison = comparison;
        _selected = comparison.recommendedIndex;
        _status = LoadStatus.success;
      });
      _fitMap();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _status = LoadStatus.error;
      });
    }
  }

  void _fitMap() {
    if (!_mapReady) return;
    final points = <LatLng>[
      widget.trip.origin.point,
      widget.trip.destination.point,
      ...?_comparison?.routes.expand((item) => item.route.points),
    ];
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: MapSheetScaffold.visibleMapPadding(context),
        maxZoom: 16,
      ),
    );
  }

  void _select(int index) => setState(() => _selected = index);

  void _openDetail() => Navigator.of(context).pushNamed(
    AppRoutes.routeDetail,
    arguments: RouteDetailArgs(trip: widget.trip, comparison: _comparison!, index: _selected),
  );

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final saved = await navigator.pushNamed<Object?>(AppRoutes.saveRoute, arguments: widget.trip);
    if (saved != true || !mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Rota frequente salva neste aparelho.'),
          action: SnackBarAction(
            label: 'Ver',
            textColor: AppColors.white,
            onPressed: () => AppNavigation.openSectionWith(navigator, AppRoutes.savedRoutes),
          ),
        ),
      );
  }

  void _startNavigation() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Navegação guiada não faz parte deste protótipo. Siga a rota pelo mapa.')),
      );
  }

  List<RainStation> get _nearbyStations {
    final byId = <String, RainStation>{};
    for (final route in _comparison?.routes ?? const <RouteAnalysis>[]) {
      for (final nearby in route.nearbyStations) {
        byId[nearby.station.id] = nearby.station;
      }
    }
    return byId.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final comparison = _comparison;
    return MapSheetScaffold(
      section: AppRoutes.home,
      map: BaseMap(
        controller: _mapController,
        center: widget.trip.origin.point,
        zoom: 13,
        onReady: () {
          _mapReady = true;
          if (_status == LoadStatus.success) _fitMap();
        },
        layers: [
          if (comparison != null) routePolylineLayer(comparison.routes.map((item) => item.route).toList(), _selected),
          stationMarkerLayer(
            _nearbyStations,
            onTap: (station) => Navigator.of(context).pushNamed(AppRoutes.stationDetail, arguments: station),
          ),
          endpointMarkerLayer(widget.trip.origin.point, widget.trip.destination.point),
        ],
      ),
      mapTopOverlay: _status == LoadStatus.loading
          ? const MapStatusChip(icon: LucideIcons.route, text: 'Calculando rotas…', loading: true)
          : null,
      mapActions: MapRoundButton(icon: LucideIcons.locateFixed, tooltip: 'Enquadrar rotas', onPressed: _fitMap),
      panelChildren: [
        const BackLink(label: 'Voltar ao início'),
        const SizedBox(height: 4),
        PageTitle(overline: 'Sua viagem', title: 'Compare suas rotas'),
        _TripSummary(trip: widget.trip),
        const SizedBox(height: 14),
        ..._buildState(),
      ],
    );
  }

  List<Widget> _buildState() {
    switch (_status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const [LoadingView(message: 'Consultando rotas, chuva observada nas estações e previsão do tempo…')];
      case LoadStatus.error:
        return [ErrorView(title: 'Não foi possível comparar as rotas', message: _error ?? '', onRetry: _load)];
      case LoadStatus.success:
        final comparison = _comparison!;
        final selected = comparison.routes[_selected];
        return [
          Text(comparison.reason, style: AppText.body.copyWith(color: AppColors.label)),
          const SizedBox(height: 12),
          if (!comparison.stationsAvailable) ...[
            const NoticeBox(
              tone: NoticeTone.warning,
              text: 'A chuva observada nas estações não pôde ser consultada. A comparação considera só a previsão.',
            ),
            const SizedBox(height: 10),
          ],
          if (!comparison.forecastAvailable) ...[
            const NoticeBox(
              tone: NoticeTone.warning,
              text: 'A previsão do tempo não pôde ser consultada. A comparação considera só a chuva observada.',
            ),
            const SizedBox(height: 10),
          ],
          for (var i = 0; i < comparison.routes.length; i++)
            RouteCard(
              analysis: comparison.routes[i],
              fastestMinutes: comparison.fastest.route.minutes,
              forecastHours: comparison.forecastHours,
              selected: i == _selected,
              onTap: () => _select(i),
            ),
          if (selected.hasHigherExposure) ...[
            const NoticeBox(
              tone: NoticeTone.warning,
              title: 'Você selecionou uma rota de maior exposição.',
              text: 'Ela passa por áreas com mais chuva registrada ou prevista do que a recomendada.',
            ),
            const SizedBox(height: 10),
          ] else if (!selected.isRecommended) ...[
            const NoticeBox(
              text: 'Esta rota tem exposição à chuva semelhante à recomendada, mas leva mais tempo.',
            ),
            const SizedBox(height: 10),
          ],
          _ExplainLink(
            title: selected.isRecommended
                ? 'Por que recomendamos a rota de ${Formatters.minutes(selected.route.minutes)}?'
                : 'Detalhes da rota de ${Formatters.minutes(selected.route.minutes)}',
            onTap: _openDetail,
          ),
          SourceLine(
            icon: LucideIcons.clock3,
            text: 'Consultado às ${Formatters.time(comparison.checkedAt)} · OSRM, SIBH / SP Águas e Open-Meteo',
          ),
          PrimaryButton(
            label: selected.isRecommended ? 'Usar rota recomendada' : 'Usar rota selecionada',
            icon: LucideIcons.navigation,
            onPressed: _startNavigation,
          ),
          const SizedBox(height: 10),
          SecondaryButton(label: 'Salvar como rota frequente', icon: LucideIcons.plus, onPressed: _save),
          const SizedBox(height: 12),
          const Text(
            'A comparação considera a chuva registrada na última hora e a previsão das próximas horas. '
            'A ausência de chuva registrada não garante que o caminho esteja seguro.',
            style: AppText.footnote,
          ),
        ];
    }
  }
}

class _TripSummary extends StatelessWidget {
  const _TripSummary({required this.trip});

  final TripArgs trip;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.noticeBg, borderRadius: BorderRadius.circular(10)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _point(LucideIcons.circleDot, AppColors.blue, trip.origin.name),
        const SizedBox(height: 6),
        _point(LucideIcons.mapPin, AppColors.destIcon, trip.destination.name),
      ],
    ),
  );

  Widget _point(IconData icon, Color color, String text) => Row(
    children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: AppText.strong, maxLines: 1, overflow: TextOverflow.ellipsis)),
    ],
  );
}

class _ExplainLink extends StatelessWidget {
  const _ExplainLink({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFF3F7FD),
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: const Color(0xFFE3EEFF), borderRadius: BorderRadius.circular(10)),
              child: const Icon(LucideIcons.info, size: 19, color: AppColors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.strong),
                  const SizedBox(height: 2),
                  const Text('Entenda os fatores considerados', style: AppText.small),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 19, color: AppColors.subtle),
          ],
        ),
      ),
    ),
  );
}
