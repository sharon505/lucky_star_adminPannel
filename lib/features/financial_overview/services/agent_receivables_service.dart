// lib/features/reports/services/agent_receivables_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart';
import '../models/agent_receivables_model.dart';

class AgentReceivablesService {
  final http.Client _client;
  final Duration timeout;

  AgentReceivablesService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  /// POST: Agent receivable for a given agent + product.
  /// Body:
  ///   agentId:  1
  ///   productId:1
  Future<AgentReceivablesResponse> fetch({
    required int agentId,
    required int productId,
  }) async {
    final res = await _client
        .post(
      ApiEndpoints.agentReceivables, // static final Uri agentReceivables = _u('AgentReceivable');
      headers: ApiEndpoints.formHeaders,
      body: {
        'agentId': agentId.toString(),
        'productId': productId.toString(),
      },
    )
        .timeout(timeout);

    if (res.statusCode != 200) {
      throw Exception('AgentReceivable failed (${res.statusCode}): ${res.body}');
    }

    final Map<String, dynamic> decoded =
    jsonDecode(res.body) as Map<String, dynamic>;
    return AgentReceivablesResponse.fromMap(decoded);
  }

  void dispose() {
    _client.close();
  }
}
