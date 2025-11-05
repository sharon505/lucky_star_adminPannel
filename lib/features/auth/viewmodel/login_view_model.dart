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

  /// Call login and update state.
  Future<void> login(UserModel user) async {
    _setLoading(true);
    _setError(null);

    try {
      final resp = await _service.login(user);

      if (resp == null) {
        _setError('Login failed. Please try again.');
        _loginResponse = null;
      } else {
        // Optional: check statusId from first Result (if present)
        final status = resp.result.isNotEmpty ? resp.result.first.statusId : null;
        if (status == 200) {
          _loginResponse = resp;
        } else {
          _loginResponse = null;
          _setError(resp.result.isNotEmpty ? resp.result.first.msg : 'Login failed.');
        }
      }
    } catch (e) {
      _loginResponse = null;
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _loginResponse = null;
    notifyListeners();
  }

  // --- internal setters ---
  void _setLoading(bool v) {
    if (_isLoading == v) return;
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }
}
