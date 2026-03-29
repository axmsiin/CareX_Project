class RegisterRequest {
  final String tel;
  final String firebaseUid;
  final String userName;

  RegisterRequest({
    required this.tel,
    required this.firebaseUid,
    required this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'tel': tel,
      'firebase_uid': firebaseUid,
      'user_name': userName,
    };
  }
}
