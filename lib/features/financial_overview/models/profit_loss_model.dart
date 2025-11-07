// lib/features/reports/models/profit_loss_model.dart
import 'dart:convert';

class ProfitLossResponse {
  final List<ProfitLossRow> result;

  ProfitLossResponse({required this.result});

  factory ProfitLossResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List<dynamic>? ?? [])
        .map((e) => ProfitLossRow.fromJson(e as Map<String, dynamic>))
        .toList();
    return ProfitLossResponse(result: list);
  }

  Map<String, dynamic> toJson() => {
    'Result': result.map((e) => e.toJson()).toList(),
  };

  // Convenience helpers
  factory ProfitLossResponse.fromRawJson(String str) =>
      ProfitLossResponse.fromJson(jsonDecode(str) as Map<String, dynamic>);
  String toRawJson() => jsonEncode(toJson());
}

class ProfitLossRow {
  final String description; // e.g. "AGENT RECEIVABLE", "NET PROFIT"
  final double amount;      // parsed from "Amount" -> double (handles "", "0.00", 54255)

  const ProfitLossRow({
    required this.description,
    required this.amount,
  });

  factory ProfitLossRow.fromJson(Map<String, dynamic> json) => ProfitLossRow(
    description: (json['DESCRIPTION'] ?? '').toString(),
    amount: _toDouble(json['Amount']),
  );

  Map<String, dynamic> toJson() => {
    'DESCRIPTION': description,
    'Amount': amount,
  };

  ProfitLossRow copyWith({
    String? description,
    double? amount,
  }) =>
      ProfitLossRow(
        description: description ?? this.description,
        amount: amount ?? this.amount,
      );

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return 0.0;
    return double.tryParse(s) ?? 0.0;
  }
}
