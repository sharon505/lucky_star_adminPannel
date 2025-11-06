// lib/features/reports/models/agent_stock_issue_models.dart
import 'dart:convert';

class AgentStockIssueListResponse {
  final List<AgentStockIssueItem> result;

  const AgentStockIssueListResponse({required this.result});

  factory AgentStockIssueListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List<dynamic>? ?? [])
        .map((e) => AgentStockIssueItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return AgentStockIssueListResponse(result: list);
  }

  Map<String, dynamic> toJson() => {
    'Result': result.map((e) => e.toJson()).toList(),
  };

  // String helpers
  static AgentStockIssueListResponse fromJsonString(String source) =>
      AgentStockIssueListResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);
  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() => 'AgentStockIssueListResponse(result: $result)';
}

class AgentStockIssueItem {
  final int sn;                 // "SN"
  final String issueDate;       // "ISSUE_DATE" (dd/MM/yyyy)
  final String productName;     // "ProductName"
  final String name;            // "Name" (distributor name)
  final String distributorCode; // "DistributorCode"
  final double issueCount;      // "ISSUE_COUNT"

  const AgentStockIssueItem({
    required this.sn,
    required this.issueDate,
    required this.productName,
    required this.name,
    required this.distributorCode,
    required this.issueCount,
  });

  /// Parsed DateTime from [issueDate] with format dd/MM/yyyy.
  DateTime? get issueDateParsed => _parseDdMMyyyy(issueDate);

  factory AgentStockIssueItem.fromJson(Map<String, dynamic> json) {
    return AgentStockIssueItem(
      sn: _asInt(json['SN']),
      issueDate: (json['ISSUE_DATE'] ?? '').toString(),
      productName: (json['ProductName'] ?? '').toString(),
      name: (json['Name'] ?? '').toString(),
      distributorCode: (json['DistributorCode'] ?? '').toString(),
      issueCount: _asDouble(json['ISSUE_COUNT']),
    );
  }

  Map<String, dynamic> toJson() => {
    'SN': sn,
    'ISSUE_DATE': issueDate,
    'ProductName': productName,
    'Name': name,
    'DistributorCode': distributorCode,
    'ISSUE_COUNT': issueCount,
  };

  AgentStockIssueItem copyWith({
    int? sn,
    String? issueDate,
    String? productName,
    String? name,
    String? distributorCode,
    double? issueCount,
  }) {
    return AgentStockIssueItem(
      sn: sn ?? this.sn,
      issueDate: issueDate ?? this.issueDate,
      productName: productName ?? this.productName,
      name: name ?? this.name,
      distributorCode: distributorCode ?? this.distributorCode,
      issueCount: issueCount ?? this.issueCount,
    );
  }

  @override
  String toString() =>
      'AgentStockIssueItem(sn: $sn, issueDate: $issueDate, productName: $productName, name: $name, distributorCode: $distributorCode, issueCount: $issueCount)';
}

// ---- helpers ----

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.round();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

double _asDouble(dynamic v) {
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

DateTime? _parseDdMMyyyy(String s) {
  try {
    if (s.isEmpty) return null;
    final parts = s.split('/');
    if (parts.length != 3) return null;
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  } catch (_) {
    return null;
  }
}
