import 'package:cloud_cart/domain/product/entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts();
  Future<ProductEntity> addProduct(ProductEntity product);
  Future<bool> updateProduct(ProductEntity product);
  Future<bool> deleteProduct(String productId);
}
