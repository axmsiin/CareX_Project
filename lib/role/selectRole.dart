import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carex/Caregiver/Profile_Caregiver/profileCaregiver_one.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiver_store.dart';
import 'package:carex/User/HomePages/home.dart';
import 'package:carex/User/Profile/userStore.dart';
import 'package:carex/User/Profile/userData.dart';
import 'package:carex/controllers/auth_controller.dart';
import 'package:carex/services/app_session.dart';
import 'package:carex/services/auth_service.dart';

class selectRole extends StatefulWidget {
  final String fullName;
  final String phone;
  final String firebaseUid;

  const selectRole({
    super.key,
    required this.fullName,
    required this.phone,
    required this.firebaseUid,
  });

  @override
  State<selectRole> createState() => _selectRoleState();
}

class _selectRoleState extends State<selectRole> {
  String? selectedRole;
  bool isLoading = false;

  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const String kFont = 'Sarabun';

  Future<void> _registerAndProceed(String role) async {
    if (isLoading) return;

    setState(() {
      selectedRole = role;
      isLoading = true;
    });

    try {
      final registerResult = await AuthController.registerUser(
        phone: widget.phone,
        role: role,
        firebaseUid: widget.firebaseUid,
        userName: widget.fullName,
      );

      if (!registerResult.success) {
        throw Exception(registerResult.message);
      }

      final registeredUserId = registerResult.userId;
      if (registeredUserId == null || registeredUserId.isEmpty) {
        throw Exception('ระบบไม่ได้ส่ง user_id กลับมาหลังลงทะเบียน');
      }

      final loginResult = await AuthController.loginUser(
        firebaseUid: widget.firebaseUid,
        phone: AuthController.normalizePhone(widget.phone),
      );

      if (!loginResult.success) {
        throw Exception(loginResult.message);
      }

      final userId = loginResult.userId ?? registeredUserId;
      final token = loginResult.token;
      final clientId = loginResult.clientId;
      final caregiverId = loginResult.caregiverId;

      if (userId == null || userId.isEmpty) {
        throw Exception('ระบบไม่ได้ส่ง user_id กลับมาหลังเข้าสู่ระบบ');
      }

      if (token == null || token.isEmpty) {
        throw Exception('ระบบไม่ได้ส่ง token กลับมาหลังเข้าสู่ระบบ');
      }

      await AppSession.saveUserSession(
        userId: userId,
        role: role,
        phone: AuthController.normalizePhone(widget.phone),
        userName: widget.fullName,
        firebaseUid: widget.firebaseUid,
        token: token,
        clientId: clientId,
        caregiverId: caregiverId,
      );

      if (role == 'client') {
        if (clientId != null && clientId.isNotEmpty) {
          await AppSession.saveClientId(clientId);
        } else {
          final clientResult = await AuthService.createClientProfile(
            fullname: widget.fullName,
            tel: AuthController.normalizePhone(widget.phone),
            token: token,
          );

          if (!clientResult.success) {
            throw Exception(clientResult.message);
          }

          if (clientResult.clientId != null &&
              clientResult.clientId!.isNotEmpty) {
            await AppSession.saveClientId(clientResult.clientId!);
          }
        }

        await UserStore.save(
          UserData(
            fullName: widget.fullName,
            phone: AuthController.normalizePhone(widget.phone),
          ),
        );

        await AppSession.clearPendingRegistration();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const home()),
        );
      } else {
        final profile = caregiverData(
          fullName: widget.fullName,
          phone: AuthController.normalizePhone(widget.phone),
        );

        await CaregiverStore.save(profile);
        await AppSession.clearPendingRegistration();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => profilecaregiver_one(profile: profile),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kPrimary,
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(
              color: kWhite,
              fontFamily: kFont,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _roleCard({
    required String roleValue,
    required String label,
    required VoidCallback? onTap,
  }) {
    final bool isSelected = selectedRole == roleValue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 44),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : kWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: kPrimary,
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontFamily: kFont,
            fontWeight: FontWeight.w500,
            color: isSelected ? kWhite : kText,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: kTopBar,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: kPrimary,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "KareX",
                      style: TextStyle(
                        fontFamily: kFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kWhite,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                _roleCard(
                  roleValue: 'client',
                  label: isLoading && selectedRole == 'client'
                      ? 'กำลังดำเนินการ...'
                      : 'ผู้ใช้',
                  onTap: isLoading ? null : () => _registerAndProceed('client'),
                ),
                const SizedBox(height: 30),
                _roleCard(
                  roleValue: 'caregiver',
                  label: isLoading && selectedRole == 'caregiver'
                      ? 'กำลังดำเนินการ...'
                      : 'ผู้ดูแล',
                  onTap:
                      isLoading ? null : () => _registerAndProceed('caregiver'),
                ),
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text(
                        "ย้อนกลับ",
                        style: TextStyle(
                          color: kWhite,
                          fontFamily: kFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
