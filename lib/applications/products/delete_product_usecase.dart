import 'package:cloud_cart/domain/product/repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<bool> call(String productId) async {
    return await repository.deleteProduct(productId);
  }
}
