import 'package:shared_preferences/shared_preferences.dart';

class LocalUserRegistryService {
  static const String _usersKey = 'local_registered_users';
  static const String _nextUserIdKey = 'local_next_user_id';
  static const String _caregiverProfilesKey = 'local_caregiver_profiles';

  static String normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+66')) return digits;
    if (digits.startsWith('66')) return '+$digits';
    if (digits.startsWith('0') && digits.length == 10) {
      return '+66${digits.substring(1)}';
    }
    return digits;
  }

  static Future<void> clearLocalRegistry() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_nextUserIdKey);
    await prefs.remove(_caregiverProfilesKey);
  }
}