import 'package:flutter/material.dart';
import 'package:carex/role/selectRole.dart';
import 'package:carex/authentication/login.dart';
import 'package:carex/User/Profile/userStore.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? nameError;
  String? phoneError;

  void register() {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();

    setState(() {
      nameError = null;
      phoneError = null;
    });

    bool isValid = true;

    if (name.isEmpty) {
      nameError = "กรุณากรอกชื่อ - นามสกุล";
      isValid = false;
    }

    if (phone.isEmpty) {
      phoneError = "กรุณากรอกเบอร์โทรศัพท์";
      isValid = false;
    } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      phoneError = "เบอร์โทรศัพท์ต้องเป็นตัวเลขเท่านั้น";
      isValid = false;
    } else if (phone.length != 10) {
      phoneError = "กรุณากรอกเบอร์โทรศัพท์ให้ครบ 10 หลัก";
      isValid = false;
    }

    setState(() {});

    if (!isValid) return;

    UserStore.currentUser.fullName = name;
    UserStore.currentUser.phone = phone;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("ลงทะเบียน: $name")));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => selectrole(
          fullName: name,
          phone: phone,
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCE3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD5E7FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "LOGO",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF564444),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "ชื่อ - นามสกุล",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF564444),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  onChanged: (value) {
                    if (nameError != null) {
                      setState(() {
                        nameError = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "ชื่อ - นามสกุล",
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF564444),
                    ),
                    errorText: nameError,
                    filled: true,
                    fillColor: const Color(0xFFD5E7FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFF04444)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFF04444),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "เบอร์โทรศัพท์",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF564444),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    if (phoneError != null) {
                      setState(() {
                        phoneError = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "เบอร์โทรศัพท์",
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF564444),
                    ),
                    errorText: phoneError,
                    filled: true,
                    fillColor: const Color(0xFFD5E7FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFF04444)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFF04444),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8FBFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "ลงทะเบียน",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF564444),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: const [
                    Expanded(child: Divider(color: Color(0xFF564444))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "หรือ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF564444),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFF564444))),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8FBFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "เข้าสู่ระบบ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF564444),
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
