import 'package:flexeat/domain/nutrition_facts.dart';
import 'package:flexeat/domain/packaging.dart';
import 'package:meta/meta.dart';


@immutable
class ProductState {
  final String productName;
  final NutritionFacts? nutritionFacts;
  final List<String> compatibleArticles;
  final List<Packaging> packagings;
  final bool loading;

  const ProductState({
    this.productName = "",
    this.nutritionFacts,
    this.compatibleArticles = const [],
    this.packagings = const [],
    this.loading = false,
  });

  ProductState copyWith({
    String? productName,
    NutritionFacts? nutritionFacts,
    List<String>? compatibleArticles,
    List<Packaging>? packagings,
    bool? loading,
  }) {
    return ProductState(
      productName: productName ?? this.productName,
      nutritionFacts: nutritionFacts ?? this.nutritionFacts,
      compatibleArticles: compatibleArticles ?? this.compatibleArticles,
      packagings: packagings ?? this.packagings,
      loading: loading ?? this.loading,
    );
  }
}