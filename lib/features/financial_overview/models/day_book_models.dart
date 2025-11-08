// lib/features/reports/models/day_book_models.dart
import 'package:intl/intl.dart';

/// One day-book (journal) row
class DayBookItem {
  final DateTime tranDate;
  final String description;
  final double debit;
  final double credit;

  DayBookItem({
    required this.tranDate,
    required this.description,
    required this.debit,
    required this.credit,
  });

  /// Parse from backend JSON map
  factory DayBookItem.fromJson(Map<String, dynamic> json) {
    return DayBookItem(
      tranDate: _parseDate(json['TRAN_DATE']),
      description: (json['Description'] ?? '').toString().trim(),
      debit: _parseDouble(json['DEBIT']),
      credit: _parseDouble(json['CREDIT']),
    );
  }

  Map<String, dynamic> toJson() => {
    'TRAN_DATE': DateFormat('dd/MM/yyyy').format(tranDate),
    'Description': description,
    'DEBIT': debit,
    'CREDIT': credit,
  };

  /// Helpers
  static DateTime _parseDate(dynamic v) {
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    // expecting dd/MM/yyyy
    return DateFormat('dd/MM/yyyy').parse(s);
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    final s = v.toString().trim();
    if (s.isEmpty) return 0.0;
    return double.tryParse(s) ?? 0.0;
  }

  /// Bulk parse: expects {"Result": [ ... ]}
  static List<DayBookItem> listFromApi(Map<String, dynamic> root) {
    final list = (root['Result'] as List? ?? []);
    return list.map((e) => DayBookItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}

/// Optional aggregations
class DayBookSummary {
  final double totalDebit;
  final double totalCredit;

  DayBookSummary({required this.totalDebit, required this.totalCredit});

  factory DayBookSummary.fromItems(List<DayBookItem> items) {
    double d = 0, c = 0;
    for (final it in items) {
      d += it.debit;
      c += it.credit;
    }
    return DayBookSummary(totalDebit: d, totalCredit: c);
  }
}
