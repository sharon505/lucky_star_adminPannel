// lib/features/auth/model/login_response.dart

class LoginResponse {
  final List<LoginResult> result;
  final List<dynamic> data; // Keep dynamic if Data is empty or varies

  const LoginResponse({
    required this.result,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      result: (json['Result'] as List? ?? [])
          .map((e) => LoginResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      data: (json['Data'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Result': result.map((e) => e.toJson()).toList(),
      'Data': data,
    };
  }

  /// Convenience getters (optional)
  int? get statusId => result.isNotEmpty ? result.first.statusId : null;
  String? get message => result.isNotEmpty ? result.first.msg : null;
}

class LoginResult {
  final int statusId;
  final String msg;

  const LoginResult({
    required this.statusId,
    required this.msg,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      statusId: (json['STATUSID'] as num?)?.toInt() ?? 0,
      msg: (json['MSG'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'STATUSID': statusId,
      'MSG': msg,
    };
  }
}
