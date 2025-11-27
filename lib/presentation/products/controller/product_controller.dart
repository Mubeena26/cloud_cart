import 'package:cloud_cart/applications/products/add_product_usecase.dart';
import 'package:cloud_cart/applications/products/get_product_usecase.dart';
import 'package:cloud_cart/domain/product/entities/product_entity.dart';
import 'package:cloud_cart/domain/product/repositories/product_repository.dart';
import 'package:cloud_cart/infrastructure/products/product_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl();
});

// UseCase Providers
final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productRepositoryProvider));
});

final addProductUseCaseProvider = Provider<AddProductUseCase>((ref) {
  return AddProductUseCase(ref.watch(productRepositoryProvider));
});

// Product State
class ProductState {
  final AsyncValue<List<ProductEntity>> products;
  final bool isLoading;

  ProductState({
    required this.products,
    this.isLoading = false,
  });

  ProductState copyWith({
    AsyncValue<List<ProductEntity>>? products,
    bool? isLoading,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ProductController
class ProductController extends StateNotifier<ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final AddProductUseCase addProductUseCase;

  ProductController({
    required this.getProductsUseCase,
    required this.addProductUseCase,
  }) : super(ProductState(products: const AsyncValue.loading())) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(products: const AsyncValue.loading());
    try {
      final products = await getProductsUseCase();
      state = state.copyWith(products: AsyncValue.data(products));
    } catch (e, stackTrace) {
      state = state.copyWith(products: AsyncValue.error(e, stackTrace));
    }
  }

  Future<bool> addProduct(ProductEntity product) async {
    state = state.copyWith(isLoading: true);
    try {
      await addProductUseCase(product);
      await loadProducts(); // Refresh the list
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e, stackTrace) {
      state = state.copyWith(isLoading: false);
      // Log the error for debugging
      print('Error adding product: $e');
      print('Stack trace: $stackTrace');
      // Re-throw to let the UI handle the error message
      throw e;
    }
  }
}

// ProductController Provider
final productControllerProvider =
    StateNotifierProvider<ProductController, ProductState>(
  (ref) {
    return ProductController(
      getProductsUseCase: ref.watch(getProductsUseCaseProvider),
      addProductUseCase: ref.watch(addProductUseCaseProvider),
    );
  },
);

