import '../domain/product.dart';

abstract class ProductRepository {
  Future<Product> create(Product product);
  Future<Product> findById(int id);
  Future<void> update(Product product);
}