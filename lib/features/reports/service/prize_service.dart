// lib/features/reports/services/prize_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart';
import '../models/prize_details_response.dart';

class PrizeService {
  PrizeService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Search prize details by SLNO.
  /// Adjust the param key ('SLNO' vs 'LUCKY_SLNO') if your API expects a different one.
  Future<PrizeDetailsResponse?> searchBySlno(String slno) async {
    if (slno.trim().isEmpty) return null;

    // Endpoint can be String or Uri depending on your ApiEndpoints version
    final uri = ApiEndpoints.ticketSearch is Uri
        ? (ApiEndpoints.ticketSearch as Uri)
        : Uri.parse(ApiEndpoints.ticketSearch as String);

    final headers = ApiEndpoints.formHeaders; // 'application/x-www-form-urlencoded'
    final body = {
      'SLNO': slno.trim(), // <- If your backend expects 'LUCKY_SLNO', change this key
    };

    final res = await _client.post(uri, headers: headers, body: body);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      // You can add logging here if needed
      return null;
    }

    final text = utf8.decode(res.bodyBytes);
    final Map<String, dynamic> json = jsonDecode(text);
    return PrizeDetailsResponse.fromJson(json);
  }
}
