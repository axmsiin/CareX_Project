import 'package:flutter/material.dart';
import 'package:carex/User/Profile/userStore.dart';

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
    nameController =
        TextEditingController(text: UserStore.currentUser.fullName);
    phoneController = TextEditingController(text: UserStore.currentUser.phone);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Widget buildBox({
    required Widget child,
    bool hasError = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD5E7FF),
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
      child: Text(
        error,
        style: const TextStyle(
          color: const Color(0xFFF04444),
          fontSize: 12,
        ),
      ),
    );
  }

  void saveProfile() {
    setState(() {
      nameError = null;
      phoneError = null;
    });

    bool isValid = true;

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

    UserStore.currentUser.fullName = nameController.text.trim();
    UserStore.currentUser.phone = phoneController.text.trim();

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCE3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF564444),
                  size: 18,
                ),
                label: const Text(
                  'ข้อมูลผู้ใช้',
                  style: TextStyle(
                    color: Color(0xFF564444),
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Icon(
                  Icons.account_circle_outlined,
                  size: 110,
                  color: Color(0xFFD5E7FF),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'ข้อมูลส่วนตัว',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF564444),
                ),
              ),
              const SizedBox(height: 14),
              buildBox(
                hasError: nameError != null,
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'ชื่อ-นามสกุล',
                  ),
                ),
              ),
              buildError(nameError),
              const SizedBox(height: 12),
              buildBox(
                hasError: phoneError != null,
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'เบอร์โทรศัพท์',
                  ),
                ),
              ),
              buildError(phoneError),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF8FBFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'บันทึก',
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
