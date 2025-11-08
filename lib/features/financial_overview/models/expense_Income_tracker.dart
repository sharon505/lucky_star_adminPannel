// lib/features/financial_overview/models/cash_book_model.dart
import 'dart:convert';

class CashBookResponse {
  final List<CashBookItem> items;

  CashBookResponse({required this.items});

  factory CashBookResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List? ?? [])
        .map((e) => CashBookItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return CashBookResponse(items: list);
  }

  Map<String, dynamic> toJson() => {
    'Result': items.map((e) => e.toJson()).toList(),
  };

  factory CashBookResponse.fromJsonStr(String source) =>
      CashBookResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toJsonStr() => jsonEncode(toJson());
}

class CashBookItem {
  /// Example: "2025-11-04"
  final DateTime tranDate;
  final double debit;
  final double credit;

  /// e.g., "CASH", "UPI", "CARD", "BANK", "CHEQUE", etc.
  final TransactionMode mode;

  /// May be empty.
  final String transactionRefNo;

  /// e.g., "04/11/2025 SL(519x5=2595) X 30% CM PAID"
  final String narration;

  /// e.g., "INCENTIVE PAID"
  final String ledgerName;

  /// e.g., "LIABILITY", "ASSET", "EXPENSE", "INCOME"
  final LedgerGroup ledgerGroup;

  CashBookItem({
    required this.tranDate,
    required this.debit,
    required this.credit,
    required this.mode,
    required this.transactionRefNo,
    required this.narration,
    required this.ledgerName,
    required this.ledgerGroup,
  });

  factory CashBookItem.fromJson(Map<String, dynamic> json) {
    return CashBookItem(
      tranDate: _parseDate(json['TRAN_DATE']),
      debit: _asDouble(json['DEBIT']),
      credit: _asDouble(json['CREDIT']),
      mode: TransactionModeX.fromString(json['TRANSACTION_MODE']),
      transactionRefNo: (json['TRANSACTION_REF_NO'] ?? '').toString(),
      narration: (json['NARRATION'] ?? '').toString(),
      ledgerName: (json['LEDGER_NAME'] ?? '').toString(),
      ledgerGroup: LedgerGroupX.fromString(json['GROUP']),
    );
  }

  Map<String, dynamic> toJson() => {
    'TRAN_DATE': _fmtDate(tranDate),
    'DEBIT': debit,
    'CREDIT': credit,
    'TRANSACTION_MODE': mode.name.toUpperCase(),
    'TRANSACTION_REF_NO': transactionRefNo,
    'NARRATION': narration,
    'LEDGER_NAME': ledgerName,
    'GROUP': ledgerGroup.name.toUpperCase(),
  };

  CashBookItem copyWith({
    DateTime? tranDate,
    double? debit,
    double? credit,
    TransactionMode? mode,
    String? transactionRefNo,
    String? narration,
    String? ledgerName,
    LedgerGroup? ledgerGroup,
  }) {
    return CashBookItem(
      tranDate: tranDate ?? this.tranDate,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      mode: mode ?? this.mode,
      transactionRefNo: transactionRefNo ?? this.transactionRefNo,
      narration: narration ?? this.narration,
      ledgerName: ledgerName ?? this.ledgerName,
      ledgerGroup: ledgerGroup ?? this.ledgerGroup,
    );
  }

  @override
  String toString() =>
      'CashBookItem(date: ${_fmtDate(tranDate)}, debit: $debit, credit: $credit, mode: ${mode.name}, ref: $transactionRefNo, narration: $narration, ledger: $ledgerName, group: ${ledgerGroup.name})';

  // ---- utils ----
  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
    final s = v.toString().trim();
    // Expecting ISO yyyy-MM-dd; fallback to DateTime.tryParse.
    return DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _fmtDate(DateTime d) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  static double _asDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return 0.0;
    return double.tryParse(s) ?? 0.0;
  }
}

/// Payment/receipt channel
enum TransactionMode { cash, upi, card, bank, cheque, other }

extension TransactionModeX on TransactionMode {
  static TransactionMode fromString(dynamic v) {
    final s = (v ?? '').toString().trim().toUpperCase();
    switch (s) {
      case 'CASH':
        return TransactionMode.cash;
      case 'UPI':
        return TransactionMode.upi;
      case 'CARD':
        return TransactionMode.card;
      case 'BANK':
      case 'NEFT':
      case 'RTGS':
      case 'IMPS':
        return TransactionMode.bank;
      case 'CHEQUE':
      case 'CHECK':
        return TransactionMode.cheque;
      default:
        return TransactionMode.other;
    }
  }
}

/// Ledger group/classification
enum LedgerGroup { asset, liability, income, expense, other }

extension LedgerGroupX on LedgerGroup {
  static LedgerGroup fromString(dynamic v) {
    final s = (v ?? '').toString().trim().toUpperCase();
    switch (s) {
      case 'ASSET':
        return LedgerGroup.asset;
      case 'LIABILITY':
        return LedgerGroup.liability;
      case 'INCOME':
        return LedgerGroup.income;
      case 'EXPENSE':
      case 'EXPENSES':
        return LedgerGroup.expense;
      default:
        return LedgerGroup.other;
    }
  }
}
