import 'dart:async';
import 'dart:convert';

import 'package:carex/core/config/app_config.dart';
import 'package:carex/models/auth_result.dart';
import 'package:carex/models/login_request.dart';
import 'package:carex/models/register_request.dart';
import 'package:http/http.dart' as http;

class ClientProfileResult {
  final bool success;
  final String message;
  final String? clientId;

  ClientProfileResult({
    required this.success,
    required this.message,
    this.clientId,
  });
}

class AuthService {
  static Uri _uri(String path) {
    final base = AppConfig.baseUrl.endsWith('/')
        ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
        : AppConfig.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath');
  }

  static Future<AuthResult> register(RegisterRequest request) async {
    final url = _uri('/register');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          return AuthResult(
            success: true,
            message: 'สมัครสมาชิกสำเร็จ',
          );
        }

        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return AuthResult.fromJson({
            'success': true,
            ...decoded,
          });
        }

        return AuthResult(
          success: true,
          message: 'สมัครสมาชิกสำเร็จ',
        );
      }

      String errorMessage = 'สมัครสมาชิกไม่สำเร็จ';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['message'] != null) {
          errorMessage = decoded['message'].toString();
        }
      } catch (_) {}

      return AuthResult.failure(errorMessage);
    } on TimeoutException {
      return AuthResult.failure('เซิร์ฟเวอร์ตอบกลับช้าเกินไป');
    } catch (e) {
      return AuthResult.failure('เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ: $e');
    }
  }

  static Future<AuthResult> login(LoginRequest request) async {
    final url = _uri('/login');

    try {
      print(
          'AuthService: login() POST $url payload=${jsonEncode(request.toJson())}');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      print(
          'AuthService: login() response status=${response.statusCode} body=${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          return AuthResult(
            success: true,
            message: 'เข้าสู่ระบบสำเร็จ',
          );
        }

        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return AuthResult.fromJson({
            'success': true,
            ...decoded,
          });
        }

        return AuthResult(
          success: true,
          message: 'เข้าสู่ระบบสำเร็จ',
        );
      }

      String errorMessage = 'เข้าสู่ระบบไม่สำเร็จ';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['message'] != null) {
          errorMessage = decoded['message'].toString();
        }
      } catch (_) {}

      return AuthResult.failure(errorMessage);
    } on TimeoutException {
      return AuthResult.failure('เซิร์ฟเวอร์ตอบกลับช้าเกินไป');
    } catch (e) {
      return AuthResult.failure('เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ: $e');
    }
  }

  static Future<ClientProfileResult> createClientProfile({
    required String fullname,
    required String tel,
    required String token,
  }) async {
    final url = _uri('/profile/client');

    try {
      final response = await http
          .post(
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

      final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ClientProfileResult(
          success: true,
          message: decoded is Map<String, dynamic>
              ? decoded['message']?.toString() ?? 'สร้างโปรไฟล์ client สำเร็จ'
              : 'สร้างโปรไฟล์ client สำเร็จ',
          clientId: decoded is Map<String, dynamic>
              ? decoded['client_id']?.toString()
              : null,
        );
      }

      return ClientProfileResult(
        success: false,
        message: decoded is Map<String, dynamic>
            ? decoded['message']?.toString() ?? 'สร้างโปรไฟล์ client ไม่สำเร็จ'
            : 'สร้างโปรไฟล์ client ไม่สำเร็จ',
      );
    } on TimeoutException {
      return ClientProfileResult(
        success: false,
        message: 'เซิร์ฟเวอร์ตอบกลับช้าเกินไป',
      );
    } catch (e) {
      return ClientProfileResult(
        success: false,
        message: 'เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ: $e',
      );
    }
  }
}
