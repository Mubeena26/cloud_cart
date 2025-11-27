import 'dart:io';
import 'package:cloud_cart/core/common/widgets/custom_elevated_text_button.dart';
import 'package:cloud_cart/core/common/widgets/custom_text_field.dart';
import 'package:cloud_cart/core/supabase_clien.dart';
import 'package:cloud_cart/core/theme/colors.dart';
import 'package:cloud_cart/core/theme/text_styles.dart';
import 'package:cloud_cart/domain/product/entities/product_entity.dart';
import 'package:cloud_cart/presentation/products/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddProductBody extends ConsumerStatefulWidget {
  const AddProductBody({super.key});

  @override
  ConsumerState<AddProductBody> createState() => _AddProductBodyState();
}

class _AddProductBodyState extends ConsumerState<AddProductBody> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error picking image: ${e.toString()}\nPlease ensure the app has been fully rebuilt after adding image_picker dependency.',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<String?> _uploadImageToSupabase(File imageFile) async {
    try {
      // Generate unique file name
      final uuid = const Uuid();
      final fileName = '${uuid.v4()}.png';
      const bucketName = 'product';

      // Upload to Supabase Storage (using File as SDK requires)
      final res = await SupabaseClientManager.client.storage
          .from(bucketName)
          .upload(fileName, imageFile);

      // Check for upload errors
      if (res.isEmpty) {
        throw Exception('Upload failed: Empty response');
      }

      // Get public URL
      final imageUrl = SupabaseClientManager.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error uploading image: $e';

        // Provide more specific error messages
        if (e.toString().contains('Bucket not found') ||
            e.toString().contains('404')) {
          errorMessage =
              'Storage bucket "product-images" not found. Please create it in your Supabase dashboard.';
        } else if (e.toString().contains('permission') ||
            e.toString().contains('403')) {
          errorMessage =
              'Permission denied. Please check your Supabase Storage policies for the "product-images" bucket.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 6),
          ),
        );
      }
      return null;
    }
  }

  Future<void> _addProduct() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter product name')),
      );
      return;
    }

    if (_priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter product price')),
      );
      return;
    }

    final priceValue = double.tryParse(_priceController.text.trim());
    if (priceValue == null || priceValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price greater than 0'),
        ),
      );
      return;
    }

    if (_quantityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter product quantity')),
      );
      return;
    }

    final quantityValue = int.tryParse(_quantityController.text.trim());
    if (quantityValue == null || quantityValue < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid quantity (0 or greater)'),
        ),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image first
      final imageUrl = await _uploadImageToSupabase(_selectedImage!);
      if (imageUrl == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create product entity (values already validated above)
      final product = ProductEntity(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        price: priceValue,
        quantity: quantityValue,
        image: imageUrl,
      );

      // Add product using controller
      final controller = ref.read(productControllerProvider.notifier);

      try {
        final success = await controller.addProduct(product);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product added successfully!')),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Provide user-friendly error messages
          String errorMessage = 'Failed to add product';
          final errorString = e.toString().toLowerCase();
          bool isRLSError = false;

          if (errorString.contains('row-level security') ||
              errorString.contains('rls') ||
              (errorString.contains('permission') &&
                  errorString.contains('policy'))) {
            // Extract the detailed error message from the exception
            isRLSError = true;
            errorMessage = e.toString();
            // Remove the "Exception: " prefix if present
            if (errorMessage.startsWith('Exception: ')) {
              errorMessage = errorMessage.substring(11);
            }
          } else if (errorString.contains('column') &&
              (errorString.contains('schema cache') ||
                  errorString.contains('not found'))) {
            errorMessage =
                'Database column mismatch!\n\n'
                'The image column name in your Product table doesn\'t match.\n'
                'Please check your Supabase dashboard and update the column name in:\n'
                'lib/infrastructure/products/product_repository_impl.dart\n'
                'Change the "imageColumnName" constant to match your database.';
          } else if (errorString.contains('permission') ||
              errorString.contains('policy')) {
            errorMessage =
                'Permission denied. Please check your database permissions.';
          } else if (errorString.contains('duplicate') ||
              errorString.contains('unique')) {
            errorMessage = 'A product with this ID already exists.';
          } else if (errorString.contains('null') ||
              errorString.contains('required')) {
            errorMessage =
                'Missing required fields. Please check all fields are filled.';
          } else if (errorString.contains('network') ||
              errorString.contains('connection')) {
            errorMessage =
                'Network error. Please check your internet connection.';
          } else {
            errorMessage = 'Failed to add product: ${e.toString()}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SingleChildScrollView(
                child: Text(errorMessage, style: const TextStyle(fontSize: 13)),
              ),
              duration: isRLSError
                  ? const Duration(seconds: 15)
                  : const Duration(seconds: 5),
              backgroundColor: Colors.red,
              action: isRLSError
                  ? SnackBarAction(
                      label: 'Dismiss',
                      textColor: Colors.white,
                      onPressed: () {},
                    )
                  : null,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          CustomTextFeild(
            controller: _nameController,
            hintText: "Enter product name",
            filColor: const Color(0xffF3F2E9),
            borderColor: Colors.transparent,
            borderRadius: 12,
            textHead: "Product Name",
            headTextStyle: getTextStylNunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xff424242),
            ),
          ),
          const SizedBox(height: 16),

          // Product Image
          Text(
            "Product Image",
            style: getTextStylNunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xff424242),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xffF3F2E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xffE5E4E4)),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : const Center(child: Icon(Icons.add, color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 16),

          // Price
          CustomTextFeild(
            controller: _priceController,
            hintText: "₹100",
            filColor: const Color(0xffF3F2E9),
            borderColor: Colors.transparent,
            borderRadius: 12,
            textHead: "Price",
            headTextStyle: getTextStylNunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xff424242),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Quantity
          CustomTextFeild(
            controller: _quantityController,
            hintText: "Enter quantity",
            filColor: const Color(0xffF3F2E9),
            borderColor: Colors.transparent,
            borderRadius: 12,
            textHead: "Quantity",
            headTextStyle: getTextStylNunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xff424242),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final GlobalKey<_AddProductBodyState> _bodyKey =
      GlobalKey<_AddProductBodyState>();

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
          title: Padding(
            padding: const EdgeInsets.only(right: 110),
            child: Text(
              'Add Product',
              style: getTextStylNunito(
                color: const Color(0xff090F47),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              child: AddProductBody(key: _bodyKey),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Consumer(
          builder: (context, ref, child) {
            final isLoading = ref.watch(productControllerProvider).isLoading;
            final bodyState = _bodyKey.currentState;
            final isLocalLoading = bodyState?._isLoading ?? false;

            return CustomElavatedTextButton(
              onPressed: (isLoading || isLocalLoading)
                  ? null
                  : () {
                      bodyState?._addProduct();
                    },
              bgcolor: PColors.color0C9C34,
              text: (isLoading || isLocalLoading) ? "Adding..." : "Add Product",
              textColor: PColors.colorFFFFFF,
              borderColor: Colors.transparent,
              borderRadius: 16,
            );
          },
        ),
      ),
    );
  }
}
