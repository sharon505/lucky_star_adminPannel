// lib/features/reports/services/cash_collection_by_agent_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/cash_received_by_agent_models.dart';
import '../../../core/network/api_endpoints.dart';

class CashCollectionByAgentService {
  final http.Client _client;
  final Uri endpoint;
  final Map<String, String> _baseHeaders;

  CashCollectionByAgentService({
    http.Client? client,
    Uri? endpoint,
    Map<String, String>? headers,
  })  : _client = client ?? http.Client(),
        endpoint = endpoint ?? ApiEndpoints.cashCollectionByAgent,
        _baseHeaders = headers ??
            const {
              // Use form-encoded unless your backend requires JSON
              'Content-Type': 'application/x-www-form-urlencoded',
            };

  // ---- Request date format: yyyy-MM-dd ----
  String _two(int n) => n < 10 ? '0$n' : '$n';
  String _fmt(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  /// Fetch cash collections by agent
  ///
  /// POST body:
  /// - FROM_DATE : yyyy-MM-dd
  /// - TO_DATE   : yyyy-MM-dd
  /// - AGENT_ID  : int (0 = ALL, if your API supports)
  /// - PRODUCT_ID: int
  Future<List<CashReceivedItem>> fetch({
    required DateTime fromDate,
    required DateTime toDate,
    required int agentId,
    required int productId,
    Map<String, String>? extraHeaders,
  }) async {
    final headers = {..._baseHeaders, if (extraHeaders != null) ...extraHeaders};

    final body = {
      'FROM_DATE': _fmt(fromDate),
      'TO_DATE': _fmt(toDate),
      'AGENT_ID': agentId.toString(),
      'PRODUCT_ID': productId.toString(),
    };

    // -------- Debug logs (trim long bodies) --------
    // ignore: avoid_print
    print('🔵 POST  ${endpoint.toString()}');
    // ignore: avoid_print
    print('🔵 HEAD  $headers');
    // ignore: avoid_print
    print('🔵 BODY  $body');

    final resp = await _client
        .post(endpoint, headers: headers, body: body)
        .timeout(const Duration(seconds: 30));

    // ignore: avoid_print
    print('🟣 CODE  ${resp.statusCode}');
    // ignore: avoid_print
    print('🟣 RESP  ${resp.body.length > 1200 ? resp.body.substring(0, 1200) + '…' : resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('REPORT_CASH_RECEIVED failed: HTTP ${resp.statusCode}');
    }

    final decoded = json.decode(resp.body);

    // Accept { "Result": [...] } or bare [...]
    late final List raw;
    if (decoded is Map && decoded['Result'] is List) {
      raw = decoded['Result'] as List;
    } else if (decoded is List) {
      raw = decoded;
    } else {
      throw Exception('Unexpected JSON shape: ${decoded.runtimeType}');
    }

    return raw
        .whereType<Map<String, dynamic>>()
        .map(CashReceivedItem.fromJson)
        .toList();
  }

  void dispose() => _client.close();
}
