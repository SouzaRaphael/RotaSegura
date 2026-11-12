import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/load_status.dart';
import '../../models/rain_station.dart';
import '../../navigation/app_routes.dart';
import '../../services/api/api_client.dart';
import '../../services/api/rain_station_service.dart';
import '../../services/station_filter.dart';
import '../../services/storage/favorites_storage.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/app_buttons.dart';
import '../../widgets/common/load_state_views.dart';
import '../../widgets/common/notice_box.dart';
import '../../widgets/common/page_title.dart';
import '../../widgets/shell/page_scaffold.dart';
import '../../widgets/stations/station_filter_bar.dart';
import '../../widgets/stations/station_tile.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key, this.service, this.favoritesStorage = const FavoritesStorage()});

  final RainStationService? service;
  final FavoritesStorage favoritesStorage;

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  late final RainStationService _service = widget.service ?? RainStationService();
  final _searchController = TextEditingController();

  LoadStatus _status = LoadStatus.initial;
  List<RainStation> _stations = const [];
  String? _error;
  DateTime? _updatedAt;

  String _search = '';
  StationFilter _filter = StationFilter.all;
  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favorites = await widget.favoritesStorage.load();
    if (mounted) setState(() => _favorites = favorites);
  }

  Future<void> _load() async {
    setState(() {
      _status = LoadStatus.loading;
      _error = null;
    });
    await _fetch();
  }

  Future<void> _refresh() async {
    if (_status != LoadStatus.success) return _load();
    await _fetch(keepListOnError: true);
  }

  Future<void> _fetch({bool keepListOnError = false}) async {
    try {
      final stations = await _service.fetchStations();
      if (!mounted) return;
      setState(() {
        _stations = stations;
        _updatedAt = DateTime.now().toUtc();
        _status = LoadStatus.success;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (keepListOnError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível atualizar. ${error.message}')));
        return;
      }
      setState(() {
        _error = error.message;
        _status = LoadStatus.error;
      });
    }
  }

  Future<void> _toggleFavorite(RainStation station) async {
    final favorites = await widget.favoritesStorage.toggle(station.id);
    if (!mounted) return;
    setState(() => _favorites = favorites);
    final added = favorites.contains(station.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(added ? '${station.name} adicionada aos favoritos.' : '${station.name} removida dos favoritos.'),
        ),
      );
  }

  Future<void> _openDetail(RainStation station) async {
    await Navigator.of(context).pushNamed(AppRoutes.stationDetail, arguments: station);
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) => PageScaffold(
    section: AppRoutes.stations,
    onRefresh: _status == LoadStatus.success ? _refresh : null,
    children: [
      const PageTitle(
        overline: 'SIBH / SP Águas',
        title: 'Chuva agora',
        intro: 'Chuva acumulada na última hora em cada estação pluviométrica do município de São Paulo.',
      ),
      ..._buildState(),
    ],
  );

  List<Widget> _buildState() {
    switch (_status) {
      case LoadStatus.initial:
        return [
          EmptyView(
            icon: LucideIcons.cloudRain,
            title: 'Veja onde está chovendo',
            message: 'Consulte as medições mais recentes das estações. A consulta leva alguns segundos.',
            action: PrimaryButton(label: 'Consultar estações', icon: LucideIcons.search, onPressed: _load),
          ),
        ];
      case LoadStatus.loading:
        return const [LoadingView(message: 'Consultando as estações do SIBH…')];
      case LoadStatus.error:
        return [ErrorView(title: 'Não foi possível carregar a chuva agora', message: _error ?? '', onRetry: _load)];
      case LoadStatus.success:
        return _buildList();
    }
  }

  List<Widget> _buildList() {
    final now = DateTime.now().toUtc();
    final visible = StationQuery.apply(_stations, search: _search, filter: _filter, favorites: _favorites);
    final counts = {
      for (final option in StationFilter.values) option: StationQuery.count(_stations, option, _favorites),
    };
    return [
      Row(
        children: [
          const Icon(LucideIcons.clock3, size: 15, color: AppColors.subtle),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Atualizado às ${Formatters.time(_updatedAt ?? now)} · ${_stations.length} estações',
              style: AppText.small,
            ),
          ),
          LinkButton(label: 'Atualizar', icon: LucideIcons.refreshCw, onPressed: _refresh),
        ],
      ),
      const SizedBox(height: 8),
      StationFilterBar(
        controller: _searchController,
        filter: _filter,
        counts: counts,
        onSearchChanged: (value) => setState(() => _search = value),
        onFilterChanged: (value) => setState(() => _filter = value),
      ),
      const SizedBox(height: 14),
      if (visible.isEmpty)
        EmptyView(
          icon: _filter == StationFilter.favorites ? LucideIcons.star : LucideIcons.search,
          title: _filter == StationFilter.favorites && _search.isEmpty
              ? 'Nenhuma estação favorita'
              : 'Nenhuma estação encontrada',
          message: _filter == StationFilter.favorites && _search.isEmpty
              ? 'Toque na estrela de uma estação para acompanhá-la aqui.'
              : 'Tente outro termo de busca ou outro filtro.',
        )
      else
        for (final station in visible)
          StationTile(
            station: station,
            now: now,
            isFavorite: _favorites.contains(station.id),
            onToggleFavorite: () => _toggleFavorite(station),
            onTap: () => _openDetail(station),
          ),
      const SizedBox(height: 8),
      const NoticeBox(
        text:
            'A medição representa apenas o ponto da estação e não indica alagamento na via. '
            'Estações sem leitura recente aparecem como "Leitura antiga".',
      ),
    ];
  }
}
