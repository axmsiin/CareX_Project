class ProfileResult {
  final bool success;
  final String message;

  ProfileResult({
    required this.success,
    required this.message,
  });

  factory ProfileResult.fromJson(Map<String, dynamic> json) {
    return ProfileResult(
      success: json['success'] == true,
      message: json['message']?.toString() ?? 'บันทึกข้อมูลสำเร็จ',
    );
  }

  factory ProfileResult.success([String message = 'บันทึกข้อมูลสำเร็จ']) {
    return ProfileResult(success: true, message: message);
  }

  factory ProfileResult.failure(String message) {
    return ProfileResult(success: false, message: message);
  }
}