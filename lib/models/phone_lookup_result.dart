class PhoneLookupResult {
  final bool exists;
  final int? userId;
  final String? role;
  final String? userName;
  final String? firebaseUid;
  final String? token;
  final bool profileCompleted;
  final bool fromLocal;

  const PhoneLookupResult({
    required this.exists,
    this.userId,
    this.role,
    this.userName,
    this.firebaseUid,
    this.token,
    this.profileCompleted = false,
    this.fromLocal = false,
  });

  factory PhoneLookupResult.notFound() {
    return const PhoneLookupResult(exists: false);
  }

  factory PhoneLookupResult.fromJson(Map<String, dynamic> json) {
    return PhoneLookupResult(
      exists: json['exists'] == true || json['found'] == true,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse('${json['user_id']}'),
      role: json['role']?.toString(),
      userName: json['user_name']?.toString(),
      firebaseUid: json['firebase_uid']?.toString(),
      token: json['token']?.toString(),
      profileCompleted: json['profile_completed'] == true,
      fromLocal: json['from_local'] == true,
    );
  }
}
