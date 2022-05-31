import 'package:flexeat/domain/nutrition_facts.dart';

import '../repository/nutrition_facts_repository.dart';

class LocalNutritionFactsRepository extends NutritionFactsRepository {
  @override
  Future<NutritionFacts> findByProductId(int productId) async {
    return const NutritionFacts();
  }
}
