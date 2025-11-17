// lib/features/auth/viewmodel/login_view_model.dart
import 'package:flutter/foundation.dart';

import '../model/login_model.dart';
import '../model/model_user.dart';
import '../service/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _service;

  AuthViewModel({AuthService? service}) : _service = service ?? AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  LoginResponse? _loginResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginResponse? get loginResponse => _loginResponse;

  /// Call login & update state using new LoginResponse model.
  Future<void> login(UserModel user) async {
    _setLoading(true);
    _setError(null);

    try {
      final resp = await _service.login(user);

      if (resp == null) {
        _setError("Server error: No response");
        _loginResponse = null;
      } else {
        final int? status = resp.statusId;
        final String? msg = resp.message;

        if (status == 200) {
          // SUCCESS
          _loginResponse = resp;
        } else {
          // FAILURE
          _loginResponse = null;
          _setError(msg ?? "Login failed.");
        }
      }
    } catch (e) {
      _loginResponse = null;
      _setError("Unexpected error: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Reset states
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _loginResponse = null;
    notifyListeners();
  }

  // --- internal setters ---
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }
}
