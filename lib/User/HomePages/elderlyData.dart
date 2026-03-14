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

  // เพิ่มส่วนนี้
  String matchPercent;
  String caregiverPhone;
  String caregiverGender;
  String caregiverAge;
  String caregiverProvince;
  String caregiverExperience;
  String caregiverRating;
  String caregiverReviewCount;
  String caregiverBio;

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

    // เพิ่มส่วนนี้
    required this.matchPercent,
    required this.caregiverPhone,
    required this.caregiverGender,
    required this.caregiverAge,
    required this.caregiverProvince,
    required this.caregiverExperience,
    required this.caregiverRating,
    required this.caregiverReviewCount,
    required this.caregiverBio,
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

      // เพิ่มส่วนนี้
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
}
