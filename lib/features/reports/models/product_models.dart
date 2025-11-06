// lib/features/reports/models/product_models.dart
import 'dart:convert';

class ProductListResponse {
  final List<ProductItem> result;

  const ProductListResponse({required this.result});

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List<dynamic>? ?? [])
        .map((e) => ProductItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return ProductListResponse(result: list);
  }

  Map<String, dynamic> toJson() => {
    'Result': result.map((e) => e.toJson()).toList(),
  };

  ProductListResponse copyWith({List<ProductItem>? result}) =>
      ProductListResponse(result: result ?? this.result);

  // Convenience helpers
  static ProductListResponse fromJsonString(String source) =>
      ProductListResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);
  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() => 'ProductListResponse(result: $result)';
}

class ProductItem {
  final int productId;
  final String productName;

  const ProductItem({
    required this.productId,
    required this.productName,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
    productId: _asInt(json['ProductID']),
    productName: (json['ProductName'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'ProductID': productId,
    'ProductName': productName,
  };

  ProductItem copyWith({
    int? productId,
    String? productName,
  }) =>
      ProductItem(
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
      );

  @override
  String toString() =>
      'ProductItem(productId: $productId, productName: $productName)';
}

/// Safe int parser supporting int/double/string
int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.round();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}
