// lib/features/reports/models/cash_received_by_agent_models.dart
import 'dart:convert';

class CashReceivedResponse {
  final List<CashReceivedItem> result;

  CashReceivedResponse({required this.result});

  factory CashReceivedResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['Result'];
    final list = (raw is List ? raw : <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(CashReceivedItem.fromJson)
        .toList();
    return CashReceivedResponse(result: list);
  }

  /// Accepts either:
  /// 1) { "Result": [ ... ] }
  /// 2) [ ... ]
  static CashReceivedResponse flexible(String source) {
    final decoded = json.decode(source);
    if (decoded is Map<String, dynamic>) {
      return CashReceivedResponse.fromJson(decoded);
    } else if (decoded is List) {
      final list = decoded
          .whereType<Map<String, dynamic>>()
          .map(CashReceivedItem.fromJson)
          .toList();
      return CashReceivedResponse(result: list);
    } else {
      return CashReceivedResponse(result: const []);
    }
  }

  Map<String, dynamic> toJson() => {
    'Result': result.map((e) => e.toJson()).toList(),
  };
}

class CashReceivedItem {
  final int sn;
  final int distributorId;
  final DateTime date;        // from "DATE"
  final String productName;   // "ProductName"
  final String name;          // agent name ("Name")
  final double receivedAmt;   // "RECEIVED_AMT"

  CashReceivedItem({
    required this.sn,
    required this.distributorId,
    required this.date,
    required this.productName,
    required this.name,
    required this.receivedAmt,
  });

  factory CashReceivedItem.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic v) {
      final s = (v ?? '').toString().trim();
      if (s.isEmpty) return DateTime.now();

      // yyyy-MM-dd
      final iso = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      if (iso.hasMatch(s)) {
        final p = s.split('-');
        return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
      }

      // dd/MM/yyyy
      final slash = RegExp(r'^\d{2}/\d{2}/\d{4}$');
      if (slash.hasMatch(s)) {
        final p = s.split('/');
        return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      }

      // Best effort
      try {
        return DateTime.parse(s);
      } catch (_) {
        return DateTime.now();
      }
    }

    double _toD(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.trim()) ?? 0.0;
      return 0.0;
    }

    int _toI(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v.trim()) ?? 0;
      if (v is num) return v.toInt();
      return 0;
    }

    return CashReceivedItem(
      sn: _toI(json['SN']),
      distributorId: _toI(json['DistributorID']),
      date: _parseDate(json['DATE']),
      productName: (json['ProductName'] ?? '').toString(),
      name: (json['Name'] ?? '').toString(),
      receivedAmt: _toD(json['RECEIVED_AMT']),
    );
  }

  Map<String, dynamic> toJson() => {
    'SN': sn,
    'DistributorID': distributorId,
    'DATE': _fmt(date),
    'ProductName': productName,
    'Name': name,
    'RECEIVED_AMT': receivedAmt,
  };

  CashReceivedItem copyWith({
    int? sn,
    int? distributorId,
    DateTime? date,
    String? productName,
    String? name,
    double? receivedAmt,
  }) {
    return CashReceivedItem(
      sn: sn ?? this.sn,
      distributorId: distributorId ?? this.distributorId,
      date: date ?? this.date,
      productName: productName ?? this.productName,
      name: name ?? this.name,
      receivedAmt: receivedAmt ?? this.receivedAmt,
    );
  }

  static String _two(int n) => n < 10 ? '0$n' : '$n';

  /// Default serialization format (you can change to yyyy-MM-dd if needed)
  static String _fmt(DateTime d) =>
      '${_two(d.day)}/${_two(d.month)}/${d.year}';
}
