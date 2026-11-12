import 'package:flutter/material.dart';

import '../../navigation/app_routes.dart';
import '../../services/storage/onboarding_storage.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/common/logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.storage = const OnboardingStorage()});

  final OnboardingStorage storage;

  static const minimumDuration = Duration(milliseconds: 1800);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToNextScreen();
  }

  Future<void> _goToNextScreen() async {
    final results = await Future.wait<Object?>([
      Future<void>.delayed(SplashScreen.minimumDuration),
      widget.storage.isHidden(),
    ]);
    final skipOnboarding = results[1] as bool;
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(skipOnboarding ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.white, AppColors.lightBlueBg],
        ),
      ),
      child: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child),
          ),
          child: const Column(
            children: [
              Spacer(flex: 3),
              AppLogo(scale: 1.6),
              SizedBox(height: 18),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Compare rotas e acompanhe a chuva em São Paulo.',
                  textAlign: TextAlign.center,
                  style: AppText.intro,
                ),
              ),
              SizedBox(height: 36),
              SizedBox.square(dimension: 26, child: CircularProgressIndicator(strokeWidth: 2.6)),
              Spacer(flex: 4),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Dados públicos: SIBH / SP Águas, OpenStreetMap e Open-Meteo',
                  textAlign: TextAlign.center,
                  style: AppText.footnote,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
