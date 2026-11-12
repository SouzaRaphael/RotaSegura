class DataSource {
  const DataSource({required this.name, required this.usage, required this.limits});

  final String name;
  final String usage;
  final String limits;
}

const dataSources = <DataSource>[
  DataSource(
    name: 'SIBH / SP Águas — Chuva Agora',
    usage: 'Chuva acumulada na última hora nas estações pluviométricas do município de São Paulo.',
    limits:
        'A medição vale para o ponto da estação. A cobertura é limitada e a estabilidade do serviço não é garantida. '
        'Registros de radar ficam de fora.',
  ),
  DataSource(
    name: 'Open-Meteo',
    usage: 'Previsão horária de chuva (mm e probabilidade) nos pontos das rotas e das estações.',
    limits: 'Previsão de modelos meteorológicos para a área, sem precisão de rua.',
  ),
  DataSource(
    name: 'OSRM e OpenStreetMap',
    usage: 'Rotas de carro com alternativas, tempo estimado, distância e principais vias.',
    limits: 'Servidor público de demonstração; o tempo não considera o trânsito do momento.',
  ),
  DataSource(
    name: 'Nominatim (OpenStreetMap)',
    usage: 'Busca de endereços e lugares dentro do município de São Paulo.',
    limits: 'A busca roda ao confirmar o texto, respeitando o limite de uso do serviço.',
  ),
  DataSource(
    name: 'Esri World Light Gray',
    usage: 'Mapa base cinza claro, o mesmo do projeto web de referência.',
    limits: 'Dados do mapa: Esri e colaboradores do OpenStreetMap.',
  ),
];

const methodologySteps = <String>[
  'Buscamos até 3 rotas de carro entre a origem e o destino.',
  'Para cada rota, procuramos as estações com leitura recente a até 1, 2 ou 3 km do trajeto (ajuste no Perfil) e pegamos a maior chuva da última hora.',
  'Também consultamos a previsão das próximas 3 horas em 4 pontos de cada rota e pegamos o maior acumulado.',
  'A exposição da rota é a soma desses dois valores. A recomendada é a de menor exposição; se a diferença for menor que 0,5 mm, vale a mais rápida.',
];
