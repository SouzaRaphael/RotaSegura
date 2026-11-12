import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/route_analysis.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/route_args.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/app_buttons.dart';
import '../../widgets/common/load_state_views.dart';
import '../../widgets/common/page_title.dart';
import '../../widgets/routes/factor_tile.dart';
import '../../widgets/shell/page_scaffold.dart';
import '../../widgets/stations/station_tile.dart';

class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen({super.key, required this.args});

  final RouteDetailArgs args;

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  int _expanded = -1;

  void _toggle(int index) => setState(() => _expanded = _expanded == index ? -1 : index);

  @override
  Widget build(BuildContext context) {
    final comparison = widget.args.comparison;
    final analysis = widget.args.analysis;
    final route = analysis.route;
    final extra = route.minutes - comparison.fastest.route.minutes;
    final radius = Formatters.kilometers(comparison.radiusMeters / 1000);
    final now = DateTime.now().toUtc();
    final factors = _factors(comparison, analysis, extra, radius);

    return PageScaffold(
      section: AppRoutes.home,
      children: [
        const BackLink(label: 'Voltar para rotas'),
        PageTitle(
          overline: 'Entenda a recomendação',
          title: analysis.isRecommended ? 'Por que esta rota?' : 'Sobre esta rota',
          intro: comparison.reason,
        ),
        _RouteSummary(analysis: analysis, extraMinutes: extra),
        const SizedBox(height: 16),
        for (var i = 0; i < factors.length; i++)
          FactorTile(
            icon: factors[i].icon,
            title: factors[i].title,
            description: factors[i].description,
            details: factors[i].details,
            warning: factors[i].warning,
            expanded: _expanded == i,
            onTap: () => _toggle(i),
          ),
        SectionHeading(overline: 'A até $radius do trajeto', title: 'Estações no caminho'),
        if (!comparison.stationsAvailable)
          const EmptyView(
            icon: LucideIcons.cloudOff,
            title: 'Estações indisponíveis',
            message: 'A chuva observada não pôde ser consultada nesta comparação.',
          )
        else if (analysis.nearbyStations.isEmpty)
          EmptyView(
            icon: LucideIcons.mapPin,
            title: 'Nenhuma estação perto do trajeto',
            message: 'Não há estações com leitura recente a até $radius desta rota.',
          )
        else
          for (final nearby in analysis.nearbyStations)
            StationTile(
              station: nearby.station,
              now: now,
              distanceMeters: nearby.distanceMeters,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.stationDetail, arguments: nearby.station),
            ),
        const SizedBox(height: 8),
        const Text(
          'A ausência de chuva registrada não garante que o caminho esteja seguro. '
          'As condições podem mudar rapidamente.',
          style: AppText.footnote,
        ),
      ],
    );
  }

  List<_Factor> _factors(RouteComparison comparison, RouteAnalysis analysis, int extra, String radius) {
    final raining = analysis.rainingStations;
    final top = raining.isEmpty ? null : raining.first.station;
    return [
      _Factor(
        icon: LucideIcons.cloudRain,
        title: 'Chuva observada perto do trajeto',
        description: analysis.observedRain == null
            ? 'Não foi possível consultar as estações.'
            : top == null
            ? '${analysis.nearbyStations.length} estações a até $radius, nenhuma com chuva na última hora.'
            : '${raining.length} de ${analysis.nearbyStations.length} estações com chuva. '
                  'Maior acumulado: ${Formatters.millimeters(top.rainfall)} em ${top.name}.',
        details: const [
          'Fonte: SIBH / SP Águas ("Chuva Agora").',
          'Período: acumulado da última hora em cada estação.',
          'Leituras com mais de 90 minutos não entram na comparação.',
        ],
        warning: (analysis.observedRain ?? 0) > 0,
      ),
      _Factor(
        icon: LucideIcons.cloudSunRain,
        title: 'Previsão de chuva no trajeto',
        description: analysis.forecastRain == null
            ? 'Não foi possível consultar a previsão.'
            : 'Até ${Formatters.millimeters(analysis.forecastRain!)} nas próximas ${comparison.forecastHours} horas, '
                  'com probabilidade máxima de ${analysis.forecastProbability ?? 0}%.',
        details: const [
          'Fonte: Open-Meteo (modelos meteorológicos).',
          'Calculada em 4 pontos distribuídos ao longo da rota.',
          'É uma previsão para a área, não para uma rua específica.',
        ],
        warning: (analysis.forecastRain ?? 0) > 0.5,
      ),
      _Factor(
        icon: LucideIcons.clock3,
        title: 'Tempo e distância',
        description:
            '${Formatters.minutes(analysis.route.minutes)} · ${Formatters.kilometers(analysis.route.kilometers)}'
            '${analysis.isFastest ? ' · rota mais rápida' : ' · ${Formatters.minutesDifference(extra)} que a mais rápida'}.',
        details: const [
          'Fonte: OSRM com dados do OpenStreetMap.',
          'Tempo estimado sem considerar o trânsito do momento.',
        ],
      ),
      if (analysis.route.summary.isNotEmpty)
        _Factor(
          icon: LucideIcons.route,
          title: 'Principais vias',
          description: analysis.route.summary,
          details: const ['Vias mais longas do trajeto, segundo o OSRM.'],
        ),
    ];
  }
}

class _Factor {
  const _Factor({
    required this.icon,
    required this.title,
    required this.description,
    required this.details,
    this.warning = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<String> details;
  final bool warning;
}

class _RouteSummary extends StatelessWidget {
  const _RouteSummary({required this.analysis, required this.extraMinutes});

  final RouteAnalysis analysis;
  final int extraMinutes;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.recommendedBg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(13)),
          child: const Icon(LucideIcons.route, color: AppColors.white, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(analysis.label, style: AppText.small.copyWith(color: AppColors.recommendedText)),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: Formatters.minutes(analysis.route.minutes), style: AppText.stat(size: 21)),
                    if (extraMinutes > 0)
                      TextSpan(text: '  · $extraMinutes min a mais', style: AppText.small),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
