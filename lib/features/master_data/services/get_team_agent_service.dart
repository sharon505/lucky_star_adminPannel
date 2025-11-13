import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../../../core/network/api_endpoints.dart';
import '../models/agent_model.dart';

class GetTeamAgentService {
  final http.Client _client;
  final Duration timeout;

  GetTeamAgentService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  /// Fetch agents for a given Team.
  ///
  /// POST body:
  ///   TeamId: <int>
  ///
  /// Expected JSON:
  /// {
  ///   "Result": [
  ///     { "Name": "SHYKALA", "DisID": 4, "Code": "SHYKALA1" },
  ///     ...
  ///   ]
  /// }
  Future<List<AgentModel>> fetch({required int teamId}) async {
    final reqId = _newReqId();
    final sw = Stopwatch()..start();

    final uri     = ApiEndpoints.getTeamAgent;
    final headers = ApiEndpoints.formHeaders;

    final body = {
      'TeamId': teamId.toString(),
    };

    _log(reqId, 'POST ${uri.toString()}');
    _log(reqId, 'Headers: ${_safeHeaders(headers)}');
    _log(reqId, 'Body: ${jsonEncode(body)}');

    http.Response res;
    try {
      res = await _client
          .post(uri, headers: headers, body: body)
          .timeout(timeout);
    } catch (e) {
      _log(
        reqId,
        'HTTP error after ${sw.elapsedMilliseconds}ms -> $e',
        isError: true,
      );
      rethrow;
    }

    _log(reqId, 'Status: ${res.statusCode} in ${sw.elapsedMilliseconds}ms');
    _log(reqId, 'Raw: ${_truncate(res.body)}');

    if (res.statusCode != 200) {
      final msg =
          'GetTeamAgent failed (${res.statusCode}): ${_truncate(res.body, 600)}';
      _log(reqId, msg, isError: true);
      throw Exception(msg);
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      _log(reqId, 'JSON decode error: $e', isError: true);
      rethrow;
    }

    final List<dynamic> list =
        (decoded['Result'] as List<dynamic>?) ?? const [];

    final agents = list
        .map((e) => AgentModel.fromJson(e as Map<String, dynamic>))
        .toList();

    _log(reqId, 'Parsed -> ${agents.length} agent(s)');
    return agents;
  }

  void dispose() {
    _client.close();
  }

  // --- Helpers --------------------------------------------------------------

  void _log(String reqId, String msg, {bool isError = false}) {
    if (!kDebugMode) return;
    final line = '[$reqId] $msg';
    if (isError) {
      debugPrint('❌ $line');
    } else {
      debugPrint('🔎 $line');
    }
  }

  Map<String, String> _safeHeaders(Map<String, String> headers) {
    final masked = Map<String, String>.from(headers);
    if (masked.containsKey('Authorization')) {
      masked['Authorization'] = '***';
    }
    return masked;
  }

  String _truncate(String s, [int max = 400]) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}…(${s.length - max} more)';
  }

  String _newReqId() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    return 'TA${ms.toRadixString(36).toUpperCase()}';
  }
}
