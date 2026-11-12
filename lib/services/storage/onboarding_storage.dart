import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  const OnboardingStorage();

  static const _hiddenKey = 'onboarding_hidden';
  static const _seenKey = 'onboarding_seen';

  Future<bool> isHidden() async => (await SharedPreferences.getInstance()).getBool(_hiddenKey) ?? false;

  Future<bool> wasSeen() async => (await SharedPreferences.getInstance()).getBool(_seenKey) ?? false;

  Future<void> complete({required bool dontShowAgain}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
    await prefs.setBool(_hiddenKey, dontShowAgain);
  }

  Future<void> setHidden(bool hidden) async =>
      (await SharedPreferences.getInstance()).setBool(_hiddenKey, hidden);
}
