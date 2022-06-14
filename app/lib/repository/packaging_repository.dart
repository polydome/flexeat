import 'package:flexeat/model/packaging.dart';
import 'package:flexeat/model/product.dart';

abstract class PackagingRepository {
  Future<List<Packaging>> findAllByProductId(int productId);
  Future<Packaging?> findById(int packagingId);
  Future<Product?> findProductByPackagingId(int packagingId);
  Future<Packaging> create(int productId, Packaging packaging);
}
