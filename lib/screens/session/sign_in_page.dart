import 'package:eatsily/screens/session/passwd_reset_page.dart';
import 'package:flutter/material.dart';
import 'package:eatsily/services/auth_service.dart';
import 'package:eatsily/widgets/common_widget.dart';
import 'package:eatsily/widgets/sign_in_fields_widget.dart';
import 'package:eatsily/widgets/sign_in_button_widget.dart';
import 'package:eatsily/widgets/register_button_widget.dart';
import 'package:eatsily/widgets/password_reset_text_widget.dart';
import 'package:eatsily/screens/session/sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Email and password controllers
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  // Error message
  String? errorMessage = '';

  // Authentication logic moved to AuthService
  Future<bool> _signIn() async {
    return await AuthService().signInWithEmailAndPassword(
      email: _controllerEmail.text,
      password: _controllerPassword.text,
      onError: (error) {
        setState(() {
          errorMessage = error;
        });
      },
    );
  }

  // Authentication logic moved to AuthService
  Future<void> _signUpPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  Future<void> _passwdPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PasswdReset()),
    );
  }

  // Build method with extracted widgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CommonWidgets.background(),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                CommonWidgets.title(),
                _buildForm(),
                const SizedBox(height: 10),
                _buildButtons(),
                _buildErrorMessage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Extracted form as a separate method for better organization
  Widget _buildForm() {
    return Column(
      children: [
        EntryEmailField(controller: _controllerEmail),
        EntryPasswordField(controller: _controllerPassword),
      ],
    );
  }

  // Extracted buttons
  Widget _buildButtons() {
    return Column(
      children: [
        SubmitButton(onPressed: _signIn),
        const SizedBox(height: 10),
        RegisterButton(onPressed: _signUpPage),
        PasswordResetText(onPressed: _passwdPage),
      ],
    );
  }

  // Error message display
  Widget _buildErrorMessage() {
    return errorMessage != null && errorMessage!.isNotEmpty
        ? Text(errorMessage!, style: const TextStyle(color: Colors.red))
        : Container();
  }
}
