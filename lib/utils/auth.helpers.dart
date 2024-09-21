import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eatsily/providers/custom_auth_provider.dart';

void handleLogout(BuildContext context, {Widget? redirectTo}) {
  final authProvider = Provider.of<CustomAuthProvider>(context, listen: false);
  authProvider.signOut(context, redirectTo: redirectTo);
}
