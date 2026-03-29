class CaregiverProfileRequest {
  final String? userId;
  final String fullname;
  final String alias;
  final String tel;
  final String gender;
  final int weight;
  final int height;
  final String address;
  final double latitude;
  final double longitude;
  final String province;
  final String birthday;

  CaregiverProfileRequest({
    this.userId,
    required this.fullname,
    required this.alias,
    required this.tel,
    required this.gender,
    required this.weight,
    required this.height,
    required this.address,
    this.latitude = 0.0,
    this.longitude = 0.0,
    required this.province,
    required this.birthday,
  });

  Map<String, dynamic> toJson() {
    return {
      if (userId != null && userId!.isNotEmpty) 'user_id': userId,
      'fullname': fullname,
      'alias': alias,
      'tel': tel,
      'gender': gender,
      'weight': weight,
      'height': height,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'province': province,
      'birthday': birthday,
    };
  }
}