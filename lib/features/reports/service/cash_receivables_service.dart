// lib/features/reports/service/cash_receivables_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart'; // exposes ApiEndpoints.cashReceivablesByAgent
import '../models/cash_receivables_models.dart';

class CashReceivablesService {
  final http.Client _client;
  final Duration timeout;

  CashReceivablesService({
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  /// POST -> ApiEndpoints.cashReceivablesByAgent
  /// Body (form-url-encoded):
  ///   agentid: <int>
  ///   PRODUCT_ID: <int>
  Future<CashReceivableListResponse> fetchByAgent({
    required int agentId,
    required int productId,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = ApiEndpoints.cashReceivablesByAgent;

    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
      if (extraHeaders != null) ...extraHeaders,
    };

    final body = {
      'agentid': agentId.toString(),
      'PRODUCT_ID': productId.toString(),
    };

    final res = await _client
        .post(uri, headers: headers, body: body)
        .timeout(timeout);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return CashReceivableListResponse.fromJson(decoded);
  }

  void dispose() => _client.close();
}
