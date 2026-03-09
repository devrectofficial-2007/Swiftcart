import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'admin_screen.dart';
import 'user_screen.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("Login with Google"),
          onPressed: () async {
            var user = await _authService.signInWithGoogle();
            if (user != null) {
              await _authService.saveUserToDB(user);
              String role = await _authService.getUserRole(user.uid);

              if (role == "admin") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (c) => AdminScreen()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (c) => UserScreen()),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
