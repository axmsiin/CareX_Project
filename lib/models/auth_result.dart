class AuthResult {
  final bool success;
  final String message;
  final String? userId;
  final String? token;
  final String? role;
  final String? roleId; // เพิ่ม role_id จาก login response
  final String? userName;

  AuthResult({
    required this.success,
    required this.message,
    this.userId,
    this.token,
    this.role,
    this.roleId,
    this.userName,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      success: json['success'] == true,
      message: json['message']?.toString() ?? 'สำเร็จ',
      userId: json['user_id']?.toString(),
      token: json['token']?.toString(),
      role: json['role']?.toString(),
      roleId: json['role_id']?.toString(), // รับ role_id จาก response
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
