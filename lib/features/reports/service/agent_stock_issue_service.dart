import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart';
import '../models/agent_stock_issue_models.dart';

class AgentStockIssueService {
  final http.Client _client = http.Client();

  /// Fetch agent stock issue details.
  ///
  /// Always sends a POST request with:
  /// PRODUCT_ID, AGENT_ID, FROM_DATE, TO_DATE
  Future<AgentStockIssueListResponse> fetchIssues({
    required int productId,
    required int agentId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final uri = ApiEndpoints.agentStockIssueDetails;

    // Body data
    final body = {
      "PRODUCT_ID": productId.toString(),
      "AGENT_ID": agentId.toString(),
      "FROM_DATE": _fmtYMD(fromDate),
      "TO_DATE": _fmtYMD(toDate),
    };

    try {
      final response = await _client
          .post(
        uri,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: body,
      )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      final decoded = jsonDecode(response.body);
      return AgentStockIssueListResponse.fromJson(decoded);
    } catch (e) {
      throw Exception('Failed to fetch agent stock issue details: $e');
    }
  }

  void dispose() => _client.close();

  // Date format yyyy-MM-dd
  String _fmtYMD(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
