import 'dart:async';

import 'package:flexeat/data/row.dart';
import 'package:flexeat/domain/product.dart';
import 'package:flexeat/repository/product_repository.dart';
import 'package:sqflite/sqflite.dart';

const productTable = 'product';
const nameColumn = 'name';
const idColumn = 'id';

enum DataEvent { productCreated, productChanged }

class LocalProductRepository implements ProductRepository {
  final Database _database;
  final StreamController<DataEvent> _dataEventController =
      StreamController(sync: true);

  Stream<DataEvent> get dataEvents => _dataEventController.stream;

  void emit(DataEvent dataEvent) {
    _dataEventController.add(dataEvent);
  }

  LocalProductRepository(this._database);

  @override
  Future<Product> create(Product product) async {
    if (product.id != 0) {
      throw UnimplementedError("Creating products with ID not supported.");
    }

    final productId = await _database.insert(productTable, _serialize(product));

    emit(DataEvent.productCreated);

    return product.copyWith(id: productId);
  }

  @override
  Future<List<Product>> findAll() async {
    final rows = await _database.query(productTable);
    final products =
        rows.map((row) => _deserialize(row)).toList(growable: false);
    return products;
  }

  @override
  Future<Product> findById(int id) async {
    final rows = await _database
        .query(productTable, where: '$idColumn = ?', whereArgs: [id]);
    return _deserialize(rows.first);
  }

  @override
  Future<void> update(Product product) async {
    await _database.update(productTable, _serialize(product),
        where: '$idColumn = ?', whereArgs: [product.id]);

    emit(DataEvent.productChanged);
  }

  @override
  Stream<List<Product>> watchAll() async* {
    final applicableEvents = [
      DataEvent.productCreated,
      DataEvent.productChanged
    ];

    yield await findAll();
    yield* dataEvents
        .where((event) => applicableEvents.contains(event))
        .asyncMap((event) => findAll());
  }

  Row _serialize(Product product) {
    return {
      idColumn: product.id > 0 ? product.id : null,
      nameColumn: product.name
    };
  }

  Product _deserialize(Row row) {
    return Product(id: row[idColumn], name: row[nameColumn]);
  }
}
