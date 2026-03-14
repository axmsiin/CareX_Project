class UserData {
  String fullName;
  String phone;

  UserData({
    required this.fullName,
    required this.phone,
  });

  factory UserData.empty() {
    return UserData(
      fullName: '',
      phone: '',
    );
  }
}
