// lib/features/reports/services/profit_loss_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart';
import '../models/profit_loss_model.dart';

class ProfitLossService {
  final http.Client _client;
  final Duration timeout;

  ProfitLossService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  /// Fetch P&L for a specific date (expects yyyy-MM-dd).
  Future<ProfitLossResponse> fetchByDateStr({required String date}) async {
    final res = await _client
        .post(
      ApiEndpoints.profitAndLossStatement,
      headers: ApiEndpoints.formHeaders,
      body: {
        'DATE': date, // e.g., 2025-11-06
      },
    )
        .timeout(timeout);

    if (res.statusCode != 200) {
      throw Exception('REPORT_PANDL failed (${res.statusCode}): ${res.body}');
    }

    final Map<String, dynamic> decoded =
    jsonDecode(res.body) as Map<String, dynamic>;
    return ProfitLossResponse.fromJson(decoded);
  }

  /// Convenience overload: accepts DateTime and formats to yyyy-MM-dd
  Future<ProfitLossResponse> fetchByDate({required DateTime date}) {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final formatted = '$yyyy-$mm-$dd';
    return fetchByDateStr(date: formatted);
  }

  void dispose() => _client.close();
}
