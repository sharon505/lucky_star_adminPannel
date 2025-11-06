import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart'; // has ApiEndpoints.stockReport
import '../models/stock_summary_models.dart';     // your model from previous step

class StockReportService {
  final http.Client _client;
  final Duration timeout;

  StockReportService({
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  /// POST: DATE=YYYY-MM-DD, PRODUCT_ID=<id>
  Future<StockSummaryResponse> fetchStockSummary({
    required DateTime date,
    required int productId,
    Map<String, String>? extraHeaders, // if you need auth etc.
  }) async {
    final body = {
      'DATE': _fmtDate(date),           // e.g., 2025-11-06
      'PRODUCT_ID': productId.toString()
    };

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      if (extraHeaders != null) ...extraHeaders,
    };

    final res = await _client
        .post(ApiEndpoints.stockReport, headers: headers, body: body)
        .timeout(timeout);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return StockSummaryResponse.fromJson(decoded);
  }

  static String _fmtDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  void dispose() => _client.close();
}
