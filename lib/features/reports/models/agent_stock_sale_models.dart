import 'dart:convert';

class StockSaleResponse {
  final List<StockSaleItem> result;
  StockSaleResponse({required this.result});

  factory StockSaleResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List? ?? [])
        .map((e) => StockSaleItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return StockSaleResponse(result: list);
  }

  static StockSaleResponse fromJsonString(String s) =>
      StockSaleResponse.fromJson(json.decode(s) as Map<String, dynamic>);
}

class StockSaleItem {
  final int sn;
  final DateTime date;       // from "DATE": "dd/MM/yyyy"
  final String productName;  // "ProductName"
  final String name;         // agent name ("Name")
  final double stockSale;    // "STOCK_SALE"

  StockSaleItem({
    required this.sn,
    required this.date,
    required this.productName,
    required this.name,
    required this.stockSale,
  });

  factory StockSaleItem.fromJson(Map<String, dynamic> json) {
    String s = (json['DATE'] ?? '').toString().trim();
    DateTime parsed = DateTime.now();
    if (s.isNotEmpty) {
      final p = s.split('/');
      if (p.length == 3) {
        parsed = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      }
    }
    double toD(v) => switch (v) {
      num n => n.toDouble(),
      String t when t.trim().isEmpty => 0,
      String t => double.tryParse(t) ?? 0,
      _ => 0
    };

    return StockSaleItem(
      sn: (json['SN'] ?? 0) as int,
      date: parsed,
      productName: (json['ProductName'] ?? '').toString(),
      name: (json['Name'] ?? '').toString(),
      stockSale: toD(json['STOCK_SALE']),
    );
  }
}
