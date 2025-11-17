import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../../../core/network/api_endpoints.dart';
import '../models/agent_master_model.dart';

class AgentMasterService {
  final http.Client _client;
  final Duration timeout;

  AgentMasterService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  /// Create / Insert Agent Master
  ///
  /// POST body:
  ///   Name        : String
  ///   code        : String
  ///   Address     : String
  ///   Locationid  : int
  ///   Teamid      : int
  ///   Phone       : String
  ///   Email       : String
  ///   User        : String
  ///
  /// Expected JSON:
  /// {
  ///   "Result": [
  ///     { "Column1": 100 }
  ///   ]
  /// }
  ///
  Future<AgentMasterResponse> createAgent({
    required String name,
    required String code,
    required String address,
    required int locationId,
    required int teamId,
    required String phone,
    required String email,
    required String user,
  }) async {
    final reqId = _newReqId();
    final sw = Stopwatch()..start();

    final uri = ApiEndpoints.agentMaster;      // Insert_Agent
    final headers = ApiEndpoints.formHeaders;

    final body = <String, String>{
      'Name'       : name,
      'code'       : code,
      'Address'    : address,
      'Locationid' : locationId.toString(),
      'Teamid'     : teamId.toString(),
      'Phone'      : phone,
      'Email'      : email,
      'User'       : user,
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
      _log(reqId, 'HTTP error after ${sw.elapsedMilliseconds}ms -> $e', isError: true);
      rethrow;
    }

    _log(reqId, 'Status: ${res.statusCode} in ${sw.elapsedMilliseconds}ms');
    _log(reqId, 'Raw: ${_truncate(res.body)}');

    if (res.statusCode != 200) {
      final msg = 'AgentMaster failed (${res.statusCode}): ${_truncate(res.body, 600)}';
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

    final response = AgentMasterResponse.fromJson(decoded);
    _log(reqId, 'Parsed -> ${response.result.length} row(s)');

    return response;
  }

  void dispose() {
    _client.close();
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  void _log(String reqId, String msg, {bool isError = false}) {
    if (!kDebugMode) return;
    final line = '[$reqId] $msg';
    isError ? debugPrint('❌ $line') : debugPrint('🔎 $line');
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
    return 'AM${ms.toRadixString(36).toUpperCase()}';
  }
}
