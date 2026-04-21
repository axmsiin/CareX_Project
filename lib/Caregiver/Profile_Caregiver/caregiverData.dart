class caregiverData {
  String fullName;
  String nickName;
  String phone;
  DateTime? birthDate;
  int weight;
  int height;
  String gender;
  List<String> availableDays;
  bool allDayAvailable;
  String startTime;
  String endTime;
  String address;
  String province;
  double latitude;
  double longitude;
  String degree;
  DateTime? graduationDate;
  String? caregiverId;
  int? score;

  String guarantorName;
  String guarantorPhone;
  String guarantorRelation;

  caregiverData({
    this.fullName = '',
    this.nickName = '',
    this.phone = '',
    this.birthDate,
    this.weight = 0,
    this.height = 0,
    this.gender = '',
    this.availableDays = const [],
    this.allDayAvailable = false,
    this.startTime = '',
    this.endTime = '',
    this.address = '',
    this.province = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.degree = '',
    this.graduationDate,
    this.caregiverId,
    this.score,
    this.guarantorName = '',
    this.guarantorPhone = '',
    this.guarantorRelation = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'nickName': nickName,
      'phone': phone,
      'birthDate': birthDate?.toIso8601String(),
      'weight': weight,
      'height': height,
      'gender': gender,
      'availableDays': availableDays,
      'allDayAvailable': allDayAvailable,
      'startTime': startTime,
      'endTime': endTime,
      'address': address,
      'province': province,
      'latitude': latitude,
      'longitude': longitude,
      'degree': degree,
      'graduationDate': graduationDate?.toIso8601String(),
      'caregiverId': caregiverId,
      'score': score,
      'guarantorName': guarantorName,
      'guarantorPhone': guarantorPhone,
      'guarantorRelation': guarantorRelation,
    };
  }

  factory caregiverData.fromJson(Map<String, dynamic> json) {
    return caregiverData(
      fullName: json['fullName']?.toString() ??
          json['fullname']?.toString() ??
          json['user_name']?.toString() ??
          '',
      nickName: json['nickName']?.toString() ?? json['alias']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['tel']?.toString() ?? '',
      birthDate: DateTime.tryParse(
        json['birthDate']?.toString() ?? json['birthday']?.toString() ?? '',
      ),
      weight: json['weight'] is int
          ? json['weight']
          : int.tryParse('${json['weight']}') ?? 0,
      height: json['height'] is int
          ? json['height']
          : int.tryParse('${json['height']}') ?? 0,
      gender: json['gender']?.toString() ?? '',
      availableDays:
          (json['availableDays'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      allDayAvailable: json['allDayAvailable'] == true,
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      latitude: json['latitude'] is double
          ? json['latitude']
          : double.tryParse('${json['latitude']}') ?? 0.0,
      longitude: json['longitude'] is double
          ? json['longitude']
          : double.tryParse('${json['longitude']}') ?? 0.0,
      degree: json['degree']?.toString() ?? '',
      graduationDate: DateTime.tryParse(
        json['graduationDate']?.toString() ?? '',
      ),
      caregiverId:
          json['caregiverId']?.toString() ?? json['caregiver_id']?.toString(),
      score: json['score'] is int
          ? json['score']
          : int.tryParse('${json['score']}'),
      guarantorName: json['guarantorName']?.toString() ??
          json['guarantor_name']?.toString() ??
          '',
      guarantorPhone: json['guarantorPhone']?.toString() ??
          json['guarantor_phone']?.toString() ??
          '',
      guarantorRelation: json['guarantorRelation']?.toString() ??
          json['guarantor_relation']?.toString() ??
          '',
    );
  }
}
