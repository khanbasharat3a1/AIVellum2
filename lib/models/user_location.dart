class UserLocation {
  final String countryCode;
  final String countryName;
  final bool isIndia;

  UserLocation({
    required this.countryCode,
    required this.countryName,
    required this.isIndia,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      countryCode: json['countryCode'] ?? 'US',
      countryName: json['countryName'] ?? 'United States',
      isIndia: json['isIndia'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'countryName': countryName,
      'isIndia': isIndia,
    };
  }
}