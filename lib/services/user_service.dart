import 'package:firebase_database/firebase_database.dart';

class UserService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final DataSnapshot snapshot = await _database.child('users').get();
      
      if (snapshot.value == null) return [];
      
      final Map<dynamic, dynamic> usersData = snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> users = [];
      
      usersData.forEach((key, value) {
        if (value is Map) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(value);
          userData['uid'] = key;
          users.add(userData);
        }
      });
      
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _database.child('users').child(uid).update({'role': role});
    } catch (e) {
      print('Error updating user role: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _database.child('users').child(uid).remove();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  Stream<DatabaseEvent> getUsersStream() {
    return _database.child('users').onValue;
  }
}
