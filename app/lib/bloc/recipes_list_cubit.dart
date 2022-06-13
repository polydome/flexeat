import 'dart:async';

import 'package:flexeat/domain/recipe.dart';
import 'package:flexeat/repository/recipe_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'navigation_cubit.dart';

class RecipesListCubit extends Cubit<List<Recipe>> {
  final RecipeRepository _recipeRepository;
  final NavigationCubit _navigationCubit;
  late final StreamSubscription _sub;

  RecipesListCubit(this._recipeRepository, this._navigationCubit) : super([]) {
    _sub = _recipeRepository.findAll().listen((recipes) {
      emit(recipes);
    });
  }

  void add() {
    _recipeRepository.create("Unnamed").then((recipeId) {
      _navigationCubit.navigateToRecipe(id: recipeId);
    });
  }

  @override
  Future<void> close() async {
    _sub.cancel();
    super.close();
  }
}
