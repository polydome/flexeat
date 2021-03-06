class NutritionFacts {
  final double? energy;
  final double? fat;
  final double? carbohydrates;
  final double? fibre;
  final double? protein;
  final double? salt;

  const NutritionFacts({
    this.energy,
    this.fat,
    this.carbohydrates,
    this.fibre,
    this.protein,
    this.salt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionFacts &&
          runtimeType == other.runtimeType &&
          energy == other.energy &&
          fat == other.fat &&
          carbohydrates == other.carbohydrates &&
          fibre == other.fibre &&
          protein == other.protein &&
          salt == other.salt;

  @override
  int get hashCode =>
      energy.hashCode ^
      fat.hashCode ^
      carbohydrates.hashCode ^
      fibre.hashCode ^
      protein.hashCode ^
      salt.hashCode;

  @override
  String toString() {
    return 'NutritionFacts{energy: $energy, fat: $fat, carbohydrates: $carbohydrates, fibre: $fibre, protein: $protein, salt: $salt}';
  }

  Map<String, double?> toMap() {
    return {
      'energy': energy,
      'fat': fat,
      'carbohydrates': carbohydrates,
      'fibre': fibre,
      'protein': protein,
      'salt': salt,
    };
  }

  NutritionFacts operator +(NutritionFacts other) {
    return NutritionFacts(
      energy: _addNutritionalValues(energy, other.energy),
      fat: _addNutritionalValues(fat, other.fat),
      carbohydrates: _addNutritionalValues(carbohydrates, other.carbohydrates),
      fibre: _addNutritionalValues(fibre, other.fibre),
      protein: _addNutritionalValues(protein, other.protein),
      salt: _addNutritionalValues(salt, other.salt),
    );
  }

  static double? _addNutritionalValues(double? value, double? other) =>
      (value == null && other == null) ? null : (value ?? 0) + (other ?? 0);

  NutritionFacts scaled(int grams) => NutritionFacts(
        energy: _scale(energy, grams),
        fat: _scale(fat, grams),
        carbohydrates: _scale(carbohydrates, grams),
        fibre: _scale(fibre, grams),
        protein: _scale(protein, grams),
        salt: _scale(salt, grams),
      );

  static double? _scale(double? value, int grams) =>
      value != null ? value / 100 * grams : null;
}
