// lib/features/reports/models/distributor_models.dart
import 'dart:convert';

class DistributorListResponse {
  final List<DistributorItem> result;

  const DistributorListResponse({required this.result});

  factory DistributorListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List<dynamic>? ?? [])
        .map((e) => DistributorItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return DistributorListResponse(result: list);
  }

  Map<String, dynamic> toJson() => {
    'Result': result.map((e) => e.toJson()).toList(),
  };

  DistributorListResponse copyWith({List<DistributorItem>? result}) =>
      DistributorListResponse(result: result ?? this.result);

  // Convenience helpers
  static DistributorListResponse fromJsonString(String source) =>
      DistributorListResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);
  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() => 'DistributorListResponse(result: $result)';
}

class DistributorItem {
  final int distributorId;
  final String name;

  const DistributorItem({
    required this.distributorId,
    required this.name,
  });

  factory DistributorItem.fromJson(Map<String, dynamic> json) => DistributorItem(
    distributorId: _asInt(json['DistributorID']),
    name: (json['Name'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'DistributorID': distributorId,
    'Name': name,
  };

  DistributorItem copyWith({
    int? distributorId,
    String? name,
  }) =>
      DistributorItem(
        distributorId: distributorId ?? this.distributorId,
        name: name ?? this.name,
      );

  @override
  String toString() => 'DistributorItem(distributorId: $distributorId, name: $name)';
}

/// Safe int parser supporting int/double/string
int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.round();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}
