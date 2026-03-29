import 'package:flutter/material.dart';
import 'package:carex/User/Profile/userStore.dart';
import 'package:carex/User/Profile/userData.dart';
import 'package:carex/services/backend_data_service.dart';

class editProfileUser extends StatefulWidget {
  const editProfileUser({super.key});

  @override
  State<editProfileUser> createState() => _EditProfileUserState();
}

class _EditProfileUserState extends State<editProfileUser> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  String? nameError;
  String? phoneError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: UserStore.currentUser.fullName);
    phoneController = TextEditingController(text: UserStore.currentUser.phone);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Widget buildBox({required Widget child, bool hasError = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAFF),
        borderRadius: BorderRadius.circular(12),
        border: hasError ? Border.all(color: const Color(0xFFF04444)) : null,
      ),
      child: child,
    );
  }

  Widget buildError(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 4),
      child: Text(error, style: const TextStyle(color: Color(0xFFF04444), fontSize: 12)),
    );
  }

  Future<void> saveProfile() async {
    setState(() {
      nameError = null;
      phoneError = null;
    });
    var isValid = true;
    if (nameController.text.trim().isEmpty) {
      nameError = 'กรุณากรอกชื่อ-นามสกุล';
      isValid = false;
    }
    if (phoneController.text.trim().isEmpty) {
      phoneError = 'กรุณากรอกเบอร์โทรศัพท์';
      isValid = false;
    }
    setState(() {});
    if (!isValid) return;
    final updated = UserData(fullName: nameController.text.trim(), phone: phoneController.text.trim());
    final ok = await BackendDataService.updateUserProfile(updated);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อัปเดตข้อมูลผู้ใช้ลงฐานข้อมูลไม่สำเร็จ')),
      );
      return;
    }
    await UserStore.syncFromBackend();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF564444), size: 18),
                label: const Text('ข้อมูลผู้ใช้', style: TextStyle(color: Color(0xFF564444), fontSize: 15)),
              ),
              const SizedBox(height: 10),
              const Center(child: Icon(Icons.account_circle_outlined, size: 110, color: Color(0xFFFCFAFF))),
              const SizedBox(height: 30),
              const Text('ข้อมูลส่วนตัว', style: TextStyle(fontSize: 16, color: Color(0xFF564444))),
              const SizedBox(height: 14),
              buildBox(hasError: nameError != null, child: TextField(controller: nameController, decoration: const InputDecoration.collapsed(hintText: 'ชื่อ-นามสกุล'))),
              buildError(nameError),
              const SizedBox(height: 12),
              buildBox(hasError: phoneError != null, child: TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration.collapsed(hintText: 'เบอร์โทรศัพท์'))),
              buildError(phoneError),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: const Color(0xFFEE711E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  child: const Text('บันทึก', style: TextStyle(color: Color(0xFF564444))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
