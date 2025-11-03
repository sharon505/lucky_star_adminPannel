import 'package:flutter/material.dart';

class LoginFormProvider extends ChangeNotifier {
  // Controllers


  ///todo hard coded
  final TextEditingController usernameController = TextEditingController(
    // text: "Jebelali1"

    // text: 'BP RZ01'
  );

  final TextEditingController passwordController = TextEditingController(
    // text: 'ali1@123'

    // text: 'RZ01#123'
  );

  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  // Toggle Password Visibility
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // Validator for Username
  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Username is required";
    }
    return null;
  }

  // Validator for Password
  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }
    if (value.length < 4) {
      return "Password must be at least 4 characters";
    }
    return null;
  }

  // Check if form is valid
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  // Clear fields
  void reset() {
    usernameController.clear();
    passwordController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
