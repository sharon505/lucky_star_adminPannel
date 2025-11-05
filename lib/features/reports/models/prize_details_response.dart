// lib/features/reports/model/prize_details_response.dart

class PrizeDetailsResponse {
  final List<PrizeDetail> result;

  const PrizeDetailsResponse({required this.result});

  factory PrizeDetailsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List? ?? []);
    return PrizeDetailsResponse(
      result: list
          .map((e) => PrizeDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'Result': result.map((e) => e.toJson()).toList(),
  };
}

class PrizeDetail {
  final String luckySlno;         // "LUCKY_SLNO"
  final double prizeAmount;       // "PRIZE_AMOUNT"
  final String customerName;      // "CUSTOMER_NAME"
  final String customerMob;       // "CUSTOMER_MOB"
  final DateTime? date;           // "DATE" -> ISO string, nullable if parse fails
  final String claimStatus;       // "CLAIM_STATUS" (kept as raw string)

  const PrizeDetail({
    required this.luckySlno,
    required this.prizeAmount,
    required this.customerName,
    required this.customerMob,
    required this.date,
    required this.claimStatus,
  });

  factory PrizeDetail.fromJson(Map<String, dynamic> json) {
    return PrizeDetail(
      luckySlno: (json['LUCKY_SLNO'] ?? '').toString(),
      prizeAmount: _toDouble(json['PRIZE_AMOUNT']),
      customerName: (json['CUSTOMER_NAME'] ?? '').toString(),
      customerMob: (json['CUSTOMER_MOB'] ?? '').toString(),
      date: _tryParseDate(json['DATE']),
      claimStatus: (json['CLAIM_STATUS'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'LUCKY_SLNO': luckySlno,
    'PRIZE_AMOUNT': prizeAmount,
    'CUSTOMER_NAME': customerName,
    'CUSTOMER_MOB': customerMob,
    'DATE': date?.toIso8601String(),
    'CLAIM_STATUS': claimStatus,
  };
}

// -------- helpers --------
double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

DateTime? _tryParseDate(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}
