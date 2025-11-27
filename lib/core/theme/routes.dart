import 'package:cloud_cart/core/theme/ppages.dart';
import 'package:cloud_cart/presentation/products/add_product_screen.dart';

import 'package:cloud_cart/presentation/products/product_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route<dynamic>? genericRoute(RouteSettings settings) {
    switch (settings.name) {
      case PPages.addProduct:
        return MaterialPageRoute(builder: (context) => ProductPage());

      // case PPages.updatProduct:
      //   return MaterialPageRoute(
      //     builder: (context) => updateProductScreen(),
      //   );

      case PPages.addProdcut:
        return MaterialPageRoute(builder: (context) => AddProductScreen());

      default:
        return null;
    }
  }
}
