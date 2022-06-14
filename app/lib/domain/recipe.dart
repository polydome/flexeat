import 'package:flexeat/model/recipe_header.dart';

import 'ingredient.dart';

class Recipe {
  final RecipeHeader header;
  final List<Ingredient> ingredients;

  const Recipe({
    this.header = const RecipeHeader(),
    this.ingredients = const [],
  });
}
