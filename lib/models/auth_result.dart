class AuthResult {
  final bool success;
  final String message;
  final int? userId;
  final String? token;
  final String? role;
  final String? userName;

  AuthResult({
    required this.success,
    required this.message,
    this.userId,
    this.token,
    this.role,
    this.userName,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      success: json['success'] == true,
      message: json['message']?.toString() ?? 'สำเร็จ',
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse('${json['user_id']}'),
      token: json['token']?.toString(),
      role: json['role']?.toString(),
      userName: json['user_name']?.toString(),
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult(
      success: false,
      message: message,
    );
  }
}
