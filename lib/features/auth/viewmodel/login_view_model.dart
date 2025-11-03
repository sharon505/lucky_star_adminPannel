import 'package:flutter/material.dart';

import '../model/login_model.dart';
import '../model/model_user.dart';
import '../service/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  LoginResponse? _loginResponse;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  LoginResponse? get loginResponse => _loginResponse;
  String? get errorMessage => _errorMessage;

  Future<void> login(UserModel userModel) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(userModel: userModel);

      if (response != null) {
        _loginResponse = response;
      } else {
        _errorMessage = "Login failed. Please check your credentials.";
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _loginResponse = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
