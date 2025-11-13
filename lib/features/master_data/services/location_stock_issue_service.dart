import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../../../core/network/api_endpoints.dart';
import '../models/location_stock_issue_model.dart';

class LocationStockIssueService {
  final http.Client _client;
  final Duration timeout;

  LocationStockIssueService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  /// Submit a Location Stock Issue.
  ///
  /// POST body:
  ///   issuedate:      2025-11-13 (yyyy-MM-dd)
  ///   Product:        1
  ///   current_stock:  (int)
  ///   IssueQuantity:  (int)
  ///   locationid:     (int)
  ///   user:           (String)
  ///
  /// Expected JSON:
  /// {
  ///   "Result": [
  ///     { "Column1": 100 }
  ///   ]
  /// }
  Future<LocationStockIssueModel> submit({
    required DateTime issueDate,
    required int productId,
    required int currentStock,
    required int issueQuantity,
    required int locationId,
    required String user,
  }) async {
    final reqId = _newReqId();
    final sw = Stopwatch()..start();

    final uri     = ApiEndpoints.locationStockIssue;
    final headers = ApiEndpoints.formHeaders;

    final body = {
      'issuedate': _fmtDate(issueDate),     // e.g. 2025-11-13
      'Product': productId.toString(),
      'current_stock': currentStock.toString(),
      'IssueQuantity': issueQuantity.toString(),
      'locationid': locationId.toString(),
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
      _log(reqId,
          'HTTP error after ${sw.elapsedMilliseconds}ms -> $e',
          isError: true);
      rethrow;
    }

    _log(reqId, 'Status: ${res.statusCode} in ${sw.elapsedMilliseconds}ms');
    _log(reqId, 'Raw: ${_truncate(res.body)}');

    if (res.statusCode != 200) {
      final msg =
          'LocationStockIssue failed (${res.statusCode}): ${_truncate(res.body, 600)}';
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
      _log(reqId, 'Parsed -> empty Result list, returning Column1 = 0');
      return LocationStockIssueModel(column1: 0);
    }

    final first = LocationStockIssueModel.fromJson(
      resultList.first as Map<String, dynamic>,
    );

    _log(reqId, 'Parsed -> Column1: ${first.column1}');
    return first;
  }

  void dispose() {
    _client.close();
  }

  // --- Helpers ----------------------------------------------------------------

  String _fmtDate(DateTime d) {
    final y   = d.year.toString().padLeft(4, '0');
    final m   = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

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
    return 'LSI${ms.toRadixString(36).toUpperCase()}';
  }
}
