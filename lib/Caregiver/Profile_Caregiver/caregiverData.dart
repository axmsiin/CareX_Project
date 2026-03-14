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

  String degree;
  DateTime? graduationDate;

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
    this.degree = '',
    this.graduationDate,
  });
}