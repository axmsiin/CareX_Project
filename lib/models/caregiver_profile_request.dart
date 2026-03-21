class CaregiverProfileRequest {
  final int userId;
  final String fullname;
  final String alias;
  final String tel;
  final String gender;
  final int weight;
  final int height;
  final String address;
  final String province;
  final String birthday;

  CaregiverProfileRequest({
    required this.userId,
    required this.fullname,
    required this.alias,
    required this.tel,
    required this.gender,
    required this.weight,
    required this.height,
    required this.address,
    required this.province,
    required this.birthday,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fullname': fullname,
      'alias': alias,
      'tel': tel,
      'gender': gender,
      'weight': weight,
      'height': height,
      'address': address,
      'province': province,
      'birthday': birthday,
    };
  }
}