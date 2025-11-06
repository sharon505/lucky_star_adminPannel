// lib/features/reports/models/cash_receivables_models.dart
import 'dart:convert';

class CashReceivableItem {
  final int sn;
  final int distributorId;
  final String productName;
  final String name;
  final double debit;
  final double credit;
  final double payout;
  final double balanceReceive;
  final double receivable;

  const CashReceivableItem({
    required this.sn,
    required this.distributorId,
    required this.productName,
    required this.name,
    required this.debit,
    required this.credit,
    required this.payout,
    required this.balanceReceive,
    required this.receivable,
  });

  /// Factory: tolerant to int/double/null
  factory CashReceivableItem.fromJson(Map<String, dynamic> json) {
    double _d(dynamic v) => v == null ? 0.0 : (v as num).toDouble();

    return CashReceivableItem(
      sn: (json['SN'] ?? 0) as int,
      distributorId: (json['DistributorID'] ?? 0) as int,
      productName: (json['ProductName'] ?? '').toString(),
      name: (json['Name'] ?? '').toString(),
      debit: _d(json['DEBIT']),
      credit: _d(json['CREDIT']),
      payout: _d(json['PAYOUT']),
      balanceReceive: _d(json['BALANCE_RECEIVE']),
      receivable: _d(json['RECEIVABLE']),
    );
  }

  Map<String, dynamic> toJson() => {
    'SN': sn,
    'DistributorID': distributorId,
    'ProductName': productName,
    'Name': name,
    'DEBIT': debit,
    'CREDIT': credit,
    'PAYOUT': payout,
    'BALANCE_RECEIVE': balanceReceive,
    'RECEIVABLE': receivable,
  };

  CashReceivableItem copyWith({
    int? sn,
    int? distributorId,
    String? productName,
    String? name,
    double? debit,
    double? credit,
    double? payout,
    double? balanceReceive,
    double? receivable,
  }) {
    return CashReceivableItem(
      sn: sn ?? this.sn,
      distributorId: distributorId ?? this.distributorId,
      productName: productName ?? this.productName,
      name: name ?? this.name,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      payout: payout ?? this.payout,
      balanceReceive: balanceReceive ?? this.balanceReceive,
      receivable: receivable ?? this.receivable,
    );
  }
}

/// Wrapper for the API envelope: { "Result": [ ... ] }
class CashReceivableListResponse {
  final List<CashReceivableItem> result;

  const CashReceivableListResponse({required this.result});

  factory CashReceivableListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List<dynamic>? ?? [])
        .map((e) => CashReceivableItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return CashReceivableListResponse(result: list);
  }

  Map<String, dynamic> toJson() => {
    'Result': result.map((e) => e.toJson()).toList(),
  };

  /// Convenience: parse directly from raw string
  factory CashReceivableListResponse.fromRawJson(String source) =>
      CashReceivableListResponse.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}
