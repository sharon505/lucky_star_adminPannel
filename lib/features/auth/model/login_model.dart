// lib/features/auth/model/login_response.dart

class LoginResponse {
  final List<LoginResult> result;
  final List<LoginData> data;

  const LoginResponse({
    required this.result,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      result: (json['Result'] as List? ?? [])
          .map((e) => LoginResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      data: (json['Data'] as List? ?? [])
          .map((e) => LoginData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Result': result.map((e) => e.toJson()).toList(),
      'Data': data.map((e) => e.toJson()).toList(),
    };
  }

  /// Convenience getters
  int? get statusId => result.isNotEmpty ? result.first.statusId : null;
  String? get message => result.isNotEmpty ? result.first.msg : null;

  /// First logged-in user (if any)
  LoginData? get user => data.isNotEmpty ? data.first : null;

  String? get userName => user?.name;
  int? get distributorId => user?.distributorId;
  String? get distributorCode => user?.distributorCode;
  int? get roleId => user?.roleId;
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

class LoginData {
  final String name;
  final int distributorId;
  final String distributorCode;
  final int roleId;

  const LoginData({
    required this.name,
    required this.distributorId,
    required this.distributorCode,
    required this.roleId,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      name: (json['Name'] ?? '').toString(),
      distributorId: (json['DistributorID'] as num?)?.toInt() ?? 0,
      distributorCode: (json['DistributorCode'] ?? '').toString(),
      roleId: (json['ROLE_ID'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'DistributorID': distributorId,
      'DistributorCode': distributorCode,
      'ROLE_ID': roleId,
    };
  }
}
