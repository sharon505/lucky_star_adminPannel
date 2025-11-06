import 'dart:convert';

class StockSummaryResponse {
  final List<StockSummaryItem> result;

  const StockSummaryResponse({required this.result});

  factory StockSummaryResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List<dynamic>? ?? [])
        .map((e) => StockSummaryItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return StockSummaryResponse(result: list);
  }

  Map<String, dynamic> toJson() => {
    'Result': result.map((e) => e.toJson()).toList(),
  };

  StockSummaryResponse copyWith({List<StockSummaryItem>? result}) =>
      StockSummaryResponse(result: result ?? this.result);

  /// Helpers if you’re parsing from a raw string
  static StockSummaryResponse fromJsonString(String source) =>
      StockSummaryResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);
  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() => 'StockSummaryResponse(result: $result)';
}

class StockSummaryItem {
  final String descriptions; // "OPENING STOCK", ...
  final int stock;           // 37310
  final int balanceStock;    // 37310

  const StockSummaryItem({
    required this.descriptions,
    required this.stock,
    required this.balanceStock,
  });

  factory StockSummaryItem.fromJson(Map<String, dynamic> json) => StockSummaryItem(
    descriptions: (json['DESCRIPTIONS'] ?? '').toString(),
    stock: _asInt(json['STOCK']),
    balanceStock: _asInt(json['BALANCE_STOCK']),
  );

  Map<String, dynamic> toJson() => {
    'DESCRIPTIONS': descriptions,
    'STOCK': stock,
    'BALANCE_STOCK': balanceStock,
  };

  StockSummaryItem copyWith({
    String? descriptions,
    int? stock,
    int? balanceStock,
  }) =>
      StockSummaryItem(
        descriptions: descriptions ?? this.descriptions,
        stock: stock ?? this.stock,
        balanceStock: balanceStock ?? this.balanceStock,
      );

  @override
  String toString() =>
      'StockSummaryItem(descriptions: $descriptions, stock: $stock, balanceStock: $balanceStock)';
}

/// Safe int parsing supporting int/double/string
int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.round();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}
