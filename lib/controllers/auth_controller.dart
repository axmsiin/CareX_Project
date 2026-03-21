import 'package:carex/models/auth_result.dart';
import 'package:carex/models/login_request.dart';
import 'package:carex/models/phone_lookup_result.dart';
import 'package:carex/models/register_request.dart';
import 'package:carex/services/auth_service.dart';

class LoginResult {
  final bool success;
  final String message;
  final int? userId;
  final String? role;
  final String? userName;
  final String? token;
  final bool isRegistered;

  LoginResult({
    required this.success,
    required this.message,
    this.userId,
    this.role,
    this.userName,
    this.token,
    this.isRegistered = true,
  });
}

class AuthController {
  static String normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (digits.startsWith('+66')) return digits;
    if (digits.startsWith('66')) return '+$digits';
    if (digits.startsWith('0') && digits.length == 10) {
      return '+66${digits.substring(1)}';
    }

    return digits;
  }

  static Future<AuthResult> registerUser({
    required String phone,
    required String role,
    required String firebaseUid,
    required String userName,
  }) async {
    final normalizedPhone = normalizePhone(phone);

    final request = RegisterRequest(
      phone: normalizedPhone,
      role: role,
      firebaseUid: firebaseUid,
      userName: userName,
    );

    final serviceResult = await AuthService.register(request);

    if (!serviceResult.success) {
      return AuthResult(
        success: false,
        message: serviceResult.message,
        userId: serviceResult.userId,
        token: serviceResult.token,
        role: serviceResult.role,
        userName: serviceResult.userName,
      );
    }

    return AuthResult(
      success: true,
      message: serviceResult.message,
      userId: serviceResult.userId,
      token: serviceResult.token,
      role: serviceResult.role ?? role,
      userName: serviceResult.userName ?? userName,
    );
  }

  static Future<LoginResult> loginUser({
    required String firebaseUid,
    String? phone,
  }) async {
    print('AuthController: loginUser called for firebaseUid=$firebaseUid phone=$phone');

    final serviceResult = await AuthService.login(
      LoginRequest(firebaseUid: firebaseUid),
    );

    print('AuthController: AuthService.login returned success=${serviceResult.success} message=${serviceResult.message} userId=${serviceResult.userId} role=${serviceResult.role}');

    if (!serviceResult.success) {
      return LoginResult(
        success: false,
        message: serviceResult.message,
        userId: serviceResult.userId,
        role: serviceResult.role,
        userName: serviceResult.userName,
        token: serviceResult.token,
        isRegistered: false,
      );
    }

    return LoginResult(
      success: true,
      message: serviceResult.message,
      userId: serviceResult.userId,
      role: serviceResult.role,
      userName: serviceResult.userName,
      token: serviceResult.token,
      isRegistered: true,
    );
  }

  static Future<PhoneLookupResult> findUserByPhone(String phone) async {
    return PhoneLookupResult.notFound();
  }
}
