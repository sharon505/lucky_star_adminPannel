// lib/features/reports/services/cash_book_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart';
import '../models/cash_book_model.dart';

class CashBookService {
  final http.Client _client;
  final Duration timeout;

  CashBookService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  Future<CashBookResponse> fetchCashBook({
    required String agentId,
  }) async {
    final res = await _client
        .post(
      ApiEndpoints.cashBook,
      headers: ApiEndpoints.formHeaders,
      body: {
        'Agentid': agentId,
      },
    )
        .timeout(timeout);

    if (res.statusCode != 200) {
      throw Exception(
        'CashBook failed (${res.statusCode}): ${res.body}',
      );
    }

    final Map<String, dynamic> decoded =
    jsonDecode(res.body) as Map<String, dynamic>;
    return CashBookResponse.fromJson(decoded);
  }

  void dispose() => _client.close();
}
