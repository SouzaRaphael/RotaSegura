import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/saved_route.dart';
import '../../navigation/app_navigation.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/route_args.dart';
import '../../services/storage/saved_routes_storage.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_buttons.dart';
import '../../widgets/common/load_state_views.dart';
import '../../widgets/common/page_title.dart';
import '../../widgets/shell/page_scaffold.dart';

class SavedRoutesScreen extends StatefulWidget {
  const SavedRoutesScreen({super.key, this.storage = const SavedRoutesStorage()});

  final SavedRoutesStorage storage;

  @override
  State<SavedRoutesScreen> createState() => _SavedRoutesScreenState();
}

class _SavedRoutesScreenState extends State<SavedRoutesScreen> {
  List<SavedRoute>? _routes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final routes = await widget.storage.load();
    if (mounted) setState(() => _routes = routes);
  }

  void _consult(SavedRoute route) => Navigator.of(context).pushNamed(
    AppRoutes.routeCompare,
    arguments: TripArgs(origin: route.origin, destination: route.destination),
  );

  Future<void> _delete(SavedRoute route) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir rota frequente?'),
        content: Text('"${route.name}" será removida deste aparelho.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final routes = await widget.storage.remove(route.id);
    if (!mounted) return;
    setState(() => _routes = routes);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${route.name}" foi excluída.')));
  }

  @override
  Widget build(BuildContext context) {
    final routes = _routes;
    return PageScaffold(
      section: AppRoutes.savedRoutes,
      children: [
        const PageTitle(
          overline: 'Minhas rotas',
          title: 'Rotas frequentes',
          intro: 'Consulte a chuva no caminho dos seus trajetos do dia a dia antes de sair.',
        ),
        if (routes == null)
          const LoadingView(message: 'Carregando suas rotas…')
        else if (routes.isEmpty)
          EmptyView(
            icon: LucideIcons.bookmark,
            title: 'Nenhuma rota salva ainda',
            message: 'Compare as rotas de uma viagem e toque em "Salvar como rota frequente".',
            action: PrimaryButton(
              label: 'Comparar rotas',
              icon: LucideIcons.search,
              onPressed: () => AppNavigation.openSection(context, AppRoutes.home),
            ),
          )
        else
          for (final route in routes)
            _SavedRouteCard(route: route, onConsult: () => _consult(route), onDelete: () => _delete(route)),
      ],
    );
  }
}

class _SavedRouteCard extends StatelessWidget {
  const _SavedRouteCard({required this.route, required this.onConsult, required this.onDelete});

  final SavedRoute route;
  final VoidCallback onConsult;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(route.name, style: AppText.h3)),
            IconButton(
              tooltip: 'Excluir rota',
              onPressed: onDelete,
              icon: const Icon(LucideIcons.trash2, size: 19, color: AppColors.error),
            ),
          ],
        ),
        Text('${route.origin.name} → ${route.destination.name}', style: AppText.small),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(LucideIcons.calendar, size: 14, color: AppColors.subtle),
            const SizedBox(width: 6),
            Text(
              [route.weekdaysLabel, if (route.departureTime != null) 'saída às ${route.departureTime}'].join(' · '),
              style: AppText.small.copyWith(color: AppColors.label, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: LinkButton(label: 'Consultar agora', onPressed: onConsult),
        ),
      ],
    ),
  );
}
