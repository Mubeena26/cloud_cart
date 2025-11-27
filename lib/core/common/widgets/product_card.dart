import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_cart/core/theme/colors.dart';
import 'package:cloud_cart/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String title;
  final int price;
  final int originalPrice;
  final int quantity;
  final bool isAvailable;
  final bool hasDiscount;
  final String discountText;
  final VoidCallback? onEdit; // optional callback for edit button

  const ProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.quantity,
    required this.isAvailable,
    required this.hasDiscount,
    required this.discountText,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isAvailable ? 1.0 : 0.5, // dimmed if out of stock
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: PColors.colorFFFFFF,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xffE0E0E0), // Light grey border
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // soft shadow
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image and top tags
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Container(
                    height: 112,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xffEEEEF0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: image.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: image,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
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
                        horizontal: 6,
                        vertical: 2,
                      ),
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
              ],
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                title,
                style: getTextStylNunito(
                  color: PColors.color000000,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),

            // Price and Quantity in Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Price section
                  Text(
                    "price : ",
                    style: getTextStylNunito(
                      color: const Color.fromARGB(255, 40, 41, 50),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "₹$price",
                    style: TextStyle(
                      fontFamily: "Overpass",
                      color: PColors.color0C9C34,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: 12),
                  // Quantity section
                  Text(
                    "quantity: ",
                    style: getTextStylNunito(
                      color: const Color.fromARGB(255, 40, 41, 50),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "$quantity",
                    style: const TextStyle(
                      fontFamily: "Overpass",
                      color: Color(0xff090F47),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isAvailable) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "Out of Stock",
                        style: getTextStylNunito(
                          color: const Color(0xffD32F2F),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Edit Elevated Button
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      onEdit ??
                      () {
                        debugPrint("Edit button pressed for $title");
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PColors.color0C9C34,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Edit",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


