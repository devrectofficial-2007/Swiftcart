import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");

  // Google Sign In Function
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (e) {
      print("Error in Google Sign-In: $e");
      return null;
    }
  }

  // Check Role from RTDB
  Future<String> getUserRole(String uid) async {
    final snapshot = await _dbRef.child(uid).get();
    if (snapshot.exists) {
      return snapshot.child("role").value.toString();
    } else {
      return "user"; // Default role
    }
  }

  // Save new user to RTDB
  Future<void> saveUserToDB(User user) async {
    final snapshot = await _dbRef.child(user.uid).get();
    if (!snapshot.exists) {
      await _dbRef.child(user.uid).set({
        "name": user.displayName,
        "email": user.email,
        "role": "user", // Default
        "createdAt": ServerValue.timestamp,
      });
    }
  }
}
