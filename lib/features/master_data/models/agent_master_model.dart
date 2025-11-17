class AgentMasterResponse {
  final List<AgentMaster> result;

  AgentMasterResponse({
    required this.result,
  });

  factory AgentMasterResponse.fromJson(Map<String, dynamic> json) {
    return AgentMasterResponse(
      result: (json['Result'] as List<dynamic>? ?? [])
          .map((e) => AgentMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AgentMaster {
  final int column1;

  AgentMaster({
    required this.column1,
  });

  factory AgentMaster.fromJson(Map<String, dynamic> json) {
    return AgentMaster(
      column1: json['Column1'] is int
          ? json['Column1']
          : int.tryParse(json['Column1'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Column1': column1,
    };
  }
}
