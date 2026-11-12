import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/load_status.dart';
import '../../models/rain_forecast.dart';
import '../../models/rain_station.dart';
import '../../navigation/app_routes.dart';
import '../../services/api/api_client.dart';
import '../../services/api/forecast_service.dart';
import '../../services/storage/favorites_storage.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/app_buttons.dart';
import '../../widgets/common/favorite_button.dart';
import '../../widgets/common/info_row.dart';
import '../../widgets/common/load_state_views.dart';
import '../../widgets/common/notice_box.dart';
import '../../widgets/common/page_title.dart';
import '../../widgets/map/base_map.dart';
import '../../widgets/map/map_layers.dart';
import '../../widgets/shell/page_scaffold.dart';
import '../../widgets/stations/forecast_bars.dart';
import '../../widgets/stations/rain_level_style.dart';

class StationDetailScreen extends StatefulWidget {
  const StationDetailScreen({
    super.key,
    required this.station,
    this.forecastService,
    this.favoritesStorage = const FavoritesStorage(),
  });

  final RainStation station;
  final ForecastService? forecastService;
  final FavoritesStorage favoritesStorage;

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  late final ForecastService _forecastService = widget.forecastService ?? ForecastService();

  bool _isFavorite = false;
  LoadStatus _forecastStatus = LoadStatus.initial;
  RainForecast? _forecast;
  String? _forecastError;

  RainStation get _station => widget.station;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
    _loadForecast();
  }

  Future<void> _loadFavorite() async {
    final favorites = await widget.favoritesStorage.load();
    if (mounted) setState(() => _isFavorite = favorites.contains(_station.id));
  }

  Future<void> _toggleFavorite() async {
    final favorites = await widget.favoritesStorage.toggle(_station.id);
    if (mounted) setState(() => _isFavorite = favorites.contains(_station.id));
  }

  Future<void> _loadForecast() async {
    setState(() {
      _forecastStatus = LoadStatus.loading;
      _forecastError = null;
    });
    try {
      final forecast = await _forecastService.fetchForecast(_station.point);
      if (!mounted) return;
      setState(() {
        _forecast = forecast;
        _forecastStatus = LoadStatus.success;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _forecastError = error.message;
        _forecastStatus = LoadStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toUtc();
    final stale = _station.isStale(now);
    final color = _station.level.color;
    return PageScaffold(
      section: AppRoutes.stations,
      children: [
        const BackLink(label: 'Voltar'),
        PageTitle(
          overline: 'Estação pluviométrica',
          title: _station.name,
          trailing: FavoriteButton(isFavorite: _isFavorite, onPressed: _toggleFavorite, size: 28),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.millimeters(_station.rainfall),
                      style: AppText.stat(size: 34, color: Color.lerp(color, AppColors.navy, 0.3)!),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'na última hora · de ${Formatters.time(_station.periodStart)} '
                      'às ${Formatters.time(_station.periodEnd)}',
                      style: AppText.small,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [RainLevelBadge(level: _station.level), if (stale) const StaleBadge()],
                    ),
                  ],
                ),
              ),
              Icon(_station.isRaining ? LucideIcons.cloudRain : LucideIcons.cloud, size: 44, color: color),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 190,
            child: BaseMap(
              center: _station.point,
              zoom: 14,
              layers: [stationMarkerLayer([_station], onTap: (_) {})],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_station.owner.isNotEmpty)
          InfoRow(icon: LucideIcons.building2, label: 'Operador', value: _station.owner),
        if (_station.basin.isNotEmpty) InfoRow(icon: LucideIcons.waves, label: 'Sub-bacia', value: _station.basin),
        InfoRow(icon: LucideIcons.gauge, label: 'Leituras no período', value: '${_station.readings}'),
        InfoRow(
          icon: LucideIcons.mapPin,
          label: 'Coordenadas',
          value: '${_station.latitude.toStringAsFixed(4)}, ${_station.longitude.toStringAsFixed(4)}',
        ),
        SectionHeading(overline: 'Open-Meteo', title: 'Previsão para as próximas horas'),
        ..._buildForecast(),
        const SizedBox(height: 14),
        NoticeBox(
          text:
              'Fonte: SIBH / SP Águas. A medição representa apenas a estação e não indica alagamento na via.'
              '${stale ? ' Esta leitura tem mais de 90 minutos.' : ''}',
        ),
      ],
    );
  }

  List<Widget> _buildForecast() {
    switch (_forecastStatus) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const [LoadingView(message: 'Consultando a previsão para este ponto…')];
      case LoadStatus.error:
        return [ErrorView(title: 'Previsão indisponível', message: _forecastError ?? '', onRetry: _loadForecast)];
      case LoadStatus.success:
        final forecast = _forecast!;
        final total = forecast.totalFor(12);
        return [
          Text(
            total <= 0
                ? 'Sem chuva prevista nas próximas 12 horas.'
                : '${Formatters.millimeters(total)} previstos nas próximas 12 horas '
                      '(probabilidade máxima de ${forecast.maxProbabilityFor(12)}%).',
            style: AppText.body,
          ),
          const SizedBox(height: 16),
          ForecastBars(forecast: forecast),
          const SizedBox(height: 6),
          const Text('Chuva prevista por hora (mm) e probabilidade.', style: AppText.footnote),
        ];
    }
  }
}
