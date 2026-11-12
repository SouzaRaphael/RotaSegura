# Rota Segura (Flutter)

Versão mobile em Flutter do [Rota Segura](https://github.com/EnzoLuchini/Rota-segura), feita para rodar no **Chrome em uma aba vertical** (tela-alvo 440 × 956, a mesma do design mobile da referência).

O app compara rotas de carro em São Paulo pela **exposição à chuva**: a chuva registrada na última hora nas estações perto do trajeto e a previsão para as próximas horas. Também mostra a chuva agora em cada estação da cidade e guarda rotas frequentes no aparelho.

## Como rodar no Chrome (aba vertical)

Requer o Flutter 3.47 ou mais recente.

```bash
flutter pub get
```

```bash
flutter run -d chrome --web-port=8080 --web-browser-flag=--window-size=440,956
```

A janela do Chrome abre em formato de celular. A porta fixa (`--web-port=8080`) é necessária para que as preferências (como "Não mostrar novamente"), os favoritos e as rotas salvas continuem entre uma execução e outra: no navegador, o SharedPreferences grava no `localStorage`, que é separado por endereço e porta. Sem ela, o Flutter escolhe uma porta nova a cada `flutter run` e o app abre sem os dados anteriores. Para que o Flutter guarde esses dados, feche o app com `q` no terminal ou fechando a janela do Chrome.

Também há configurações prontas: **"Chrome (aba vertical)"** no Android Studio (`.idea/runConfigurations`) e **"Rota Segura (Chrome, aba vertical)"** no VS Code (`.vscode/launch.json`).

Em uma aba larga, o app aparece centralizado em uma moldura de celular de 440 × 956. Em uma aba estreita (ou no modo dispositivo do DevTools, `Ctrl+Shift+M`), ocupa a tela toda.

> **Caminho com `°` no Windows.** O `flutter analyze` pode falhar quando a pasta tem caracteres como `°` (`3° ano`). Crie uma junção para um caminho só com ASCII e rode os comandos a partir dela:
> `New-Item -ItemType Junction -Path C:\dev\rota_segura -Target "<pasta do projeto>"`

### Por que estas APIs

Todas as fontes são públicas, **não pedem chave** e **aceitam chamadas do navegador (CORS)**, por isso funcionam no Chrome sem servidor intermediário. O GeoSampa e o feed do INMET, usados pelo backend Node da referência, não respondem a chamadas feitas direto do navegador, então ficaram de fora desta versão.

| Fonte | Uso |
|---|---|
| SIBH / SP Águas — "Chuva Agora" | Chuva da última hora em cada estação do município (filtrada pelo código IBGE 3550308) |
| Open-Meteo | Previsão horária de chuva (mm e probabilidade) |
| OSRM (OpenStreetMap) | Rotas de carro com alternativas |
| Nominatim (OpenStreetMap) | Busca de endereços dentro de São Paulo |
| Esri World Light Gray | Mapa base (o mesmo da referência) |

## Testes

```bash
flutter analyze
```

```bash
flutter test
```

26 testes cobrem a conversão dos JSON em modelos, a análise de exposição das rotas, os filtros, os formatadores, o Splash, a introdução e a lista de estações passando pelos quatro estados.

## Requisitos da disciplina

| Requisito | Onde está |
|---|---|
| **1. Splash** | [splash_screen.dart](lib/screens/splash/splash_screen.dart) mostra o logo e, depois de 1,8 s, lê o SharedPreferences ([onboarding_storage.dart](lib/services/storage/onboarding_storage.dart)) e segue para a introdução ou para o Início. |
| **2. Onboarding** | [onboarding_screen.dart](lib/screens/onboarding/onboarding_screen.dart): 4 páginas ([onboarding_pages.dart](lib/data/onboarding_pages.dart)) com ícone, título e descrição; botões Voltar, Avançar/Começar e Pular; caixa "Não mostrar novamente", salva ao concluir. O Perfil tem "Ver introdução novamente" e uma chave para voltar a mostrá-la. |
| **3. Navegação** | Rotas nomeadas ([app_routes.dart](lib/navigation/app_routes.dart)) criadas em `onGenerateRoute` ([app_router.dart](lib/navigation/app_router.dart)), com argumentos tipados ([route_args.dart](lib/navigation/route_args.dart)). São 10 telas além de Splash e Introdução: Início, Buscar local, Comparar rotas, Por que esta rota?, Salvar rota, Chuva agora, Detalhe da estação, Minhas rotas, Perfil e Fontes. Parâmetros: origem/destino → comparação; rota → detalhe; estação → detalhe. A busca de local e "Salvar rota" devolvem resultado no `pop`. O menu ☰ mantém o Início na base da pilha. |
| **4. WebService** | Pacote `http` em [api_client.dart](lib/services/api/api_client.dart), com tempo limite e mensagens amigáveis. O JSON vira modelos (`RainStation.fromJson`, `RainForecast.fromJson`, `DrivingRoute.fromOsrm`, `Place.fromNominatim`). Estados `initial/loading/success/error` ([load_status.dart](lib/models/load_status.dart)) em Chuva agora, Detalhe da estação, Buscar local, Comparar rotas e no resumo do Início, sempre com "Tentar novamente". |
| **5. Interações** | Item da lista → detalhe (estações e rotas). Busca sem acentos e filtros Todas / Com chuva / Favoritas. Favoritar estações (lista e detalhe). Atualizar (botão e "puxar para atualizar"). Selecionar rota (cartão e mapa mudam), fatores expansíveis, trocar e limpar origem e destino, salvar e excluir rotas frequentes, preferências. |
| **6. Organização e estado** | Estado com `setState` em `StatefulWidget`; textos e componentes estáticos em `StatelessWidget`. Regras fora das telas: comparação em [route_exposure_analyzer.dart](lib/services/analysis/route_exposure_analyzer.dart), busca e filtros em [station_filter.dart](lib/services/station_filter.dart), validação em [saved_routes_storage.dart](lib/services/storage/saved_routes_storage.dart). Ao voltar para o Início, um `RouteObserver` recarrega as preferências alteradas no Perfil. |

## Estrutura

```
lib/
  config/        URLs das APIs e limites de São Paulo
  theme/         cores e tipografia do CSS da referência (Manrope + DM Sans em assets/fonts)
  navigation/    rotas nomeadas, router, argumentos tipados e observer
  data/          conteúdo estático: introdução, sugestões de busca, fontes
  models/        estação, previsão, rota, análise, local, rota salva, preferências, estados
  services/api/  cliente HTTP e um serviço por API
  services/analysis/  geometria e comparação das rotas
  services/storage/   SharedPreferences: introdução, favoritos, rotas salvas, preferências
  utils/         formatação em português (mm, horário de Brasília, minutos)
  widgets/       componentes reutilizáveis: moldura, cabeçalho, mapa, cartões, estados
  screens/       uma pasta por tela
```

## Limites

Chuva registrada não é o mesmo que alagamento, e a ausência de chuva não garante que a via esteja livre. O tempo das rotas não considera o trânsito do momento. Não há alertas em tempo real, notificações nem navegação por GPS.
