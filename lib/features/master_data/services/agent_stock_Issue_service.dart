import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../../../core/network/api_endpoints.dart';
import '../models/agent_stock_Issue_response_model.dart';

class AgentStockIssueService {
  final http.Client _client;
  final Duration timeout;

  AgentStockIssueService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  /// Create Agent Stock Issue
  ///
  /// POST body:
  ///   issuedate:      yyyy-MM-dd (or your server format)
  ///   current_stock:  <int / double>
  ///   teamcode:       <String>
  ///   agent:          <String>  e.g. "JEBEL ALI 1(JEBEL ALI)"
  ///   Product:        <int>     (ProductId)
  ///   IssueQuantity:  <int>
  ///   user:           <String>  (logged in user code / id)
  ///   locationid:     <int>
  ///
  /// Expected JSON:
  /// {
  ///   "Result": [
  ///     { "Column1": 100 }
  ///   ]
  /// }
  ///
  /// Returns: AgentStockIssueResponse
  Future<AgentStockIssueResponse> issueStock({
    required String issueDate,
    required num currentStock,
    required String teamCode,   // "JEBEL ALI"
    required String agent,      // "JEBEL ALI 1"
    required String product,    // "LUCKY STAR CARD"
    required int issueQuantity,
    required String user,       // "admin"
    required int locationId,    // 1
  }) async {
    final reqId = _newReqId();
    final sw = Stopwatch()..start();

    final uri     = ApiEndpoints.agentStockIssue;
    final headers = ApiEndpoints.formHeaders;


    final body = {
      'issuedate'    : issueDate,                 // "2025-11-14"
      'current_stock': currentStock.toString(),   // "28535"
      'teamcode'     : teamCode,                  // "JEBEL ALI"
      'agent'        : agent,                     // "JEBEL ALI 1"
      'Product'      : product,                   // "LUCKY STAR CARD"
      'IssueQuantity': issueQuantity.toString(),  // "10"
      'user'         : user,                      // "admin"
      'locationid'   : locationId.toString(),     // "1"
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
          'AgentStockIssue failed (${res.statusCode}): ${_truncate(res.body, 600)}';
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

    final response = AgentStockIssueResponse.fromJson(decoded);
    _log(reqId, 'Parsed -> ${response.result.length} row(s)');
    return response;
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
    return 'ASI${ms.toRadixString(36).toUpperCase()}';
  }
}
