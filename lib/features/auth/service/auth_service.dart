import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart';
/// Make sure these are correct in your project:
/// AppString.baseUrl = 'https://esonxtapi.cgpil.in:53758/SoBranch.asmx/';
/// AppString.header  = {'Content-Type': 'application/x-www-form-urlencoded'};
import '../model/login_model.dart';
import '../model/model_user.dart';

/// Reusable, system-trust HTTP client (no pinning, no insecure bypass).
final http.Client _client = http.Client();

class AuthService {
  static const _timeout = Duration(seconds: 20);

  /// Builds a safe HTTPS Uri from baseUrl + relative path.
  Uri _buildUri(String relativePath) {
    // Ensures exactly one slash between base and path.
    final base = ApiEndpoints.baseUrl;
    final normalized = base.endsWith('/') ? base : '$base/';
    return Uri.parse('$normalized$relativePath');
  }

  Future<LoginResponse?> login({required UserModel userModel}) async {
    try {
      // ✅ MUST be the hostname that matches your cert; do NOT use the raw IP.
      final uri = _buildUri('Login');

      // For classic .asmx endpoints, form-url-encoded is typical.
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        ...?ApiEndpoints.header, // your header can override/add (but keep content-type)
      };

      final body = {
        'Username': userModel.usercode,
        'Password': userModel.password,
      };

      final res = await _client.post(uri, headers: headers, body: body).timeout(_timeout);

      // Debug logs
      // ignore: avoid_print
      print('🔵 Status: ${res.statusCode}  📍 ${uri.toString()}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // If server returns JSON string with possible UTF-8, decode safely:
        final text = utf8.decode(res.bodyBytes);
        // Some .asmx return JSON payloads wrapped or raw; adjust if needed.
        final decoded = jsonDecode(text);
        return LoginResponse.fromJson(decoded);
      } else {
        // ignore: avoid_print
        print('❌ Login failed: ${res.statusCode}\n${res.body}');
        return null;
      }
    } on HandshakeException catch (e) {
      // ignore: avoid_print
      print('🔴 TLS Handshake failed: $e');
      // Most common server-side causes:
      //  1) Missing intermediate CA (serve full chain)
      //  2) Hostname mismatch (use the exact domain in AppString.baseUrl)
      //  3) Expired/old chain (renew cert; serve ISRG Root X1 chain)
      return null;
    } on SocketException catch (e) {
      // ignore: avoid_print
      print('🔴 Network error: $e');
      return null;
    } on FormatException catch (e) {
      // ignore: avoid_print
      print('🟠 Response was not valid JSON: $e');
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('🔴 Unexpected error: $e');
      return null;
    }
  }
}
