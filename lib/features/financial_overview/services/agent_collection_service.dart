// lib/features/financial_overview/services/agent_collection_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../../../core/network/api_endpoints.dart';
import '../models/agent_collection_model.dart';

class AgentCollectionService {
  final http.Client _client;
  final Duration timeout;

  AgentCollectionService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  /// Post an Agent Collection entry.
  ///
  /// API body keys are lower_snake to match your current endpoint:
  /// date, productId, agentId, amount, user
  Future<AgentCollectionResponse> submit({
    required DateTime date,
    required int productId,
    required int agentId,
    required num amount,
    required String user,
  }) async {
    final reqId = _newReqId();
    final sw = Stopwatch()..start();

    final uri = ApiEndpoints.agentCollection;
    final headers = ApiEndpoints.formHeaders;
    final body = {
      'date': _fmtDate(date), // e.g., 2025-11-12
      'productId': productId.toString(),
      'agentId': agentId.toString(),
      'amount': amount.toString(),
      'user': user,
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
      final msg = 'AgentCollection failed (${res.statusCode}): ${_truncate(res.body, 600)}';
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

    final parsed = AgentCollectionResponse.fromJson(decoded);

    // Convenience: log first row if present
    if (parsed.result.isNotEmpty) {
      final first = parsed.result.first;
      _log(reqId, 'Parsed -> statusId: ${first.statusId}, msg: ${first.msg}');
    } else {
      _log(reqId, 'Parsed -> empty result list');
    }

    return parsed;
  }

  /// Convenience helper for “today” (system local date).
  Future<AgentCollectionResponse> submitToday({
    required int productId,
    required int agentId,
    required num amount,
    required String user,
  }) {
    final today = DateTime.now();
    return submit(
      date: today,
      productId: productId,
      agentId: agentId,
      amount: amount,
      user: user,
    );
    // NOTE: Date is local; adjust if backend expects a specific TZ/UTC.
  }

  void dispose() {
    _client.close();
  }

  // --- Helpers ----------------------------------------------------------------

  String _fmtDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  /// Only prints in debug mode.
  void _log(String reqId, String msg, {bool isError = false}) {
    if (!kDebugMode) return;
    final line = '[$reqId] $msg';
    if (isError) {
      debugPrint('❌ $line');
    } else {
      debugPrint('🔎 $line');
    }
  }

  /// Avoid leaking auth tokens etc. Adjust to mask sensitive headers if needed.
  Map<String, String> _safeHeaders(Map<String, String> headers) {
    final masked = Map<String, String>.from(headers);
    // Example: if you use 'Authorization', mask it.
    if (masked.containsKey('Authorization')) masked['Authorization'] = '***';
    return masked;
    // Add more masks as needed.
  }

  /// Truncates long strings so logs stay tidy.
  String _truncate(String s, [int max = 400]) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}…(${s.length - max} more)';
  }

  /// Generates a short per-request id for log grouping.
  String _newReqId() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    return 'AC${ms.toRadixString(36).toUpperCase()}';
  }
}
