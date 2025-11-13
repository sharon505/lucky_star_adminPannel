class GetTeam {
  final int teamId;
  final String teamName;

  GetTeam({
    required this.teamId,
    required this.teamName,
  });

  factory GetTeam.fromJson(Map<String, dynamic> json) {
    return GetTeam(
      teamId: json['TeamID'] ?? 0,
      teamName: json['TeamName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TeamID': teamId,
      'TeamName': teamName,
    };
  }
}
