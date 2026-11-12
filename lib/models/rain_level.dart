enum RainLevel {
  none('Sem chuva'),
  light('Chuva fraca'),
  moderate('Chuva moderada'),
  heavy('Chuva forte'),
  veryHeavy('Chuva muito forte');

  const RainLevel(this.label);

  final String label;

  static RainLevel fromMillimeters(double millimeters) {
    if (millimeters <= 0) return RainLevel.none;
    if (millimeters < 5) return RainLevel.light;
    if (millimeters < 25) return RainLevel.moderate;
    if (millimeters < 50) return RainLevel.heavy;
    return RainLevel.veryHeavy;
  }
}
