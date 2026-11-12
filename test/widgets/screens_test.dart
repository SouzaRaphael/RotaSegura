import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rota_segura/navigation/app_routes.dart';
import 'package:rota_segura/navigation/route_args.dart';
import 'package:rota_segura/screens/onboarding/onboarding_screen.dart';
import 'package:rota_segura/screens/splash/splash_screen.dart';
import 'package:rota_segura/screens/stations/stations_screen.dart';
import 'package:rota_segura/services/api/api_client.dart';
import 'package:rota_segura/services/api/rain_station_service.dart';
import 'package:rota_segura/services/storage/onboarding_storage.dart';
import 'package:rota_segura/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixtures.dart';

Widget testApp(Widget home) => MaterialApp(
  theme: buildAppTheme(),
  home: home,
  routes: {
    AppRoutes.home: (_) => const Scaffold(body: Text('TELA INICIAL')),
    AppRoutes.onboarding: (_) => const Scaffold(body: Text('INTRODUÇÃO')),
    AppRoutes.stationDetail: (_) => const Scaffold(body: Text('DETALHE')),
  },
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Splash', () {
    testWidgets('sem preferência salva, segue para a introdução', (tester) async {
      await tester.pumpWidget(testApp(const SplashScreen()));
      expect(find.text('Compare rotas e acompanhe a chuva em São Paulo.'), findsOneWidget);
      await tester.pump(SplashScreen.minimumDuration);
      await tester.pumpAndSettle();
      expect(find.text('INTRODUÇÃO'), findsOneWidget);
    });

    testWidgets('com "Não mostrar novamente", vai direto ao início', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_hidden': true});
      await tester.pumpWidget(testApp(const SplashScreen()));
      await tester.pump(SplashScreen.minimumDuration);
      await tester.pumpAndSettle();
      expect(find.text('TELA INICIAL'), findsOneWidget);
    });
  });

  group('Introdução', () {
    testWidgets('avança, volta e salva a opção marcada', (tester) async {
      await tester.pumpWidget(testApp(const OnboardingScreen(args: OnboardingArgs())));
      await tester.pumpAndSettle();
      expect(find.text('Compare rotas antes de sair'), findsOneWidget);
      expect(tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed, isNull);

      await tester.tap(find.text('Avançar'));
      await tester.pumpAndSettle();
      expect(find.text('Veja onde está chovendo agora'), findsOneWidget);

      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();
      expect(find.text('Compare rotas antes de sair'), findsOneWidget);

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Avançar'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Começar'), findsOneWidget);
      await tester.tap(find.text('Não mostrar novamente'));
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();

      expect(find.text('TELA INICIAL'), findsOneWidget);
      expect(await const OnboardingStorage().isHidden(), isTrue);
    });

    testWidgets('sem a opção marcada, a introdução continua aparecendo', (tester) async {
      await tester.pumpWidget(testApp(const OnboardingScreen(args: OnboardingArgs())));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pular'));
      await tester.pumpAndSettle();
      expect(await const OnboardingStorage().isHidden(), isFalse);
      expect(await const OnboardingStorage().wasSeen(), isTrue);
    });
  });

  group('Chuva agora', () {
    testWidgets('passa pelos estados inicial, erro, carregando e sucesso', (tester) async {
      tester.view.physicalSize = const Size(440, 956);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      var fail = true;
      final client = MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (fail) return http.Response('erro', 500);
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'measurements': [
                sibhMeasurement(id: '1', name: 'São Paulo (Penha)', value: 6.2, end: _recent()),
                sibhMeasurement(id: '2', name: 'São Paulo (Lapa)', value: 0, end: _recent()),
              ],
            }),
          ),
          200,
        );
      });
      final service = RainStationService(client: ApiClient(client: client));
      await tester.pumpWidget(testApp(StationsScreen(service: service)));
      await tester.pumpAndSettle();

      expect(find.text('Veja onde está chovendo'), findsOneWidget);
      await tester.tap(find.text('Consultar estações'));
      await tester.pump();
      expect(find.text('Consultando as estações do SIBH…'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Não foi possível carregar a chuva agora'), findsOneWidget);

      fail = false;
      await tester.ensureVisible(find.text('Tentar novamente'));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(find.text('Penha'), findsOneWidget);
      expect(find.text('Lapa'), findsOneWidget);

      await tester.tap(find.text('Com chuva (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Lapa'), findsNothing);

      await tester.tap(find.byTooltip('Adicionar aos favoritos'));
      await tester.pumpAndSettle();
      expect(find.text('Favoritas (1)'), findsOneWidget);

      await tester.tap(find.text('Penha'));
      await tester.pumpAndSettle();
      expect(find.text('DETALHE'), findsOneWidget);
    });
  });
}

String _recent() => DateTime.now().toUtc().subtract(const Duration(minutes: 10)).toIso8601String();
