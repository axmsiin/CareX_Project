import 'package:carex/models/caregiver_profile_request.dart';
import 'package:carex/models/profile_result.dart';
import 'package:carex/services/profile_service.dart';

class ProfileController {
  static Future<ProfileResult> createCaregiverProfile({
    required CaregiverProfileRequest request,
    required String token,
  }) async {
    return await ProfileService.createCaregiverProfile(
      request: request,
      token: token,
    );
  }
}