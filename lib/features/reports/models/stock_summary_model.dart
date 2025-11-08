// lib/features/financial_overview/models/stock_summary_model.dart
import 'dart:convert';

class StockSummaryResponse {
  final StockSummary result;
  final IssuedStock data;
  final CurrentStock table2;
  final TodaysSaleCount table3;
  final TodaysSaleValue table4;
  final TodaysPrizedCount table5;
  final TodaysPrizedPayout table6;

  StockSummaryResponse({
    required this.result,
    required this.data,
    required this.table2,
    required this.table3,
    required this.table4,
    required this.table5,
    required this.table6,
  });

  factory StockSummaryResponse.fromJson(Map<String, dynamic> json) {
    return StockSummaryResponse(
      result: StockSummary.fromJson(_firstMap(json['Result'])),
      data: IssuedStock.fromJson(_firstMap(json['Data'])),
      table2: CurrentStock.fromJson(_firstMap(json['Table2'])),
      table3: TodaysSaleCount.fromJson(_firstMap(json['Table3'])),
      table4: TodaysSaleValue.fromJson(_firstMap(json['Table4'])),
      table5: TodaysPrizedCount.fromJson(_firstMap(json['Table5'])),
      table6: TodaysPrizedPayout.fromJson(_firstMap(json['Table6'])),
    );
  }

  Map<String, dynamic> toJson() => {
    'Result': [result.toJson()],
    'Data': [data.toJson()],
    'Table2': [table2.toJson()],
    'Table3': [table3.toJson()],
    'Table4': [table4.toJson()],
    'Table5': [table5.toJson()],
    'Table6': [table6.toJson()],
  };

  static Map<String, dynamic> _firstMap(dynamic list) {
    if (list is List && list.isNotEmpty && list.first is Map<String, dynamic>) {
      return list.first as Map<String, dynamic>;
    }
    return {};
  }

  factory StockSummaryResponse.fromJsonStr(String source) =>
      StockSummaryResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

/// ---------------- Each sub-model ----------------

class StockSummary {
  final double totalStock;

  StockSummary({required this.totalStock});

  factory StockSummary.fromJson(Map<String, dynamic> json) => StockSummary(
    totalStock: _asDouble(json['TOTAL STOCK']),
  );

  Map<String, dynamic> toJson() => {'TOTAL STOCK': totalStock};
}

class IssuedStock {
  final double issuedStock;

  IssuedStock({required this.issuedStock});

  factory IssuedStock.fromJson(Map<String, dynamic> json) => IssuedStock(
    issuedStock: _asDouble(json['ISSUED STOCK']),
  );

  Map<String, dynamic> toJson() => {'ISSUED STOCK': issuedStock};
}

class CurrentStock {
  final double currentStock;

  CurrentStock({required this.currentStock});

  factory CurrentStock.fromJson(Map<String, dynamic> json) => CurrentStock(
    currentStock: _asDouble(json['CURRENT STOCK']),
  );

  Map<String, dynamic> toJson() => {'CURRENT STOCK': currentStock};
}

class TodaysSaleCount {
  final double todaysSaleCount;

  TodaysSaleCount({required this.todaysSaleCount});

  factory TodaysSaleCount.fromJson(Map<String, dynamic> json) => TodaysSaleCount(
    todaysSaleCount: _asDouble(json['TODAYS SALE COUNT']),
  );

  Map<String, dynamic> toJson() => {'TODAYS SALE COUNT': todaysSaleCount};
}

class TodaysSaleValue {
  final double todaysSaleValue;

  TodaysSaleValue({required this.todaysSaleValue});

  factory TodaysSaleValue.fromJson(Map<String, dynamic> json) => TodaysSaleValue(
    todaysSaleValue: _asDouble(json['TODAYS SALE VALUE']),
  );

  Map<String, dynamic> toJson() => {'TODAYS SALE VALUE': todaysSaleValue};
}

class TodaysPrizedCount {
  final double todaysPrizedCount;

  TodaysPrizedCount({required this.todaysPrizedCount});

  factory TodaysPrizedCount.fromJson(Map<String, dynamic> json) => TodaysPrizedCount(
    todaysPrizedCount: _asDouble(json['TODAYS PRIZED COUNT']),
  );

  Map<String, dynamic> toJson() => {'TODAYS PRIZED COUNT': todaysPrizedCount};
}

class TodaysPrizedPayout {
  final double todaysPrizedPayout;

  TodaysPrizedPayout({required this.todaysPrizedPayout});

  factory TodaysPrizedPayout.fromJson(Map<String, dynamic> json) => TodaysPrizedPayout(
    todaysPrizedPayout: _asDouble(json['TODAYS PRIZED PAYOUT']),
  );

  Map<String, dynamic> toJson() => {'TODAYS PRIZED PAYOUT': todaysPrizedPayout};
}

/// ---------------- Utility ----------------
double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  final s = v.toString().trim();
  if (s.isEmpty) return 0.0;
  return double.tryParse(s) ?? 0.0;
}
