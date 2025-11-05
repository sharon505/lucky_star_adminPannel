// lib/core/network/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart';
import '../model/login_model.dart';
import '../model/model_user.dart';


class AuthService {
  final http.Client _client;
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<LoginResponse?> login(UserModel user) async {
    final uri = ApiEndpoints.agentLogin; // if you switched to Uri const, use it directly
    final headers = ApiEndpoints.formHeaders;
    final body = {
      'Username': user.usercode,
      'Password': user.password,
    };

    final res = await _client.post(uri, headers: headers, body: body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final Map<String, dynamic> json = jsonDecode(res.body);
      return LoginResponse.fromJson(json);
    } else {
      // Simple failure path
      return null;
    }
  }
}
