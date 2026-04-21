class ElderlyData {
  String fullName;
  String nickName;
  String phone;
  String birthDate;
  String gender;
  String weight;
  List<String> underlyingDiseases;
  String address;
  double latitude;
  double longitude;
  String zipcode;

  String startDate;
  String endDate;
  String startTime;
  String endTime;
  String salaryText;
  String serviceDatesText;
  String scheduleType;
  List<String> customDays;
  List<String> selectedNeeds;
  String needLevel;
  String eatingCare;
  String woundCare;
  String respiratoryCare;
  String monitoringCare;
  String status;
  String caregiver;
  String matchPercent;
  String caregiverPhone;
  String caregiverGender;
  String caregiverAge;
  String caregiverProvince;
  String caregiverExperience;
  String caregiverRating;
  String caregiverReviewCount;
  String caregiverBio;
  String? elderlyId;
  int? score;

  ElderlyData({
    required this.fullName,
    required this.nickName,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.weight,
    required this.underlyingDiseases,
    required this.address,
    this.latitude = 0.0,
    this.longitude = 0.0,
    required this.zipcode, 

    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.salaryText,
    required this.serviceDatesText,
    required this.scheduleType,
    required this.customDays,
    required this.selectedNeeds,
    required this.needLevel,
    required this.eatingCare,
    required this.woundCare,
    required this.respiratoryCare,
    required this.monitoringCare,
    required this.status,
    required this.caregiver,
    required this.matchPercent,
    required this.caregiverPhone,
    required this.caregiverGender,
    required this.caregiverAge,
    required this.caregiverProvince,
    required this.caregiverExperience,
    required this.caregiverRating,
    required this.caregiverReviewCount,
    required this.caregiverBio,
    this.elderlyId,
    this.score,
  });

  factory ElderlyData.empty() {
    return ElderlyData(
      fullName: '',
      nickName: '',
      phone: '',
      birthDate: '',
      gender: '',
      weight: '',
      underlyingDiseases: [],
      address: '',
      latitude: 0.0,
      longitude: 0.0,
      zipcode: '', 

      startDate: '',
      endDate: '',
      startTime: '',
      endTime: '',
      salaryText: '',
      serviceDatesText: '',
      scheduleType: '',
      customDays: [],
      selectedNeeds: [],
      needLevel: '',
      eatingCare: 'ไม่มี',
      woundCare: 'ไม่มี',
      respiratoryCare: 'ไม่มี',
      monitoringCare: 'ไม่มี',
      status: '',
      caregiver: '',
      matchPercent: '',
      caregiverPhone: '',
      caregiverGender: '',
      caregiverAge: '',
      caregiverProvince: '',
      caregiverExperience: '',
      caregiverRating: '',
      caregiverReviewCount: '',
      caregiverBio: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'nickName': nickName,
      'phone': phone,
      'birthDate': birthDate,
      'gender': gender,
      'weight': weight,
      'underlyingDiseases': underlyingDiseases,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'zipcode': zipcode, 

      'startDate': startDate,
      'endDate': endDate,
      'startTime': startTime,
      'endTime': endTime,
      'salaryText': salaryText,
      'serviceDatesText': serviceDatesText,
      'scheduleType': scheduleType,
      'customDays': customDays,
      'selectedNeeds': selectedNeeds,
      'needLevel': needLevel,
      'eatingCare': eatingCare,
      'woundCare': woundCare,
      'respiratoryCare': respiratoryCare,
      'monitoringCare': monitoringCare,
      'status': status,
      'caregiver': caregiver,
      'matchPercent': matchPercent,
      'caregiverPhone': caregiverPhone,
      'caregiverGender': caregiverGender,
      'caregiverAge': caregiverAge,
      'caregiverProvince': caregiverProvince,
      'caregiverExperience': caregiverExperience,
      'caregiverRating': caregiverRating,
      'caregiverReviewCount': caregiverReviewCount,
      'caregiverBio': caregiverBio,
      'elderlyId': elderlyId,
      'score': score,
    };
  }

  factory ElderlyData.fromJson(Map<String, dynamic> json) {
    final rawDiseases =
        json['underlyingDiseases'] ?? json['underlying_disease'];

    final diseases = rawDiseases is List
        ? rawDiseases.map((e) => e.toString()).toList()
        : (rawDiseases?.toString().trim().isNotEmpty ?? false)
            ? [rawDiseases.toString()]
            : <String>[];

    return ElderlyData(
      fullName:
          json['fullName']?.toString() ?? json['fullname']?.toString() ?? '',
      nickName: json['nickName']?.toString() ?? json['alias']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['tel']?.toString() ?? '',
      birthDate:
          json['birthDate']?.toString() ?? json['birthday']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      underlyingDiseases: diseases,
      address: json['address']?.toString() ?? '',
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : double.tryParse('${json['latitude'] ?? ''}') ?? 0.0,
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : double.tryParse('${json['longitude'] ?? ''}') ?? 0.0,
      zipcode: json['zipcode']?.toString() ?? '', // ✅ เพิ่ม

      startDate:
          json['startDate']?.toString() ?? json['start_date']?.toString() ?? '',
      endDate:
          json['endDate']?.toString() ?? json['end_date']?.toString() ?? '',
      startTime:
          json['startTime']?.toString() ?? json['start_time']?.toString() ?? '',
      endTime:
          json['endTime']?.toString() ?? json['end_time']?.toString() ?? '',
      salaryText: json['salaryText']?.toString() ??
          json['budget']?.toString() ??
          json['budget_max']?.toString() ??
          '',
      serviceDatesText: json['serviceDatesText']?.toString() ??
          json['service_date']?.toString() ??
          '',
      scheduleType: json['scheduleType']?.toString() ?? '',
      customDays:
          (json['customDays'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      selectedNeeds: ((json['selectedNeeds'] as List?) ??
              (json['service_needs'] as List?) ??
              (json['option_service'] as List?) ??
              const [])
          .map((e) => e.toString())
          .toList(),
      needLevel: json['needLevel']?.toString() ??
          json['care_level']?.toString() ??
          json['mandatory_level']?.toString() ??
          '',
      eatingCare: json['eatingCare']?.toString() ?? '',
      woundCare: json['woundCare']?.toString() ?? '',
      respiratoryCare: json['respiratoryCare']?.toString() ?? '',
      monitoringCare: json['monitoringCare']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      caregiver: json['caregiver']?.toString() ??
          json['caregiver_name']?.toString() ??
          '',
      matchPercent: json['matchPercent']?.toString() ??
          json['percent_match']?.toString() ??
          '',
      caregiverPhone: json['caregiverPhone']?.toString() ?? '',
      caregiverGender: json['caregiverGender']?.toString() ?? '',
      caregiverAge: json['caregiverAge']?.toString() ?? '',
      caregiverProvince: json['caregiverProvince']?.toString() ?? '',
      caregiverExperience: json['caregiverExperience']?.toString() ?? '',
      caregiverRating: json['caregiverRating']?.toString() ?? '',
      caregiverReviewCount: json['caregiverReviewCount']?.toString() ?? '',
      caregiverBio: json['caregiverBio']?.toString() ?? '',
      elderlyId:
          json['elderlyId']?.toString() ?? json['elderly_id']?.toString(),
      score: json['score'] is int
          ? json['score']
          : int.tryParse('${json['score'] ?? ''}'),
    );
  }
}
