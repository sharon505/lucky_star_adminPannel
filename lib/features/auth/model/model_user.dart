class UserModel {
  final String usercode;
  final String password;

  UserModel({required this.usercode, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'Username': usercode,
      'Password': password,
    };
  }
}
