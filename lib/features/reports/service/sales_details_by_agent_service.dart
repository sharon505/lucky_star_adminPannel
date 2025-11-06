// lib/features/reports/services/sales_details_by_agent_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/agent_stock_sale_models.dart';
import '../../../core/network/api_endpoints.dart';

class SalesDetailsByAgentService {
  final http.Client _client;
  final Uri endpoint;
  final Map<String, String> _baseHeaders;

  SalesDetailsByAgentService({
    http.Client? client,
    Uri? endpoint,
    Map<String, String>? headers,
  })  : _client = client ?? http.Client(),
        endpoint = endpoint ?? ApiEndpoints.salesDetailsByAgent,
        _baseHeaders = headers ??
            const {
              // form-encoded unless your API expects JSON
              'Content-Type': 'application/x-www-form-urlencoded',
            };

  // ---- Format dates for request as yyyy-MM-dd ----
  String _two(int n) => n < 10 ? '0$n' : '$n';
  String _fmt(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  /// Fetch Sales Details by Agent
  ///
  /// Body:
  /// FROM_DATE: yyyy-MM-dd
  /// TO_DATE  : yyyy-MM-dd
  /// PRODUCT_ID: int
  /// AGENT_ID  : int  (0 = ALL if backend supports)
  Future<List<StockSaleItem>> fetch({
    required DateTime fromDate,
    required DateTime toDate,
    required int productId,
    required int agentId,
    Map<String, String>? extraHeaders,
  }) async {
    final headers = {..._baseHeaders, if (extraHeaders != null) ...extraHeaders};

    final body = {
      'FROM_DATE': _fmt(fromDate),
      'TO_DATE': _fmt(toDate),
      'PRODUCT_ID': productId.toString(),
      'AGENT_ID': agentId.toString(),
    };

    // ---------- Debug logs ----------
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
      throw Exception('REPORT_SALE_ENTRY failed: HTTP ${resp.statusCode}');
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
        .map((e) => StockSaleItem.fromJson(e))
        .toList();
  }

  void dispose() => _client.close();
}
