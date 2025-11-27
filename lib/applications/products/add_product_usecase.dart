import 'package:cloud_cart/domain/product/entities/product_entity.dart';
import 'package:cloud_cart/domain/product/repositories/product_repository.dart';

class AddProductUseCase {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  Future<ProductEntity> call(ProductEntity product) async {
    return await repository.addProduct(product);
  }
}
