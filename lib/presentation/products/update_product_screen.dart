
import 'package:cloud_cart/core/common/widgets/custom_elevated_text_button.dart';
import 'package:cloud_cart/core/theme/colors.dart';
import 'package:cloud_cart/core/theme/text_styles.dart';
import 'package:cloud_cart/presentation/products/add_product_screen.dart';
import 'package:flutter/material.dart';

class updateProductScreen extends StatelessWidget {
  const updateProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF3),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 43,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: PColors.colorFFFFFF,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: Color(0xff2B2B2B),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD7EFDB), Color(0xFFFBFBF3)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            centerTitle: true,
            title: Transform.translate(
              offset: Offset(-50, 0),
              child: Text(
                'Add Product',
                style: getTextStylNunito(
                  color: Color(0xff090F47),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Are you want to Delete ?',
                            style: getTextStylNunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff090F47),
                            ),
                          ),
                          const Divider(height: 24),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              // Add delete logic here
                            },
                            child: Text(
                              'Yes',
                              style: getTextStylNunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const Divider(height: 24),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'No',
                              style: getTextStylNunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xff424242),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: Container(
                    height: 43,
                    width: 43,
                    decoration: BoxDecoration(
                      color: PColors.colorFFFFFF,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    // child: Center(child: SvgPicture.asset(Svgs.delete)),
                  ),
                ),
              ),
            ],
          )),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              child: SingleChildScrollView(
                child: Column(
                  children: const [
                    AddProductBody(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: CustomElavatedTextButton(
          onPressed: () {
            // Navigator.pushNamed(context, PPages.bottomNav);
          },
          bgcolor: PColors.color0C9C34,
          text: "Update Product",
          textColor: PColors.colorFFFFFF,
          borderColor: Colors.transparent,
          borderRadius: 16,
        ),
      ),
    );
  }
}
