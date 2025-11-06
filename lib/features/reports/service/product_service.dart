// lib/features/reports/service/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_endpoints.dart';     // has ApiEndpoints.getProducts
import '../models/product_models.dart';                // ProductListResponse, ProductItem

class ProductService {
  final http.Client _client;
  final Duration timeout;

  ProductService({
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  /// Fetch products.
  /// By default uses GET. If your API requires POST with an empty body, set [usePost] = true.
  Future<ProductListResponse> fetchProducts({
    bool usePost = false,
    Map<String, String>? extraHeaders,
    bool asJson = false, // when posting, choose '{}' vs empty form body
  }) async {
    final uri = ApiEndpoints.getProducts;

    final headers = <String, String>{
      if (usePost && asJson) 'Content-Type': 'application/json',
      if (extraHeaders != null) ...extraHeaders,
    };

    late http.Response res;
    if (usePost) {
      // Empty body:
      // - JSON: '{}' (when asJson = true)
      // - Form: {} (when asJson = false)
      res = await _client
          .post(uri, headers: headers, body: asJson ? '{}' : const {})
          .timeout(timeout);
    } else {
      res = await _client.get(uri, headers: headers).timeout(timeout);
    }

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return ProductListResponse.fromJson(decoded);
  }

  void dispose() => _client.close();
}
