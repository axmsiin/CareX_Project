import 'package:carex/User/Profile/userData.dart';
import 'package:carex/services/backend_data_service.dart';

class UserStore {
  static UserData currentUser = UserData.empty();

  static Future<void> syncFromBackend() async {
    final profile = await BackendDataService.fetchUserProfile();
    if (profile != null) {
      currentUser = profile;
    }
  }

  static Future<void> save(UserData user) async {
    currentUser = user;
  }

  static Future<void> clear() async {
    currentUser = UserData.empty();
  }
}
