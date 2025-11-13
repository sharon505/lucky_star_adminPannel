import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../../../core/network/api_endpoints.dart';
import '../models/get_team_model.dart';

class GetTeamService {
  final http.Client _client;
  final Duration timeout;

  GetTeamService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  /// Fetch team list for a given location.
  ///
  /// POST body:
  ///   locationid: <int>
  ///
  /// Expected JSON:
  /// {
  ///   "Result": [
  ///     { "TeamName": "JEBEL ALI", "TeamID": 1 },
  ///     { "TeamName": "KISHOR",    "TeamID": 2 }
  ///   ]
  /// }
  Future<List<GetTeam>> fetch({required int locationId}) async {
    final reqId = _newReqId();
    final sw = Stopwatch()..start();

    final uri     = ApiEndpoints.getTeam;
    final headers = ApiEndpoints.formHeaders;

    final body = {
      'locationid': locationId.toString(),
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
      _log(reqId,
          'HTTP error after ${sw.elapsedMilliseconds}ms -> $e',
          isError: true);
      rethrow;
    }

    _log(reqId, 'Status: ${res.statusCode} in ${sw.elapsedMilliseconds}ms');
    _log(reqId, 'Raw: ${_truncate(res.body)}');

    if (res.statusCode != 200) {
      final msg =
          'GetTeam failed (${res.statusCode}): ${_truncate(res.body, 600)}';
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

    final teams = list
        .map((e) => GetTeam.fromJson(e as Map<String, dynamic>))
        .toList();

    _log(reqId, 'Parsed -> ${teams.length} team(s)');
    return teams;
  }

  void dispose() {
    _client.close();
  }

  // --- Helpers ---------------------------------------------------------------

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
    return 'GT${ms.toRadixString(36).toUpperCase()}';
  }
}
