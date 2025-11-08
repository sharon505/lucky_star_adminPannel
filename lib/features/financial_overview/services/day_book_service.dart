// lib/features/reports/service/day_book_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart';
import '../models/day_book_models.dart';

class DayBookService {
  final http.Client _client;
  DayBookService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch Day Book entries for a specific [date].
  /// Backend expects DATE in yyyy-MM-dd (e.g., 2025-11-06).
  Future<List<DayBookItem>> fetch({required DateTime date}) async {
    final String dateStr =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final response = await _client.post(
      ApiEndpoints.dayBook,
      headers: ApiEndpoints.formHeaders,
      body: {
        'DATE': dateStr,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('DayBook failed: HTTP ${response.statusCode}');
    }

    final Map<String, dynamic> jsonBody = jsonDecode(response.body);
    final items = DayBookItem.listFromApi(jsonBody);
    return items;
  }

  void dispose() {
    _client.close();
  }
}
