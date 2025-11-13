class AgentModel {
  final String name;
  final int disId;
  final String code;

  AgentModel({
    required this.name,
    required this.disId,
    required this.code,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      name: json['Name'] ?? '',
      disId: json['DisID'] ?? 0,
      code: json['Code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'DisID': disId,
      'Code': code,
    };
  }
}
