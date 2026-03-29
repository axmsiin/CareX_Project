import 'package:flutter/material.dart';
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
        // ถ้ามี clientId จาก login แล้ว ไม่ต้องสร้างใหม่
        if (clientId != null && clientId.isNotEmpty) {
          await AppSession.saveClientId(clientId);
        } else {
          // สร้าง client profile ใหม่
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
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0E8),
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
                    color: Color(0xFFFCFAFF),
                  ),
                  alignment: Alignment.center,
                  child: const Text("LOGO"),
                ),
              ),
              const SizedBox(height: 80),
              GestureDetector(
                onTap: isLoading ? null : () => _registerAndProceed('client'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: selectedRole == "client"
                        ? const Color(0xFFEE711E)
                        : const Color(0xFFFCFAFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isLoading && selectedRole == 'client'
                        ? 'กำลังดำเนินการ...'
                        : 'ผู้ใช้',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap:
                    isLoading ? null : () => _registerAndProceed('caregiver'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: selectedRole == "caregiver"
                        ? const Color(0xFFEE711E)
                        : const Color(0xFFFCFAFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isLoading && selectedRole == 'caregiver'
                        ? 'กำลังดำเนินการ...'
                        : 'ผู้ดูแล',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8B8E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "ย้อนกลับ",
                    style: TextStyle(color: Color(0xFF564444)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
