// Top-level response model
class AgentStockIssueResponse {
  final List<AgentStockIssueModel> result;

  AgentStockIssueResponse({required this.result});

  factory AgentStockIssueResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['Result'] as List<dynamic>? ?? []);
    return AgentStockIssueResponse(
      result: list
          .map((e) => AgentStockIssueModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'Result': result.map((e) => e.toJson()).toList(),
  };
}

// Single row model
class AgentStockIssueModel {
  final double column1;

  AgentStockIssueModel({
    required this.column1,
  });

  factory AgentStockIssueModel.fromJson(Map<String, dynamic> json) {
    return AgentStockIssueModel(
      column1: (json['Column1'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'Column1': column1,
  };
}
