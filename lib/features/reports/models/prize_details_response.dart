// lib/features/reports/model/prize_details_simple.dart
import 'dart:convert';

class PrizeDetailsResponse {
  final List<PrizeDetail> result;

  PrizeDetailsResponse({required this.result});

  factory PrizeDetailsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List? ?? [])
        .map((e) => PrizeDetail.fromJson(e as Map<String, dynamic>))
        .toList();
    return PrizeDetailsResponse(result: list);
  }

  Map<String, dynamic> toJson() => {
    'Result': result.map((e) => e.toJson()).toList(),
  };

  // Optional helpers
  static PrizeDetailsResponse fromJsonString(String source) =>
      PrizeDetailsResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);
  String toJsonString() => jsonEncode(toJson());
}

class PrizeDetail {
  final String luckySlno;     // LUCKY_SLNO
  final double prizeAmount;   // PRIZE_AMOUNT
  final String customerName;  // CUSTOMER_NAME
  final String customerMob;   // CUSTOMER_MOB
  final String date;          // DATE (keep as raw string for simplicity)
  final String claimStatus;   // CLAIM_STATUS
  final String? claimedOn;    // CLAIMED_ON (optional)
  final String agent;         // AGENT

  PrizeDetail({
    required this.luckySlno,
    required this.prizeAmount,
    required this.customerName,
    required this.customerMob,
    required this.date,
    required this.claimStatus,
    required this.agent,
    this.claimedOn,
  });

  factory PrizeDetail.fromJson(Map<String, dynamic> json) => PrizeDetail(
    luckySlno: (json['LUCKY_SLNO'] ?? '').toString(),
    prizeAmount: _toDouble(json['PRIZE_AMOUNT']),
    customerName: (json['CUSTOMER_NAME'] ?? '').toString(),
    customerMob: (json['CUSTOMER_MOB'] ?? '').toString(),
    date: (json['DATE'] ?? '').toString(),
    claimStatus: (json['CLAIM_STATUS'] ?? '').toString(),
    claimedOn: json['CLAIMED_ON']?.toString(),
    agent: (json['AGENT'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'LUCKY_SLNO': luckySlno,
    'PRIZE_AMOUNT': prizeAmount,
    'CUSTOMER_NAME': customerName,
    'CUSTOMER_MOB': customerMob,
    'DATE': date,
    'CLAIM_STATUS': claimStatus,
    'CLAIMED_ON': claimedOn,
    'AGENT': agent,
  };
}

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}
