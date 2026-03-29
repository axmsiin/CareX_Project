class UserData {
  String fullName;
  String phone;
  String? clientId;

  UserData({
    required this.fullName,
    required this.phone,
    this.clientId,
  });

  factory UserData.empty() {
    return UserData(
      fullName: '',
      phone: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      if (clientId != null) 'client_id': clientId,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      fullName: json['fullName']?.toString() ?? json['fullname']?.toString() ?? json['user_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['tel']?.toString() ?? '',
      clientId: json['client_id']?.toString(),
    );
  }
}
