import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  static const String _keyUserId = 'user_id';
  static const String _keyRole = 'role';
  static const String _keyPhone = 'phone';
  static const String _keyUserName = 'user_name';
  static const String _keyFirebaseUid = 'firebase_uid';
  static const String _keyToken = 'token';
  static const String _keyClientId = 'client_id';
  static const String _keyCaregiverId = 'caregiver_id';

  static const String _keyPendingName = 'pending_name';
  static const String _keyPendingPhone = 'pending_phone';
  static const String _keyPendingFirebaseUid = 'pending_firebase_uid';

  static Future<void> saveUserSession({
    String? userId,
    required String role,
    required String phone,
    required String userName,
    required String firebaseUid,
    String? token,
    String? clientId,
    String? caregiverId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (userId != null && userId.isNotEmpty) {
      await prefs.setString(_keyUserId, userId);
    }

    if (role.isNotEmpty) {
      await prefs.setString(_keyRole, role);
    }

    await prefs.setString(_keyPhone, phone);
    await prefs.setString(_keyUserName, userName);
    await prefs.setString(_keyFirebaseUid, firebaseUid);

    if (token != null && token.isNotEmpty) {
      await prefs.setString(_keyToken, token);
    }

    if (clientId != null && clientId.isNotEmpty) {
      await prefs.setString(_keyClientId, clientId);
    }

    if (caregiverId != null && caregiverId.isNotEmpty) {
      await prefs.setString(_keyCaregiverId, caregiverId);
    }

    await clearPendingRegistration();
  }

  static Future<void> saveClientId(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyClientId, clientId);
  }

  static Future<void> saveCaregiverId(String caregiverId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCaregiverId, caregiverId);
  }

  static Future<String?> getClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyClientId);
  }

  static Future<String?> getCaregiverId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCaregiverId);
  }

  static Future<void> savePendingRegistration({
    required String name,
    required String phone,
    required String firebaseUid,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPendingName, name);
    await prefs.setString(_keyPendingPhone, phone);
    await prefs.setString(_keyPendingFirebaseUid, firebaseUid);
  }

  static Future<String?> getPendingName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPendingName);
  }

  static Future<String?> getPendingPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPendingPhone);
  }

  static Future<String?> getPendingFirebaseUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPendingFirebaseUid);
  }

  static Future<void> clearPendingRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPendingName);
    await prefs.remove(_keyPendingPhone);
    await prefs.remove(_keyPendingFirebaseUid);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  static Future<String?> getFirebaseUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFirebaseUid);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  static Future<void> updateBasicProfile({
    String? userName,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (userName != null) {
      await prefs.setString(_keyUserName, userName);
    }
    if (phone != null) {
      await prefs.setString(_keyPhone, phone);
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyFirebaseUid);
    await prefs.remove(_keyToken);
    await prefs.remove(_keyClientId);
    await prefs.remove(_keyCaregiverId);
    await clearPendingRegistration();
  }
}
