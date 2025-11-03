class LoginResponse {
  final List<Result> result;
  final List<UserData> data;

  LoginResponse({
    required this.result,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      result: (json['Result'] as List)
          .map((e) => Result.fromJson(e))
          .toList(),
      data: (json['Data'] as List)
          .map((e) => UserData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Result': result.map((e) => e.toJson()).toList(),
      'Data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class Result {
  final int statusId;
  final String msg;

  Result({
    required this.statusId,
    required this.msg,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      statusId: json['STATUSID'],
      msg: json['MSG'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'STATUSID': statusId,
      'MSG': msg,
    };
  }
}

class UserData {
  final String name;
  final int distributorId;
  final String distributorCode;

  UserData({
    required this.name,
    required this.distributorId,
    required this.distributorCode,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      name: json['Name']?.trim() ?? '',
      distributorId: json['DistributorID'],
      distributorCode: json['DistributorCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'DistributorID': distributorId,
      'DistributorCode': distributorCode,
    };
  }
}
