import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'cloudinary_service.dart';

class CategoryService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<String?> uploadCategoryImage(File imageFile) async {
    try {
      return await _cloudinaryService.pickAndUploadImageFromFile(imageFile);
    } catch (e) {
      print('Error uploading category image: $e');
      rethrow;
    }
  }

  Future<String> addCategory(
    Map<String, dynamic> categoryData,
    File? imageFile,
  ) async {
    try {
      final newCategoryRef = _database.child('categories').push();
      final categoryId = newCategoryRef.key!;

      Map<String, dynamic> categoryWithId = Map.from(categoryData);
      categoryWithId['id'] = categoryId;
      categoryWithId['createdAt'] = ServerValue.timestamp;

      if (imageFile != null) {
        final imageUrl = await uploadCategoryImage(imageFile);
        if (imageUrl != null) {
          categoryWithId['imageUrl'] = imageUrl;
        }
      }

      await newCategoryRef.set(categoryWithId);
      return categoryId;
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> categoryData,
    File? newImageFile,
  ) async {
    try {
      Map<String, dynamic> updateData = Map.from(categoryData);
      updateData['updatedAt'] = ServerValue.timestamp;

      if (newImageFile != null) {
        final imageUrl = await uploadCategoryImage(newImageFile);
        if (imageUrl != null) {
          updateData['imageUrl'] = imageUrl;
        }
      }

      await _database.child('categories').child(categoryId).update(updateData);
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _database.child('categories').child(categoryId).remove();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final DataSnapshot snapshot = await _database.child('categories').get();

      if (snapshot.value == null) return [];

      final Map<dynamic, dynamic> categoriesData =
          snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> categories = [];

      categoriesData.forEach((key, value) {
        if (value is Map) {
          Map<String, dynamic> categoryData = Map<String, dynamic>.from(value);
          categories.add(categoryData);
        }
      });

      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<void> addSubcategory(
    String categoryId,
    Map<String, dynamic> subcategoryData,
  ) async {
    try {
      final newSubcategoryRef = _database
          .child('categories')
          .child(categoryId)
          .child('subcategories')
          .push();
      final subcategoryId = newSubcategoryRef.key!;

      Map<String, dynamic> subcategoryWithId = Map.from(subcategoryData);
      subcategoryWithId['id'] = subcategoryId;
      subcategoryWithId['createdAt'] = ServerValue.timestamp;

      await newSubcategoryRef.set(subcategoryWithId);
    } catch (e) {
      print('Error adding subcategory: $e');
      rethrow;
    }
  }

  Future<void> updateSubcategory(
    String categoryId,
    String subcategoryId,
    Map<String, dynamic> subcategoryData,
  ) async {
    try {
      Map<String, dynamic> updateData = Map.from(subcategoryData);
      updateData['updatedAt'] = ServerValue.timestamp;

      await _database
          .child('categories')
          .child(categoryId)
          .child('subcategories')
          .child(subcategoryId)
          .update(updateData);
    } catch (e) {
      print('Error updating subcategory: $e');
      rethrow;
    }
  }

  Future<void> deleteSubcategory(
    String categoryId,
    String subcategoryId,
  ) async {
    try {
      await _database
          .child('categories')
          .child(categoryId)
          .child('subcategories')
          .child(subcategoryId)
          .remove();
    } catch (e) {
      print('Error deleting subcategory: $e');
      rethrow;
    }
  }

  Stream<DatabaseEvent> getCategoriesStream() {
    return _database.child('categories').onValue;
  }
}
