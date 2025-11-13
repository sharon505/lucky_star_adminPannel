import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../../../core/network/api_endpoints.dart';
import '../models/get_location_model.dart'; // where GetLocation is defined

class LocationService {
  final http.Client _client;
  final Duration timeout;

  LocationService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  /// Fetch all locations from GetLocation endpoint.
  ///
  /// Expected JSON:
  /// {
  ///   "Result": [
  ///     { "LocationID": 0, "LocationName": "ALL" },
  ///     ...
  ///   ]
  /// }
  Future<List<GetLocation>> fetchAll() async {
    final reqId = _newReqId();
    final sw = Stopwatch()..start();

    final uri     = ApiEndpoints.geLocation;
    final headers = ApiEndpoints.formHeaders;

    _log(reqId, 'POST ${uri.toString()}');
    _log(reqId, 'Headers: ${_safeHeaders(headers)}');

    http.Response res;
    try {
      // If your API expects GET instead of POST, change to _client.get(...)
      res = await _client
          .post(uri, headers: headers)
          .timeout(timeout);
    } catch (e) {
      _log(reqId, 'HTTP error after ${sw.elapsedMilliseconds}ms -> $e',
          isError: true);
      rethrow;
    }

    _log(reqId, 'Status: ${res.statusCode} in ${sw.elapsedMilliseconds}ms');
    _log(reqId, 'Raw: ${_truncate(res.body)}');

    if (res.statusCode != 200) {
      final msg =
          'GetLocation failed (${res.statusCode}): ${_truncate(res.body, 600)}';
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

    final locations = resultList
        .map((e) => GetLocation.fromJson(e as Map<String, dynamic>))
        .toList();

    _log(reqId, 'Parsed -> locations: ${locations.length}');
    if (locations.isNotEmpty) {
      _log(reqId,
          'First location -> id: ${locations.first.locationId}, name: ${locations.first.locationName}');
    }

    return locations;
  }

  void dispose() {
    _client.close();
  }

  // --- Helpers ----------------------------------------------------------------

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

  /// Avoid leaking auth tokens etc.
  Map<String, String> _safeHeaders(Map<String, String> headers) {
    final masked = Map<String, String>.from(headers);
    if (masked.containsKey('Authorization')) {
      masked['Authorization'] = '***';
    }
    return masked;
  }

  /// Truncates long strings so logs stay tidy.
  String _truncate(String s, [int max = 400]) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}…(${s.length - max} more)';
  }

  /// Generates a short per-request id for log grouping.
  String _newReqId() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    return 'LOC${ms.toRadixString(36).toUpperCase()}';
  }
}
