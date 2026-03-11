import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistItem {
  final String id;
  final String name;
  final String price;
  final String originalPrice;
  final String imageUrl;
  final double rating;
  final int reviews;
  final DateTime addedAt;

  WishlistItem({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviews': reviews,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      originalPrice: map['originalPrice'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviews: map['reviews'] ?? 0,
      addedAt: DateTime.fromMillisecondsSinceEpoch(
        map['addedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}

class WishlistService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> addToWishlist(WishlistItem item) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _database
          .child('users')
          .child(user.uid)
          .child('wishlist')
          .child(item.id)
          .set(item.toMap());
    } catch (e) {
      print('Error adding to wishlist: $e');
      rethrow;
    }
  }

  Future<void> removeFromWishlist(String itemId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _database
          .child('users')
          .child(user.uid)
          .child('wishlist')
          .child(itemId)
          .remove();
    } catch (e) {
      print('Error removing from wishlist: $e');
      rethrow;
    }
  }

  Future<bool> isInWishlist(String itemId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return false;

      DataSnapshot snapshot = await _database
          .child('users')
          .child(user.uid)
          .child('wishlist')
          .child(itemId)
          .get();

      return snapshot.exists;
    } catch (e) {
      print('Error checking wishlist: $e');
      return false;
    }
  }

  Future<void> toggleWishlist(WishlistItem item) async {
    bool inWishlist = await isInWishlist(item.id);
    if (inWishlist) {
      await removeFromWishlist(item.id);
    } else {
      await addToWishlist(item);
    }
  }

  Stream<List<WishlistItem>> getWishlistItems() {
    final User? user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _database
        .child('users')
        .child(user.uid)
        .child('wishlist')
        .onValue
        .map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      List<WishlistItem> items = [];
      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          Map<String, dynamic> itemData = Map<String, dynamic>.from(value);
          items.add(WishlistItem.fromMap(itemData));
        }
      });
      
      // Sort by addedAt (newest first)
      items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return items;
    });
  }

  Future<int> getWishlistItemCount() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 0;

      DataSnapshot snapshot = await _database
          .child('users')
          .child(user.uid)
          .child('wishlist')
          .get();

      if (!snapshot.exists) return 0;

      final Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;
      return data?.length ?? 0;
    } catch (e) {
      print('Error getting wishlist item count: $e');
      return 0;
    }
  }

  Future<void> clearWishlist() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _database
          .child('users')
          .child(user.uid)
          .child('wishlist')
          .remove();
    } catch (e) {
      print('Error clearing wishlist: $e');
      rethrow;
    }
  }
}
