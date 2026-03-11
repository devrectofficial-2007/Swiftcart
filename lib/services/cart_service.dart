import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartItem {
  final String id;
  final String name;
  final String price;
  final String originalPrice;
  final String imageUrl;
  final int quantity;
  final double rating;
  final int reviews;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.quantity,
    required this.rating,
    required this.reviews,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'rating': rating,
      'reviews': reviews,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      originalPrice: map['originalPrice'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      quantity: map['quantity'] ?? 1,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviews: map['reviews'] ?? 0,
    );
  }
}

class CartService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> addToCart(CartItem item) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final DatabaseReference cartRef = _database
          .child('users')
          .child(user.uid)
          .child('cart')
          .child(item.id);

      // Check if item already exists
      DataSnapshot snapshot = await cartRef.get();
      if (snapshot.exists) {
        // Update quantity
        int currentQuantity = snapshot.child('quantity').value as int? ?? 1;
        await cartRef.update({'quantity': currentQuantity + 1});
      } else {
        // Add new item
        await cartRef.set(item.toMap());
      }
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _database
          .child('users')
          .child(user.uid)
          .child('cart')
          .child(itemId)
          .remove();
    } catch (e) {
      print('Error removing from cart: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      if (quantity <= 0) {
        await removeFromCart(itemId);
      } else {
        await _database
            .child('users')
            .child(user.uid)
            .child('cart')
            .child(itemId)
            .update({'quantity': quantity});
      }
    } catch (e) {
      print('Error updating quantity: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _database
          .child('users')
          .child(user.uid)
          .child('cart')
          .remove();
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
    }
  }

  Stream<List<CartItem>> getCartItems() {
    final User? user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _database
        .child('users')
        .child(user.uid)
        .child('cart')
        .onValue
        .map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      List<CartItem> items = [];
      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          Map<String, dynamic> itemData = Map<String, dynamic>.from(value);
          items.add(CartItem.fromMap(itemData));
        }
      });
      return items;
    });
  }

  Future<int> getCartItemCount() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 0;

      DataSnapshot snapshot = await _database
          .child('users')
          .child(user.uid)
          .child('cart')
          .get();

      if (!snapshot.exists) return 0;

      final Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return 0;

      int totalItems = 0;
      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          totalItems += (value['quantity'] as int? ?? 1);
        }
      });
      return totalItems;
    } catch (e) {
      print('Error getting cart item count: $e');
      return 0;
    }
  }

  double calculateTotal(List<CartItem> items) {
    double total = 0.0;
    for (var item in items) {
      // Remove ₹ and convert to double
      String priceStr = item.price.replaceAll('₹', '').replaceAll(',', '');
      double price = double.tryParse(priceStr) ?? 0.0;
      total += price * item.quantity;
    }
    return total;
  }
}
