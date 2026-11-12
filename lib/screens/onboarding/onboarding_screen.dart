import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/onboarding_pages.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/route_args.dart';
import '../../services/storage/onboarding_storage.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/logo.dart';
import '../../widgets/onboarding/onboarding_slide.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.args, this.storage = const OnboardingStorage()});

  final OnboardingArgs args;
  final OnboardingStorage storage;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  bool _dontShowAgain = false;
  bool _saving = false;

  bool get _isLastPage => _page == onboardingPages.length - 1;

  @override
  void initState() {
    super.initState();
    _loadCurrentChoice();
  }

  Future<void> _loadCurrentChoice() async {
    final hidden = await widget.storage.isHidden();
    if (mounted) setState(() => _dontShowAgain = hidden);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int page) => _pageController.animateToPage(
    page,
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeOutCubic,
  );

  Future<void> _finish() async {
    setState(() => _saving = true);
    await widget.storage.complete(dontShowAgain: _dontShowAgain);
    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (widget.args.fromProfile) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 8, 0),
            child: Row(
              children: [
                const AppLogo(),
                const Spacer(),
                if (!_isLastPage)
                  TextButton(
                    onPressed: _saving ? null : _finish,
                    style: TextButton.styleFrom(foregroundColor: AppColors.muted, minimumSize: const Size(64, 44)),
                    child: const Text('Pular', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingPages.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) => Center(child: OnboardingSlide(page: onboardingPages[index])),
            ),
          ),
          PageDots(count: onboardingPages.length, current: _page),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: CheckboxListTile(
              value: _dontShowAgain,
              onChanged: (value) => setState(() => _dontShowAgain = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: const Text(
                'Não mostrar novamente',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navy),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _page == 0 ? null : () => _goTo(_page - 1),
                      icon: const Icon(LucideIcons.arrowLeft, size: 18),
                      label: const Text('Voltar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.blue,
                        side: const BorderSide(color: AppColors.secondaryBorder),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: _saving ? null : (_isLastPage ? _finish : () => _goTo(_page + 1)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_isLastPage ? 'Começar' : 'Avançar'),
                          const SizedBox(width: 8),
                          Icon(_isLastPage ? LucideIcons.check : LucideIcons.arrowRight, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
