class ProfileResult {
  final bool success;
  final String message;
  final String? caregiverId;
  final String? clientId;
  final String? elderlyId;

  ProfileResult({
    required this.success,
    required this.message,
    this.caregiverId,
    this.clientId,
    this.elderlyId,
  });

  factory ProfileResult.fromJson(Map<String, dynamic> json) {
    return ProfileResult(
      success: json['success'] == true,
      message: json['message']?.toString() ?? 'บันทึกข้อมูลสำเร็จ',
      caregiverId: json['caregiver_id']?.toString(),
      clientId: json['client_id']?.toString(),
      elderlyId: json['elderly_id']?.toString(),
    );
  }

  factory ProfileResult.success([String message = 'บันทึกข้อมูลสำเร็จ']) {
    return ProfileResult(success: true, message: message);
  }

  factory ProfileResult.failure(String message) {
    return ProfileResult(success: false, message: message);
  }
}