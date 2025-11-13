class LocationStockIssueModel {
  final int column1;

  LocationStockIssueModel({
    required this.column1,
  });

  factory LocationStockIssueModel.fromJson(Map<String, dynamic> json) {
    return LocationStockIssueModel(
      column1: (json['Column1'] ?? 0) is int
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
