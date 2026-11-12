import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/app_preferences.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/route_args.dart';
import '../../services/storage/favorites_storage.dart';
import '../../services/storage/onboarding_storage.dart';
import '../../services/storage/preferences_storage.dart';
import '../../services/storage/saved_routes_storage.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/app_buttons.dart';
import '../../widgets/common/load_state_views.dart';
import '../../widgets/common/page_title.dart';
import '../../widgets/shell/page_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _preferencesStorage = const PreferencesStorage();
  final _onboardingStorage = const OnboardingStorage();

  AppPreferences? _preferences;
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preferences = await _preferencesStorage.load();
    final hidden = await _onboardingStorage.isHidden();
    if (!mounted) return;
    setState(() {
      _preferences = preferences;
      _showIntro = !hidden;
    });
  }

  Future<void> _update(AppPreferences preferences) async {
    setState(() => _preferences = preferences);
    await _preferencesStorage.save(preferences);
  }

  Future<void> _setShowIntro(bool value) async {
    setState(() => _showIntro = value);
    await _onboardingStorage.setHidden(!value);
  }

  Future<void> _openIntro() async {
    await Navigator.of(context).pushNamed(AppRoutes.onboarding, arguments: const OnboardingArgs(fromProfile: true));
    _load();
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar dados deste aparelho?'),
        content: const Text(
          'Suas rotas frequentes, estações favoritas e preferências serão apagadas. '
          'Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await Future.wait([
      const SavedRoutesStorage().clear(),
      const FavoritesStorage().clear(),
      _preferencesStorage.clear(),
    ]);
    if (!mounted) return;
    setState(() => _preferences = const AppPreferences());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dados locais apagados.')));
  }

  @override
  Widget build(BuildContext context) {
    final preferences = _preferences;
    return PageScaffold(
      section: AppRoutes.profile,
      children: [
        const PageTitle(
          overline: 'Perfil',
          title: 'Preferências',
          intro: 'Ajuste como o Rota Segura compara as rotas e mostra a chuva. Tudo fica salvo só neste aparelho.',
        ),
        if (preferences == null)
          const LoadingView(message: 'Carregando preferências…')
        else ...[
          const Text('Estações perto da rota', style: AppText.h3),
          const SizedBox(height: 4),
          const Text(
            'Distância máxima entre a estação e o trajeto para a chuva dela entrar na comparação.',
            style: AppText.small,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: [
                for (final km in AppPreferences.radiusOptions) ButtonSegment(value: km, label: Text('$km km')),
              ],
              selected: {preferences.stationRadiusKm},
              onSelectionChanged: (value) => _update(preferences.copyWith(stationRadiusKm: value.first)),
            ),
          ),
          const SizedBox(height: 12),
          _SwitchRow(
            title: 'Mostrar estações sem chuva no mapa',
            subtitle: 'Desligado, o mapa inicial mostra só as estações com chuva.',
            value: preferences.showDryStations,
            onChanged: (value) => _update(preferences.copyWith(showDryStations: value)),
          ),
          _SwitchRow(
            title: 'Mostrar a introdução ao abrir o app',
            subtitle: 'É o oposto de "Não mostrar novamente" na introdução.',
            value: _showIntro,
            onChanged: _setShowIntro,
          ),
          const SizedBox(height: 14),
          SecondaryButton(label: 'Ver introdução novamente', icon: LucideIcons.sparkles, onPressed: _openIntro),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Apagar dados deste aparelho',
            icon: LucideIcons.trash2,
            danger: true,
            onPressed: _clearData,
          ),
        ],
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.title, required this.subtitle, required this.value, required this.onChanged});

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    value: value,
    onChanged: onChanged,
    contentPadding: EdgeInsets.zero,
    title: Text(title, style: AppText.strong),
    subtitle: Text(subtitle, style: AppText.small),
  );
}
