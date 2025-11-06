// lib/features/reports/models/agent_stock_summary_models.dart

import 'dart:convert';

/// Top-level response: { "Result": [ ... ] }
class AgentStockSummaryResponse {
  final List<AgentStockSummaryItem> result;

  const AgentStockSummaryResponse({required this.result});

  factory AgentStockSummaryResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List<dynamic>? ?? [])
        .map((e) => AgentStockSummaryItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return AgentStockSummaryResponse(result: list);
  }

  Map<String, dynamic> toJson() => {
    'Result': result.map((e) => e.toJson()).toList(),
  };

  /// Convenience
  static AgentStockSummaryResponse fromJsonStr(String source) =>
      AgentStockSummaryResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);
  String toJsonStr() => jsonEncode(toJson());
}

/// A single row in Result
class AgentStockSummaryItem {
  final int sn;
  final String productName;
  final String name;
  final double issued;
  final double sale;
  final double balanceStock;

  const AgentStockSummaryItem({
    required this.sn,
    required this.productName,
    required this.name,
    required this.issued,
    required this.sale,
    required this.balanceStock,
  });

  factory AgentStockSummaryItem.fromJson(Map<String, dynamic> json) {
    return AgentStockSummaryItem(
      sn: _asInt(json['SN']),
      productName: (json['ProductName'] ?? '').toString(),
      name: (json['Name'] ?? '').toString(),
      issued: _asDouble(json['ISSUED']),
      sale: _asDouble(json['SALE']),
      balanceStock: _asDouble(json['BALANCE_STOCK']),
    );
  }

  Map<String, dynamic> toJson() => {
    'SN': sn,
    'ProductName': productName,
    'Name': name,
    'ISSUED': issued,
    'SALE': sale,
    'BALANCE_STOCK': balanceStock,
  };

  AgentStockSummaryItem copyWith({
    int? sn,
    String? productName,
    String? name,
    double? issued,
    double? sale,
    double? balanceStock,
  }) {
    return AgentStockSummaryItem(
      sn: sn ?? this.sn,
      productName: productName ?? this.productName,
      name: name ?? this.name,
      issued: issued ?? this.issued,
      sale: sale ?? this.sale,
      balanceStock: balanceStock ?? this.balanceStock,
    );
  }

  @override
  String toString() {
    return 'AgentStockSummaryItem(sn: $sn, productName: $productName, '
        'name: $name, issued: $issued, sale: $sale, balanceStock: $balanceStock)';
  }

  @override
  bool operator ==(Object other) {
    return other is AgentStockSummaryItem &&
        other.sn == sn &&
        other.productName == productName &&
        other.name == name &&
        other.issued == issued &&
        other.sale == sale &&
        other.balanceStock == balanceStock;
  }

  @override
  int get hashCode =>
      sn.hashCode ^
      productName.hashCode ^
      name.hashCode ^
      issued.hashCode ^
      sale.hashCode ^
      balanceStock.hashCode;
}

/// ---- helpers ----
int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}
