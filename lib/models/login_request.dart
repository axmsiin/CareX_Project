class LoginRequest {
  final String firebaseUid;

  LoginRequest({
    required this.firebaseUid,
  });

  Map<String, dynamic> toJson() {
    return {
      'firebase_uid': firebaseUid,
    };
  }
}