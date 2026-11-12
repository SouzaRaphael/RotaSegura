import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/saved_route.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/route_args.dart';
import '../../services/storage/saved_routes_storage.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_buttons.dart';
import '../../widgets/common/notice_box.dart';
import '../../widgets/common/page_title.dart';
import '../../widgets/shell/page_scaffold.dart';

class SaveRouteScreen extends StatefulWidget {
  const SaveRouteScreen({super.key, required this.trip, this.storage = const SavedRoutesStorage()});

  final TripArgs trip;
  final SavedRoutesStorage storage;

  @override
  State<SaveRouteScreen> createState() => _SaveRouteScreenState();
}

class _SaveRouteScreenState extends State<SaveRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: '${widget.trip.origin.name} → ${widget.trip.destination.name}'.characters.take(40).toString(),
  );
  final Set<int> _weekdays = {1, 2, 3, 4, 5};
  TimeOfDay? _departure;
  String? _daysError;
  String? _saveError;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleDay(int day) => setState(() {
    if (!_weekdays.remove(day)) _weekdays.add(day);
    _daysError = null;
  });

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _departure ?? const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Horário de saída',
    );
    if (time != null) setState(() => _departure = time);
  }

  String? get _departureText => _departure == null
      ? null
      : '${_departure!.hour.toString().padLeft(2, '0')}:${_departure!.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    final formValid = _formKey.currentState!.validate();
    final daysError = SavedRoutesStorage.validateWeekdays(_weekdays);
    setState(() {
      _daysError = daysError;
      _saveError = null;
    });
    if (!formValid || daysError != null) return;

    setState(() => _saving = true);
    try {
      await widget.storage.add(
        name: _nameController.text,
        origin: widget.trip.origin,
        destination: widget.trip.destination,
        weekdays: _weekdays,
        departureTime: _departureText,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on ArgumentError catch (error) {
      setState(() {
        _saveError = '${error.message}';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => PageScaffold(
    section: AppRoutes.savedRoutes,
    children: [
      const BackLink(label: 'Voltar para rotas'),
      const PageTitle(
        overline: 'Rota frequente',
        title: 'Salvar esta viagem',
        intro: 'Guarde o trajeto para consultar de novo com um toque. Os dados ficam só neste aparelho.',
      ),
      Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          maxLength: 40,
          validator: SavedRoutesStorage.validateName,
          decoration: const InputDecoration(labelText: 'Nome da rota', hintText: 'Ex.: Casa → Trabalho'),
        ),
      ),
      const SizedBox(height: 6),
      _PlaceLine(icon: LucideIcons.circleDot, color: AppColors.blue, label: 'Origem', text: widget.trip.origin.name),
      _PlaceLine(icon: LucideIcons.mapPin, color: AppColors.destIcon, label: 'Destino', text: widget.trip.destination.name),
      const SizedBox(height: 18),
      const Text('Dias da semana', style: AppText.h3),
      const SizedBox(height: 10),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (var day = 1; day <= 7; day++)
            FilterChip(
              label: Text(SavedRoute.weekdayLabels[day - 1]),
              selected: _weekdays.contains(day),
              onSelected: (_) => _toggleDay(day),
              showCheckmark: false,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: _weekdays.contains(day) ? AppColors.white : AppColors.navy,
              ),
            ),
        ],
      ),
      if (_daysError != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(_daysError!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
        ),
      const SizedBox(height: 18),
      const Text('Horário de saída (opcional)', style: AppText.h3),
      const SizedBox(height: 10),
      SecondaryButton(
        label: _departureText == null ? 'Escolher horário' : 'Saída às $_departureText',
        icon: LucideIcons.clock,
        onPressed: _pickTime,
      ),
      if (_saveError != null) ...[
        const SizedBox(height: 14),
        NoticeBox(tone: NoticeTone.error, text: _saveError!),
      ],
      const SizedBox(height: 22),
      PrimaryButton(label: 'Salvar rota frequente', icon: LucideIcons.bookmark, onPressed: _save, loading: _saving),
      const SizedBox(height: 12),
      const Text(
        'Não há alertas automáticos: abra a rota em "Minhas rotas" para consultar a chuva antes de sair.',
        style: AppText.footnote,
      ),
    ],
  );
}

class _PlaceLine extends StatelessWidget {
  const _PlaceLine({required this.icon, required this.color, required this.label, required this.text});

  final IconData icon;
  final Color color;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text('$label: ', style: AppText.small),
        Expanded(child: Text(text, style: AppText.strong, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}
