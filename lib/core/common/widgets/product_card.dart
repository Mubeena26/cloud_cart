import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_cart/core/theme/colors.dart';
import 'package:cloud_cart/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String title;
  final int price;
  final int originalPrice;
  final bool isAvailable;
  final bool hasDiscount;
  final String discountText;

  const ProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.isAvailable,
    required this.hasDiscount,
    required this.discountText,
  });
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isAvailable ? 1.0 : 0.5, // dimmed if out of stock
      child: Container(
        decoration: BoxDecoration(
          color: PColors.colorFFFFFF,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isAvailable ? Colors.transparent : Color(0xffF5F5F5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image and top tags
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                    height: 130,
                    width: 148,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xffEEEEF0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: image.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: image,
                              height: 100,
                              width: 100,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                ),

                // Discount badge
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xffED6B6B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        discountText,
                        style: getTextStylNunito(
                          color: PColors.colorFFFFFF,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),

                // // Approved badge only if in stock
                // if (isAvailable)
                //   Positioned(
                //     top: 8,
                //     right: 8,
                //     child: SvgPicture.asset(
                //     " "
                //       // height: 22,
                //       // width: 22,
                //     ),
                //   ),
              ],
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                title,
                style: getTextStylNunito(
                  color: const Color(0xff090F47),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Price and Stock
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "₹$price",
                    style: TextStyle(
                      fontFamily: "Overpass",
                      color: const Color(0xff090F47),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "₹$originalPrice",
                    style: TextStyle(
                      fontFamily: "Overpass",
                      color: const Color(0xff9D9EA4),
                      fontSize: 10,
                      decoration: TextDecoration.lineThrough,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Red "Out of Stock" if not available
                  if (!isAvailable)
                    Text(
                      "Out of Stock",
                      style: getTextStylNunito(
                        color: const Color(0xffD32F2F),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
