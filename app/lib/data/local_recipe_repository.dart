import 'package:flexeat/data/live_repository.dart';
import 'package:flexeat/data/row.dart';
import 'package:flexeat/domain/article.dart';
import 'package:flexeat/domain/ingredient.dart';
import 'package:flexeat/domain/recipe.dart';
import 'package:flexeat/model/recipe_header.dart';
import 'package:flexeat/repository/recipe_repository.dart';
import 'package:sqflite/sqflite.dart';

import 'database.dart';

enum DataEvent { created }

class LocalRecipeRepository
    with LiveRepository<DataEvent>
    implements RecipeRepository {
  final Database _database;

  LocalRecipeRepository(this._database);

  @override
  Future<int> create(String name) async {
    final recipeHeader = RecipeHeader(name: name);
    final id = _database.insert(recipe$, recipeHeader.serialize());

    emit(DataEvent.created);

    return id;
  }

  Future<List<RecipeHeader>> findAllHeaders() async {
    final rows = await _database.query(recipe$);
    return rows.map((recipe) => recipe.toRecipeHeader()).toList();
  }

  @override
  Stream<List<RecipeHeader>> watchAllHeaders() async* {
    yield await findAllHeaders();
    yield* dataEvents
        .where((event) => event == DataEvent.created)
        .asyncMap((event) => findAllHeaders());
  }

  Future<List<Ingredient>> _findIngredientsById(int id) async {
    final rows = await _database.rawQuery(
        "SELECT * FROM ${ingredient$} INNER JOIN ${article$} ON ${ingredient$articleId} = ${article$id} WHERE ${recipe$id} = ?",
        [id]);

    return rows.map((row) => row.toIngredient()).toList();
  }

  Future<Recipe?> findById(int id) async {
    final rows = await _database
        .query(recipe$, where: "${recipe$id} = ?", whereArgs: [id]);

    if (rows.isEmpty) {
      return null;
    }

    final ingredients = await _findIngredientsById(id);

    return Recipe(
        header: rows.first.toRecipeHeader(), ingredients: ingredients);
  }

  @override
  Stream<Recipe?> watchById(int id) async* {
    yield await findById(id);

    yield* dataEvents.asyncMap((event) => findById(id));
  }

  @override
  Future<void> updateNameById(int id, {required String name}) async {
    await _database.update(recipe$, {recipe$name: name},
        where: "${recipe$id} = ?", whereArgs: [id]);
  }

  @override
  Future<void> addIngredientById(int id,
      {required int articleId, required int weight}) async {
    await _database.insert(ingredient$, {
      ingredient$articleId: articleId,
      ingredient$recipeId: id,
      ingredient$weight: weight
    });
  }
}

extension Serialization on RecipeHeader {
  Row serialize() {
    final Row row = {recipe$name: name};

    if (id != 0) {
      row[recipe$id] = id;
    }

    return row;
  }
}

extension ToRecipe on Row {
  RecipeHeader toRecipeHeader() =>
      RecipeHeader(id: this[recipe$id], name: this[recipe$name]);

  Ingredient toIngredient() => Ingredient(
      weight: this[ingredient$weight],
      article:
          Article(id: this[ingredient$articleId], name: this[article$name]));
}