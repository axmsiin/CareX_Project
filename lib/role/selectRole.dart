import 'package:flutter/material.dart';
import 'package:carex/Caregiver/Profile_Caregiver/profileCaregiver_one.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/User/HomePages/home.dart';
import 'package:carex/controllers/auth_controller.dart';
import 'package:carex/services/app_session.dart';

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

  Future<void> _registerToBackend(String role) async {
    if (isLoading) return;

    setState(() {
      selectedRole = role;
      isLoading = true;
    });

    try {
      final result = await AuthController.registerUser(
        phone: widget.phone,
        role: role,
        firebaseUid: widget.firebaseUid,
        userName: widget.fullName,
      );

      if (!result.success) {
        throw Exception(result.message);
      }

      await AppSession.saveUserSession(
        userId: result.userId,
        role: result.role ?? role,
        phone: AuthController.normalizePhone(widget.phone),
        userName: result.userName ?? widget.fullName,
        firebaseUid: widget.firebaseUid,
        token: result.token,
      );
      await AppSession.clearPendingRegistration();

      if (!mounted) return;

      if (role == 'client') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const home(),
          ),
        );
      } else {
        final profile = caregiverData(
          fullName: widget.fullName,
          phone: AuthController.normalizePhone(widget.phone),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => profilecaregiver_one(
              profile: profile,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0D8),
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
                    color: Color(0xFFD9E6FA),
                  ),
                  alignment: Alignment.center,
                  child: const Text("LOGO"),
                ),
              ),
              const SizedBox(height: 80),
              GestureDetector(
                onTap: () => _registerToBackend('client'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: selectedRole == "client"
                        ? const Color(0xFF8FBFFF)
                        : const Color(0xFFD5E7FF),
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
                onTap: () => _registerToBackend('caregiver'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: selectedRole == "caregiver"
                        ? const Color(0xFF8FBFFF)
                        : const Color(0xFFD5E7FF),
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
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
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
