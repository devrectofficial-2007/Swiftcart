import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'cloudinary_service.dart';

class ProductService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<String?> uploadProductImage(File imageFile) async {
    try {
      return await _cloudinaryService.pickAndUploadImageFromFile(imageFile);
    } catch (e) {
      print('Error uploading product image: $e');
      rethrow;
    }
  }

  Future<String> addProduct(
    Map<String, dynamic> productData,
    List<File> imageFiles,
  ) async {
    try {
      final newProductRef = _database.child('products').push();
      final productId = newProductRef.key!;

      Map<String, dynamic> productWithId = Map.from(productData);
      productWithId['id'] = productId;
      productWithId['createdAt'] = ServerValue.timestamp;

      List<String> imageUrls = [];
      for (int i = 0; i < imageFiles.length; i++) {
        final imageUrl = await uploadProductImage(imageFiles[i]);
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      }

      productWithId['images'] = imageUrls;
      productWithId['faceImage'] = imageUrls.isNotEmpty ? imageUrls[0] : '';

      await newProductRef.set(productWithId);
      return productId;
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> productData,
    List<File>? newImageFiles,
    List<String>? existingImages,
  ) async {
    try {
      Map<String, dynamic> updateData = Map.from(productData);
      updateData['updatedAt'] = ServerValue.timestamp;

      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        List<String> imageUrls = [];
        for (int i = 0; i < newImageFiles.length; i++) {
          final imageUrl = await uploadProductImage(newImageFiles[i]);
          if (imageUrl != null) {
            imageUrls.add(imageUrl);
          }
        }

        if (existingImages != null) {
          imageUrls.addAll(existingImages);
        }

        updateData['images'] = imageUrls;
        updateData['faceImage'] = imageUrls.isNotEmpty ? imageUrls[0] : '';
      } else if (existingImages != null) {
        updateData['images'] = existingImages;
        updateData['faceImage'] = existingImages.isNotEmpty
            ? existingImages[0]
            : '';
      }

      await _database.child('products').child(productId).update(updateData);
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _database.child('products').child(productId).remove();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final DataSnapshot snapshot = await _database.child('products').get();

      if (snapshot.value == null) return [];

      final Map<dynamic, dynamic> productsData =
          snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> products = [];

      productsData.forEach((key, value) {
        if (value is Map) {
          Map<String, dynamic> productData = Map<String, dynamic>.from(value);
          products.add(productData);
        }
      });

      return products;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      final DataSnapshot snapshot = await _database
          .child('products')
          .child(productId)
          .get();

      if (snapshot.value == null) return null;

      return Map<String, dynamic>.from(snapshot.value as Map);
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  Stream<DatabaseEvent> getProductsStream() {
    return _database.child('products').onValue;
  }

  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String categoryId,
  ) async {
    try {
      final allProducts = await getAllProducts();
      return allProducts
          .where((product) => product['categoryId'] == categoryId)
          .toList();
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getProductsBySubcategory(
    String categoryId,
    String subcategoryId,
  ) async {
    try {
      final allProducts = await getAllProducts();
      return allProducts
          .where(
            (product) =>
                product['categoryId'] == categoryId &&
                product['subcategoryId'] == subcategoryId,
          )
          .toList();
    } catch (e) {
      print('Error fetching products by subcategory: $e');
      return [];
    }
  }
}
