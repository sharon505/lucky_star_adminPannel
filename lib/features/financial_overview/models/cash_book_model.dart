// lib/features/reports/models/cash_book_model.dart

import 'dart:convert';

class CashBookResponse {
  final List<CashBookRow> result;

  CashBookResponse({required this.result});

  factory CashBookResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List<dynamic>? ?? [])
        .map((e) => CashBookRow.fromJson(e as Map<String, dynamic>))
        .toList();
    return CashBookResponse(result: list);
  }

  Map<String, dynamic> toJson() => {
    'Result': result.map((e) => e.toJson()).toList(),
  };

  /// Parse from raw json string
  factory CashBookResponse.fromRawJson(String str) =>
      CashBookResponse.fromJson(jsonDecode(str) as Map<String, dynamic>);

  /// Encode to raw json string
  String toRawJson() => jsonEncode(toJson());
}

class CashBookRow {
  final String descr;   // "OPENING BAL", "CLOSING BAL", etc.
  final double debit;   // 0.00
  final double credit;  // 0.00

  const CashBookRow({
    required this.descr,
    required this.debit,
    required this.credit,
  });

  factory CashBookRow.fromJson(Map<String, dynamic> json) => CashBookRow(
    descr: (json['DESCR'] ?? '').toString(),
    debit: _toDouble(json['DEBIT']),
    credit: _toDouble(json['CREDIT']),
  );

  Map<String, dynamic> toJson() => {
    'DESCR': descr,
    'DEBIT': debit,
    'CREDIT': credit,
  };

  CashBookRow copyWith({
    String? descr,
    double? debit,
    double? credit,
  }) {
    return CashBookRow(
      descr: descr ?? this.descr,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return 0.0;
    return double.tryParse(s) ?? 0.0;
  }
}
