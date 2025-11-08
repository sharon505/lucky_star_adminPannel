// lib/features/financial_overview/services/dashboard_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart';
import '../models/stock_summary_model.dart'; // StockSummaryResponse

class DashboardService {
  final http.Client _client;
  final Duration timeout;

  DashboardService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  /// Calls GET_DASHBOARD with no body.
  Future<StockSummaryResponse> fetch() async {
    final res = await _client
        .post(
      ApiEndpoints.dashboard,           // static final Uri dashboard = _u('GET_DASHBOARD');
      headers: ApiEndpoints.formHeaders,
      // body: null  // body omitted – request has no body
    )
        .timeout(timeout);

    if (res.statusCode != 200) {
      throw Exception('GET_DASHBOARD failed (${res.statusCode}): ${res.body}');
    }

    final Map<String, dynamic> decoded =
    jsonDecode(res.body) as Map<String, dynamic>;
    return StockSummaryResponse.fromJson(decoded);
  }

  void dispose() {
    _client.close();
  }
}
