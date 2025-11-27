import 'package:cloud_cart/core/common/widgets/product_card.dart';
import 'package:cloud_cart/core/theme/colors.dart';
import 'package:cloud_cart/core/theme/text_styles.dart';
import 'package:cloud_cart/presentation/products/add_product_screen.dart';
import 'package:cloud_cart/presentation/products/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductPage extends ConsumerWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productControllerProvider);
    final productsAsync = productState.products;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF3),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            padding: const EdgeInsets.only(top: 70, left: 16, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 177, 208, 183), Color(0xFFFBFBF3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Products',
                  style: getTextStylNunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff090F47),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        'No products yet. Add your first product!',
                        style: getTextStylNunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff85868A),
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 29,
                          childAspectRatio: 0.74,
                        ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        image: product.image,
                        title: product.name,
                        price: product.price.toInt(),
                        originalPrice: (product.price * 1.5).toInt(),
                        quantity: product.quantity,
                        isAvailable: product.quantity > 0,
                        hasDiscount: false,
                        discountText: "",
                        onEdit: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddProductScreen(productToEdit: product),
                            ),
                          );
                          // Refresh products after returning from edit screen
                          if (context.mounted) {
                            ref
                                .read(productControllerProvider.notifier)
                                .loadProducts();
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading products',
                        style: getTextStylNunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(productControllerProvider.notifier)
                              .loadProducts();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
          // Refresh products after returning from add product screen
          if (context.mounted) {
            ref.read(productControllerProvider.notifier).loadProducts();
          }
        },
        backgroundColor: PColors.color0C9C34,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: PColors.colorFFFFFF,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    // Header Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: const Color(0xff2B2B2B),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Filter",
                          style: getTextStylNunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff090F47),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Filter By Section
                    Text(
                      "Filter By",
                      style: getTextStylNunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff090F47),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildCheckbox("Cancer Drugs", true),
                    _buildCheckbox("Pain Relief"),
                    _buildCheckbox("Supplements"),
                    _buildCheckbox("Hygiene & Personal Care"),
                    _buildCheckbox("Medical Equipment’s"),

                    const SizedBox(height: 24),

                    // Brands Section
                    Text(
                      "Brands",
                      style: getTextStylNunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff090F47),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildCheckbox("All Brands"),
                    _buildCheckbox("Pfizer", true),
                    _buildCheckbox("Sun Pharmaceutical"),
                    _buildCheckbox("Dr. Reddy’s Laboratories"),
                    _buildCheckbox("Cipla"),
                    _buildCheckbox("Zydus Lifesciences"),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckbox(String title, [bool initial = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: initial,
            onChanged: (value) {},
            activeColor: Colors.green,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              style: getTextStylNunito(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xff261D21),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
