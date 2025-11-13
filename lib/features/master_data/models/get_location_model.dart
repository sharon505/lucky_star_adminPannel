class GetLocation {
  final int locationId;
  final String locationName;

  GetLocation({
    required this.locationId,
    required this.locationName,
  });

  factory GetLocation.fromJson(Map<String, dynamic> json) {
    return GetLocation(
      locationId: json['LocationID'] ?? 0,
      locationName: json['LocationName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LocationID': locationId,
      'LocationName': locationName,
    };
  }
}
