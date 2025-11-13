import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../../../core/network/api_endpoints.dart';
import '../models/get_current_stock_model.dart';

class CurrentStockService {
  final http.Client _client;
  final Duration timeout;

  CurrentStockService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  Future<GetCurrentStockModel> fetch({
    required String product,
  }) async {
    final reqId = _newReqId();
    final sw = Stopwatch()..start();

    final uri = ApiEndpoints.getCurrentStock;
    final headers = ApiEndpoints.formHeaders;
    final body = {
      'Product': product,
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
          'GetCurrentStock failed (${res.statusCode}): ${_truncate(res.body, 600)}';
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

    final List<dynamic> resultList =
        (decoded['Result'] as List<dynamic>?) ?? const [];

    if (resultList.isEmpty) {
      _log(reqId, 'Parsed -> empty result list, returning 0');
      return GetCurrentStockModel(recptQnty: 0);
    }

    final first =
    GetCurrentStockModel.fromJson(resultList.first as Map<String, dynamic>);
    _log(reqId, 'Parsed -> recptQnty: ${first.recptQnty}');
    return first;
  }

  void dispose() {
    _client.close();
  }

  // --- Helpers ----------------------------------------------------------------

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
    return 'CS${ms.toRadixString(36).toUpperCase()}';
  }
}
