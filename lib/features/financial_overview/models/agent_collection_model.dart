// lib/features/financial_overview/models/agent_collection_model.dart

import 'dart:convert';

/// Top-level response wrapper
class AgentCollectionResponse {
  final List<AgentCollectionModel> result;

  const AgentCollectionResponse({required this.result});

  factory AgentCollectionResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List<dynamic>? ?? [])
        .map((e) => AgentCollectionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return AgentCollectionResponse(result: list);
  }

  /// Handy helper if you have the raw response string
  factory AgentCollectionResponse.fromJsonStr(String source) =>
      AgentCollectionResponse.fromJson(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toJson() => {
    'Result': result.map((e) => e.toJson()).toList(),
  };

  AgentCollectionResponse copyWith({List<AgentCollectionModel>? result}) =>
      AgentCollectionResponse(result: result ?? this.result);

  @override
  String toString() => 'AgentCollectionResponse(result: $result)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AgentCollectionResponse && runtimeType == other.runtimeType && result == other.result;

  @override
  int get hashCode => result.hashCode;
}

/// Individual row model
class AgentCollectionModel {
  final int statusId;
  final String msg;

  const AgentCollectionModel({
    required this.statusId,
    required this.msg,
  });

  factory AgentCollectionModel.fromJson(Map<String, dynamic> json) {
    return AgentCollectionModel(
      statusId: (json['STATUSID'] as num?)?.toInt() ?? 0,
      msg: (json['MSG'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'STATUSID': statusId,
    'MSG': msg,
  };

  AgentCollectionModel copyWith({
    int? statusId,
    String? msg,
  }) {
    return AgentCollectionModel(
      statusId: statusId ?? this.statusId,
      msg: msg ?? this.msg,
    );
  }

  @override
  String toString() => 'AgentCollectionModel(statusId: $statusId, msg: $msg)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AgentCollectionModel &&
              runtimeType == other.runtimeType &&
              statusId == other.statusId &&
              msg == other.msg;

  @override
  int get hashCode => Object.hash(statusId, msg);
}
