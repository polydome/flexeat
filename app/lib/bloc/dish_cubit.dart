import 'dart:async';

import 'package:flexeat/bloc/navigation_cubit.dart';
import 'package:flexeat/domain/model/dish.dart';
import 'package:flexeat/domain/model/ingredient.dart';
import 'package:flexeat/domain/model/nutrition_facts.dart';
import 'package:flexeat/domain/model/product_packaging.dart';
import 'package:flexeat/domain/repository/article_repository.dart';
import 'package:flexeat/domain/repository/packaging_repository.dart';
import 'package:flexeat/domain/repository/recipe_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DishCubit extends Cubit<Dish> {
  final RecipeRepository _recipeRepository;
  final PackagingRepository _packagingRepository;
  final ArticleRepository _articleRepository;
  final NavigationCubit _navigationCubit;
  final int recipeId;
  late final StreamSubscription _sub;

  Map<Ingredient, ProductPackaging?> _mergeIngredients(
      List<Ingredient> ingredients) {
    final Map<Ingredient, ProductPackaging?> newIngredients = {};

    for (final ingredient in ingredients) {
      if (state.ingredients.containsKey(ingredient)) {
        newIngredients[ingredient] = state.ingredients[ingredient];
      } else {
        newIngredients[ingredient] = null;
      }
    }

    return newIngredients;
  }

  NutritionFacts _summarizeNutritionFacts(
      Map<Ingredient, ProductPackaging?> ingredients) {
    var value = const NutritionFacts();

    for (final entry in ingredients.entries) {
      value += entry.value?.nutritionFacts.scaled(entry.key.weight) ??
          const NutritionFacts();
    }

    return value;
  }

  DishCubit(this._recipeRepository, this._packagingRepository,
      this._articleRepository, this._navigationCubit,
      {required this.recipeId})
      : super(const Dish()) {
    _sub = _recipeRepository.watchById(recipeId).listen((recipe) {
      if (recipe != null) {
        final ingredients = _mergeIngredients(recipe.ingredients);
        emit(state.copyWith(
            recipeHeader: recipe.header,
            ingredients: ingredients,
            nutritionFacts: _summarizeNutritionFacts(ingredients)));
      }
    });
  }

  @override
  Future<void> close() async {
    _sub.cancel();
    super.close();
  }

  void changeName(String name) {
    _recipeRepository.updateNameById(recipeId, name: name);
  }

  void addIngredient(int? articleId, String name, int weight) {
    _addIngredient(articleId, name, weight);
  }

  Future<void> _addIngredient(int? articleId, String name, int weight) async {
    articleId ??= await _articleRepository.create(name);

    _recipeRepository.addIngredientById(recipeId,
        articleId: articleId, weight: weight);
  }

  void selectProduct(int articleId, int packagingId) {
    _updateSelectedProduct(articleId, packagingId);
  }

  void _updateSelectedProduct(int articleId, int packagingId) async {
    final ingredient = state.ingredients.entries
        .firstWhere((element) => element.key.article.id == articleId)
        .key;

    final productPackaging =
        await _packagingRepository.findProductPackagingsByArticleId(articleId);

    final ingredients = state.ingredients.updated(
        ingredient,
        productPackaging
            .firstWhere((element) => element.packaging.id == packagingId));

    emit(state.copyWith(
        nutritionFacts: _summarizeNutritionFacts(ingredients),
        ingredients: ingredients));
  }

  void remove() {
    _recipeRepository
        .removeById(recipeId)
        .then((value) => _navigationCubit.navigateBack());
  }

  void unlinkIngredient(int articleId) async {
    final ingredients =
        Map<Ingredient, ProductPackaging>.from(state.ingredients);
    ingredients.removeWhere((key, value) => key.article.id == articleId);

    emit(state.copyWith(
        nutritionFacts: _summarizeNutritionFacts(ingredients),
        ingredients: ingredients));
  }

  void removeIngredient(int articleId) async {
    _recipeRepository.removeIngredientById(recipeId, articleId);
  }
}

extension Updated<K, V> on Map<K, V> {
  Map<K, V> updated(K key, V value) {
    final newMap = Map<K, V>.from(this);
    newMap.update(key, (_) => value);
    return newMap;
  }
}
