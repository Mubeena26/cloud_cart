import 'package:cloud_cart/core/supabase_clien.dart';
import 'package:cloud_cart/domain/product/entities/product_entity.dart';
import 'package:cloud_cart/domain/product/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final supabase = SupabaseClientManager.client;

  // Column name mapping - Update this to match your Supabase Product table schema
  // Common image column names: 'image', 'imageUrl', 'image_url', 'photo', 'photoUrl'
  // To find your column name: Check your Supabase dashboard -> Table Editor -> Product table
  // OR: The code will try to auto-detect it from existing products
  static String? _detectedImageColumnName;

  // Try to detect the image column name from existing data
  Future<String?> _detectImageColumnName() async {
    if (_detectedImageColumnName != null) return _detectedImageColumnName;

    try {
      final response = await supabase.from('Product').select('*').limit(1);
      if (response.isNotEmpty) {
        final firstRow = response.first;
        // Check for common image column names
        final possibleNames = [
          'image',
          'imageUrl',
          'image_url',
          'photo',
          'photoUrl',
          'Image',
          'ImageUrl',
        ];
        for (final name in possibleNames) {
          if (firstRow.containsKey(name)) {
            _detectedImageColumnName = name;
            print('Auto-detected image column name: $name');
            return name;
          }
        }
      }
    } catch (e) {
      print('Could not auto-detect image column: $e');
    }
    return null;
  }

  String get imageColumnName {
    // Try common names first, then fall back to detection
    // You can override this by setting _detectedImageColumnName manually
    return _detectedImageColumnName ?? 'images';
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    try {
      final response = await supabase.from('Product').select('*');

      return response
          .map<ProductEntity>((data) => ProductEntity.fromJson(data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProductEntity> addProduct(ProductEntity product) async {
    try {
      // Try to detect the image column name if not already detected
      if (_detectedImageColumnName == null) {
        await _detectImageColumnName();
      }

      // Create a copy of the JSON and map field names to match database schema
      final productData = <String, dynamic>{};

      // Map fields - adjust column names to match your Supabase table schema
      // Common variations: image -> imageUrl, image_url, photo, photoUrl
      // Note: ID is NOT included here - let the database auto-generate it (bigint/serial)
      productData['name'] = product.name;
      productData['price'] = product.price;
      productData['quantity'] = product.quantity;

      // Use the detected or configured column name for image
      final imgColumn = imageColumnName;
      productData[imgColumn] = product.image;

      final response = await supabase
          .from('Product')
          .insert(productData)
          .select();

      if (response.isEmpty) {
        throw Exception(
          'Failed to insert product: Empty response from database',
        );
      }

      return ProductEntity.fromJson(response.first);
    } catch (e) {
      // Log the error for debugging
      print('Repository error adding product: $e');

      // Handle Row-Level Security (RLS) policy violation
      if (e.toString().contains('row-level security policy') ||
          e.toString().contains('42501') ||
          e.toString().contains('violates row-level security')) {
        throw Exception(
          'Permission Denied: Row-Level Security (RLS) Policy Violation\n\n'
          'Your Supabase table has Row-Level Security enabled, but there\'s no policy '
          'allowing INSERT operations.\n\n'
          'To fix this:\n'
          '1. Go to your Supabase Dashboard\n'
          '2. Navigate to: Authentication > Policies (or Table Editor > Product > RLS)\n'
          '3. Click "New Policy" for the Product table\n'
          '4. Create an INSERT policy with one of these options:\n'
          '   - For authenticated users: "Enable insert for authenticated users only"\n'
          '   - For all users: "Enable insert for all users" (less secure)\n'
          '   - Custom: Create a policy that allows INSERT operations\n\n'
          'Example policy SQL:\n'
          'CREATE POLICY "Allow insert for authenticated users" ON "Product"\n'
          'FOR INSERT TO authenticated\n'
          'WITH CHECK (true);',
        );
      }

      // Handle bigint ID type mismatch error
      if (e.toString().contains('invalid input syntax for type bigint') ||
          e.toString().contains('22P02')) {
        throw Exception(
          'ID type mismatch: Your database uses auto-incrementing integer IDs (bigint), '
          'but the code tried to insert a UUID. The ID field has been removed from inserts '
          'to let the database auto-generate it.',
        );
      }

      // Provide helpful error message about column names
      if (e.toString().contains('column') &&
          e.toString().contains('schema cache')) {
        // Try to get column names from an existing product to help debug
        String columnInfo = '';
        try {
          final sampleResponse = await supabase
              .from('Product')
              .select('*')
              .limit(1);
          if (sampleResponse.isNotEmpty) {
            final sampleRow = sampleResponse.first;
            final columns = sampleRow.keys.toList();
            columnInfo =
                '\nFound columns in Product table: ${columns.join(", ")}';
          } else {
            columnInfo =
                '\nProduct table appears to be empty. Please check your Supabase dashboard for column names.';
          }
        } catch (_) {
          // Ignore errors when trying to get column info
        }

        throw Exception(
          'Column mismatch error: ${e.toString()}\n'
          'The image column name doesn\'t match your database schema.$columnInfo\n'
          'To fix: Open lib/infrastructure/products/product_repository_impl.dart\n'
          'and manually set _detectedImageColumnName or update the imageColumnName getter default value.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<bool> updateProduct(ProductEntity product) async {
    try {
      // Map fields to match database schema (same as addProduct)
      final productData = <String, dynamic>{};
      productData['name'] = product.name;
      productData['price'] = product.price;
      productData['quantity'] = product.quantity;
      productData[imageColumnName] = product.image;

      await supabase.from('Product').update(productData).eq('id', product.id);

      return true;
    } catch (e) {
      print('Repository error updating product: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteProduct(String productId) async {
    try {
      await supabase.from('Product').delete().eq('id', productId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
