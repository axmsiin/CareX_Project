class ElderlyData {
  String fullName;
  String nickName;
  String phone;
  String birthDate;
  String gender;
  String weight;
  String disease;
  String address;
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
  int? elderlyId;
  int? score;

  ElderlyData({
    required this.fullName,
    required this.nickName,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.weight,
    required this.disease,
    required this.address,
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
      disease: '',
      address: '',
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
      'disease': disease,
      'address': address,
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
    return ElderlyData(
      fullName: json['fullName']?.toString() ?? json['fullname']?.toString() ?? '',
      nickName: json['nickName']?.toString() ?? json['alias']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['tel']?.toString() ?? '',
      birthDate: json['birthDate']?.toString() ?? json['birthday']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      disease: json['disease']?.toString() ?? json['underlying_disease']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      startDate: json['startDate']?.toString() ?? json['start_date']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? json['end_date']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? json['start_time']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? json['end_time']?.toString() ?? '',
      salaryText: json['salaryText']?.toString() ?? json['budget']?.toString() ?? '',
      serviceDatesText: json['serviceDatesText']?.toString() ?? json['service_date']?.toString() ?? '',
      scheduleType: json['scheduleType']?.toString() ?? '',
      customDays: (json['customDays'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      selectedNeeds: ((json['selectedNeeds'] as List?) ?? (json['service_needs'] as List?) ?? const []).map((e) => e.toString()).toList(),
      needLevel: json['needLevel']?.toString() ?? json['care_level']?.toString() ?? '',
      eatingCare: json['eatingCare']?.toString() ?? '',
      woundCare: json['woundCare']?.toString() ?? '',
      respiratoryCare: json['respiratoryCare']?.toString() ?? '',
      monitoringCare: json['monitoringCare']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      caregiver: json['caregiver']?.toString() ?? json['caregiver_name']?.toString() ?? '',
      matchPercent: json['matchPercent']?.toString() ?? json['percent_match']?.toString() ?? '',
      caregiverPhone: json['caregiverPhone']?.toString() ?? '',
      caregiverGender: json['caregiverGender']?.toString() ?? '',
      caregiverAge: json['caregiverAge']?.toString() ?? '',
      caregiverProvince: json['caregiverProvince']?.toString() ?? '',
      caregiverExperience: json['caregiverExperience']?.toString() ?? '',
      caregiverRating: json['caregiverRating']?.toString() ?? '',
      caregiverReviewCount: json['caregiverReviewCount']?.toString() ?? '',
      caregiverBio: json['caregiverBio']?.toString() ?? '',
      elderlyId: json['elderlyId'] is int ? json['elderlyId'] : int.tryParse('${json['elderlyId'] ?? json['elderly_id']}'),
      score: json['score'] is int ? json['score'] : int.tryParse('${json['score']}'),
    );
  }
}
