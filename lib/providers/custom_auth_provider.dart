import 'package:flutter/material.dart';
import 'package:eatsily/services/auth_service.dart';
import 'package:eatsily/widget_tree.dart';

class CustomAuthProvider extends ChangeNotifier {
  final AuthService _authService;

  CustomAuthProvider(this._authService);

  Future<void> signOut(BuildContext context,{Widget? redirectTo}) async {
    await _authService.signOut();
    if (context.mounted && redirectTo != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => redirectTo,
        ),
      );
    }
  }
}
