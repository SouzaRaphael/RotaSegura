import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/place_suggestions.dart';
import '../../models/load_status.dart';
import '../../models/place.dart';
import '../../navigation/route_args.dart';
import '../../services/api/api_client.dart';
import '../../services/api/place_search_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/load_state_views.dart';

class PlaceSearchScreen extends StatefulWidget {
  const PlaceSearchScreen({super.key, required this.args});

  final PlaceSearchArgs args;

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final _service = PlaceSearchService();
  late final TextEditingController _controller = TextEditingController(text: widget.args.initialQuery);

  LoadStatus _status = LoadStatus.initial;
  List<Place> _results = const [];
  String? _error;
  String _lastQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search([String? text]) async {
    final query = (text ?? _controller.text).trim();
    if (text != null) _controller.text = text;
    if (query.length < PlaceSearchService.minQueryLength) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Digite pelo menos 3 letras para buscar.')));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _status = LoadStatus.loading;
      _lastQuery = query;
      _error = null;
    });
    try {
      final results = await _service.search(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _status = LoadStatus.success;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _status = LoadStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      foregroundColor: AppColors.navy,
      title: Text('Escolher ${widget.args.fieldLabel.toLowerCase()}', style: AppText.h3.copyWith(fontSize: 17)),
      shape: const Border(bottom: BorderSide(color: AppColors.border)),
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      hintText: 'Endereço, bairro ou lugar em São Paulo',
                      prefixIcon: Icon(LucideIcons.mapPin, size: 18, color: AppColors.subtle),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _status == LoadStatus.loading ? null : _search,
                  tooltip: 'Buscar',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    fixedSize: const Size(48, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(LucideIcons.search, color: AppColors.white, size: 20),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    ),
  );

  Widget _buildBody() => switch (_status) {
    LoadStatus.initial => ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Sugestões', style: AppText.overline),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final suggestion in placeSuggestions)
              ActionChip(
                label: Text(suggestion),
                onPressed: () => _search(suggestion),
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy),
              ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'A busca usa o OpenStreetMap e considera apenas locais dentro do município de São Paulo.',
          style: AppText.small,
        ),
      ],
    ),
    LoadStatus.loading => const LoadingView(message: 'Buscando locais em São Paulo…'),
    LoadStatus.error => ListView(
      padding: const EdgeInsets.all(18),
      children: [
        ErrorView(title: 'Não foi possível buscar', message: _error ?? '', onRetry: () => _search(_lastQuery)),
      ],
    ),
    LoadStatus.success when _results.isEmpty => ListView(
      padding: const EdgeInsets.all(18),
      children: [
        EmptyView(
          icon: LucideIcons.mapPin,
          title: 'Nenhum local encontrado',
          message: 'Não encontramos "$_lastQuery" em São Paulo. Tente o nome da rua, do bairro ou de um lugar conhecido.',
        ),
      ],
    ),
    LoadStatus.success => ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _results.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 64, color: AppColors.border),
      itemBuilder: (context, index) {
        final place = _results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.lightBlueBg, borderRadius: BorderRadius.circular(10)),
            child: const Icon(LucideIcons.mapPin, size: 18, color: AppColors.blue),
          ),
          title: Text(place.name, style: AppText.strong),
          subtitle: place.address.isEmpty ? null : Text(place.address, style: AppText.small),
          onTap: () => Navigator.of(context).pop(place),
        );
      },
    ),
  };
}
