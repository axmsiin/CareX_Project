class CaregiverProfileRequest {
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
  final int score;
  final List<Map<String, dynamic>> timestamp;
  final String certificateType;
  final String certificateDate;
  final String guarantorName;
  final String guarantorTel;
  final String guarantorRelationship;

  CaregiverProfileRequest({
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
    required this.score,
    required this.timestamp,
    required this.certificateType,
    required this.certificateDate,
    this.guarantorName = '',
    this.guarantorTel = '',
    this.guarantorRelationship = '',
  });

  Map<String, dynamic> toJson() {
    return {
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
      'score': score,
      'timestamp': timestamp,
      'certificate_type': certificateType,
      'certificate_date': certificateDate,
      'guarantor_name': guarantorName,
      'guarantor_tel': guarantorTel,
      'guarantor_relationship': guarantorRelationship,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
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
      'timestamp': timestamp,
      'guarantor_name': guarantorName,
      'guarantor_tel': guarantorTel,
      'guarantor_relationship': guarantorRelationship,
    };
  }
}
