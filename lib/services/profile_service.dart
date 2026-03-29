import 'dart:async';
import 'dart:convert';

import 'package:carex/core/config/app_config.dart';
import 'package:carex/models/caregiver_profile_request.dart';
import 'package:carex/models/profile_result.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  static Uri _uri(String path) {
    final base = AppConfig.baseUrl.endsWith('/')
        ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
        : AppConfig.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath');
  }

  static Future<ProfileResult> createCaregiverProfile({
    required CaregiverProfileRequest request,
    required String token,
  }) async {
    final url = _uri('/profile/caregiver');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      print('ProfileService: POST /profile/caregiver status=${response.statusCode}');
      print('ProfileService: response body=${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          return ProfileResult.success();
        }

        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return ProfileResult.fromJson({
            'success': true,
            ...decoded,
          });
        }

        return ProfileResult.success();
      }

      String message = 'บันทึกข้อมูลไม่สำเร็จ';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}

      return ProfileResult.failure(message);
    } on TimeoutException {
      return ProfileResult.failure('เซิร์ฟเวอร์ตอบกลับช้าเกินไป');
    } catch (e) {
      return ProfileResult.failure('เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ: $e');
    }
  }

  // ตาม API v2.1: PUT /profile/caregiver/{caregiver_id}
  static Future<ProfileResult> updateCaregiverProfile({
    required String caregiverId,
    required CaregiverProfileRequest request,
    required String token,
  }) async {
    final url = _uri('/profile/caregiver/$caregiverId');

    try {
      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      print('ProfileService: PUT /profile/caregiver/$caregiverId status=${response.statusCode}');
      print('ProfileService: response body=${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.body.isNotEmpty
            ? (jsonDecode(response.body)['message']?.toString() ?? 'อัปเดตโปรไฟล์สำเร็จ')
            : 'อัปเดตโปรไฟล์สำเร็จ';
        return ProfileResult.success(message);
      }

      String message = 'อัปเดตโปรไฟล์ไม่สำเร็จ';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}

      return ProfileResult.failure(message);
    } on TimeoutException {
      return ProfileResult.failure('เซิร์ฟเวอร์ตอบกลับช้าเกินไป');
    } catch (e) {
      return ProfileResult.failure('เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ: $e');
    }
  }

  // ตาม API v2.1: PUT /profile/client
  static Future<ProfileResult> updateClientProfile({
    required String fullname,
    required String tel,
    required String token,
  }) async {
    final url = _uri('/profile/client');

    try {
      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'fullname': fullname,
              'tel': tel,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('ProfileService: PUT /profile/client status=${response.statusCode}');
      print('ProfileService: response body=${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.body.isNotEmpty
            ? (jsonDecode(response.body)['message']?.toString() ?? 'อัปเดตโปรไฟล์สำเร็จ')
            : 'อัปเดตโปรไฟล์สำเร็จ';
        return ProfileResult.success(message);
      }

      String message = 'อัปเดตโปรไฟล์ไม่สำเร็จ';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}

      return ProfileResult.failure(message);
    } on TimeoutException {
      return ProfileResult.failure('เซิร์ฟเวอร์ตอบกลับช้าเกินไป');
    } catch (e) {
      return ProfileResult.failure('เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ: $e');
    }
  }
}
