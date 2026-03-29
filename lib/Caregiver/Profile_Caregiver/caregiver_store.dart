import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/services/backend_data_service.dart';

class CaregiverStore {
  static caregiverData currentProfile = caregiverData();

  static Future<void> syncFromBackend() async {
    print('CaregiverStore: syncFromBackend() started');

    final profile = await BackendDataService.fetchCaregiverProfile();

    if (profile != null) {
      currentProfile = profile;
      print(
        'CaregiverStore: sync success '
        'fullName=${profile.fullName} '
        'phone=${profile.phone} '
        'caregiverId=${profile.caregiverId}',
      );
    } else {
      print('CaregiverStore: sync failed -> profile is null');
    }
  }

  static Future<void> save(caregiverData profile) async {
    currentProfile = profile;
  }

  static Future<void> clear() async {
    currentProfile = caregiverData();
  }
}
