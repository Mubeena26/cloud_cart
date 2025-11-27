import 'package:cloud_cart/domain/product/entities/product_entity.dart';
import 'package:cloud_cart/domain/product/repositories/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<bool> call(ProductEntity product) async {
    return await repository.updateProduct(product);
  }
}
