class RegisterRequest {
  final String phone;
  final String role;
  final String firebaseUid;
  final String userName;

  RegisterRequest({
    required this.phone,
    required this.role,
    required this.firebaseUid,
    required this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'role': role,
      'firebase_uid': firebaseUid,
      'user_name': userName,
    };
  }
}
