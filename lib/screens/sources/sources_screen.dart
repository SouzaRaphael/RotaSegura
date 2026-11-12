import 'package:flutter/material.dart';

import '../../data/sources.dart';
import '../../navigation/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/notice_box.dart';
import '../../widgets/common/page_title.dart';
import '../../widgets/shell/page_scaffold.dart';

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) => PageScaffold(
    section: AppRoutes.sources,
    children: [
      const PageTitle(
        overline: 'Transparência',
        title: 'Fontes e metodologia',
        intro: 'De onde vêm os dados do Rota Segura e como a rota recomendada é escolhida.',
      ),
      const SectionHeading(title: 'Como comparamos as rotas'),
      for (var i = 0; i < methodologySteps.length; i++) _Step(number: i + 1, text: methodologySteps[i]),
      const SectionHeading(title: 'Fontes de dados'),
      for (final source in dataSources) _SourceCard(source: source),
      const SizedBox(height: 8),
      const NoticeBox(
        tone: NoticeTone.warning,
        title: 'Limites.',
        text:
            'Chuva registrada não é o mesmo que alagamento, e a ausência de chuva não garante que a via esteja livre. '
            'Não há alertas em tempo real, notificações nem navegação por GPS. Siga sempre as orientações da '
            'Defesa Civil (199) e do CGE.',
      ),
    ],
  );
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.iconBlueBg, shape: BoxShape.circle),
          child: Text('$number', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.blue)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppText.body)),
      ],
    ),
  );
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source});

  final DataSource source;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(source.name, style: AppText.strong),
        const SizedBox(height: 4),
        Text(source.usage, style: AppText.body.copyWith(fontSize: 13)),
        const SizedBox(height: 6),
        Text(source.limits, style: AppText.small),
      ],
    ),
  );
}
