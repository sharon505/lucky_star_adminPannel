// lib/features/reports/service/distributor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart';          // has ApiEndpoints.getAgent
import '../models/distributor_models.dart';                 // DistributorListResponse, DistributorItem

class DistributorService {
  final http.Client _client;
  final Duration timeout;

  DistributorService({
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  /// Fetch distributors from USP_GetDistributor_LIST.
  ///
  /// - GET by default.
  /// - If your API requires POST (with empty body), set [usePost] = true.
  /// - For JSON POST, set [asJson] = true to send '{}' with 'application/json'.
  Future<DistributorListResponse> fetchDistributors({
    bool usePost = false,
    bool asJson = false,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = ApiEndpoints.getAgent;

    final headers = <String, String>{
      if (usePost && asJson) 'Content-Type': 'application/json',
      if (extraHeaders != null) ...extraHeaders,
    };

    late http.Response res;
    if (usePost) {
      // Empty body: '{}' if asJson, or empty form body otherwise
      res = await _client
          .post(uri, headers: headers, body: asJson ? '{}' : const {})
          .timeout(timeout);
    } else {
      res = await _client.get(uri, headers: headers).timeout(timeout);
    }

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return DistributorListResponse.fromJson(decoded);
  }

  void dispose() => _client.close();
}
