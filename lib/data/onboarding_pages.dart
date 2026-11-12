import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OnboardingPageData {
  const OnboardingPageData({required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;
}

const onboardingPages = <OnboardingPageData>[
  OnboardingPageData(
    icon: LucideIcons.route,
    title: 'Compare rotas antes de sair',
    description:
        'Informe origem e destino em São Paulo e compare as alternativas de carro com tempo, '
        'distância e exposição à chuva no caminho.',
  ),
  OnboardingPageData(
    icon: LucideIcons.cloudRain,
    title: 'Veja onde está chovendo agora',
    description:
        'Acompanhe a chuva registrada na última hora pelas estações da rede SIBH / SP Águas, '
        'busque por região e favorite as estações do seu caminho.',
  ),
  OnboardingPageData(
    icon: LucideIcons.shieldAlert,
    title: 'Entenda a recomendação',
    description:
        'A rota recomendada considera a chuva observada perto do trajeto e a previsão para as '
        'próximas horas. O app apoia sua decisão, mas não garante que um caminho esteja seguro.',
  ),
  OnboardingPageData(
    icon: LucideIcons.bookmark,
    title: 'Guarde suas rotas frequentes',
    description:
        'Salve os trajetos do dia a dia e consulte de novo com um toque. '
        'Tudo fica guardado só neste aparelho.',
  ),
];
