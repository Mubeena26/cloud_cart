import 'package:cloud_cart/domain/product/entities/product_entity.dart';
import 'package:cloud_cart/domain/product/repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<ProductEntity>> call() async {
    return await repository.getProducts();
  }
}
