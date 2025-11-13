class GetCurrentStockModel {
  final int recptQnty;

  GetCurrentStockModel({
    required this.recptQnty,
  });

  factory GetCurrentStockModel.fromJson(Map<String, dynamic> json) {
    return GetCurrentStockModel(
      recptQnty: (json['recptqnty'] ?? 0) is int
          ? json['recptqnty'] as int
          : int.tryParse(json['recptqnty'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recptqnty': recptQnty,
    };
  }
}
