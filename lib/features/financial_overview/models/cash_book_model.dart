// lib/features/reports/models/day_book_model.dart
import 'dart:convert';

/// Top-level response: { "Result": [ ...entries ] }
class DayBookResponse {
  final List<DayBookEntry> items;

  DayBookResponse({required this.items});

  factory DayBookResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List? ?? [])
        .map((e) => DayBookEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return DayBookResponse(items: list);
  }

  Map<String, dynamic> toJson() => {
    'Result': items.map((e) => e.toJson()).toList(),
  };

  /// Helpers if you receive a raw string body.
  factory DayBookResponse.fromJsonStr(String source) =>
      DayBookResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toJsonStr() => jsonEncode(toJson());
}

/// A single row in the Result list.
class DayBookEntry {
  final String particulars;
  final String voucherNo;
  final double debit;
  final double credit;

  DayBookEntry({
    required this.particulars,
    required this.voucherNo,
    required this.debit,
    required this.credit,
  });

  factory DayBookEntry.fromJson(Map<String, dynamic> json) {
    return DayBookEntry(
      particulars: (json['PARTICULARS'] ?? '').toString(),
      voucherNo: (json['VOUCHER_NO'] ?? '').toString(),
      debit: _asDouble(json['DEBIT']),
      credit: _asDouble(json['CREDIT']),
    );
  }

  Map<String, dynamic> toJson() => {
    'PARTICULARS': particulars,
    'VOUCHER_NO': voucherNo,
    'DEBIT': debit,
    'CREDIT': credit,
  };

  DayBookEntry copyWith({
    String? particulars,
    String? voucherNo,
    double? debit,
    double? credit,
  }) {
    return DayBookEntry(
      particulars: particulars ?? this.particulars,
      voucherNo: voucherNo ?? this.voucherNo,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
    );
  }

  @override
  String toString() =>
      'DayBookEntry(particulars: $particulars, voucherNo: $voucherNo, debit: $debit, credit: $credit)';

  static double _asDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return 0.0;
    return double.tryParse(s) ?? 0.0;
  }
}
