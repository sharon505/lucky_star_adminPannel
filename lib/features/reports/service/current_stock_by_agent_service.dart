// lib/features/reports/service/current_stock_by_agent_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart';

class CurrentStockByAgentService {
  final http.Client _client;
  final Duration timeout;

  CurrentStockByAgentService({
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  /// Calls REPORT_STOCK_BALANCE_OF_DISTRIBUTOR endpoint.
  ///
  /// Required:
  /// - [productId]  -> POST field "PRODUCT_ID"
  /// - [agentId]    -> POST field "AGENT_ID"
  ///
  /// Transport:
  /// - If [asJson] is false (default), sends form-url-encoded body.
  /// - If [asJson] is true, sends JSON: {"PRODUCT_ID": "...", "AGENT_ID": "..."}.
  ///
  /// Returns decoded JSON (Map). Handle shape according to your API.
  Future<Map<String, dynamic>> fetch({
    required int productId,
    required int agentId,
    bool asJson = false,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = ApiEndpoints.currentStockByAgent;

    final fields = <String, String>{
      'PRODUCT_ID': productId.toString(),
      'AGENT_ID': agentId.toString(),
    };

    final headers = <String, String>{
      if (asJson) 'Content-Type': 'application/json',
      if (extraHeaders != null) ...extraHeaders,
    };

    late http.Response res;
    if (asJson) {
      res = await _client
          .post(uri, headers: headers, body: jsonEncode(fields))
          .timeout(timeout);
    } else {
      res = await _client
          .post(uri, headers: headers, body: fields)
          .timeout(timeout);
    }

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    // If API returns a list at top-level, wrap it.
    return {'Result': decoded};
  }

  void dispose() => _client.close();
}
