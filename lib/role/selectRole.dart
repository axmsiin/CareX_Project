import 'package:flutter/material.dart';
import 'package:carex/Caregiver/Profile_Caregiver/profileCaregiver_one.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/User/HomePages/home.dart';

class selectrole extends StatefulWidget {
  final String fullName;
  final String phone;

  const selectrole({
    super.key,
    required this.fullName,
    required this.phone,
  });

  @override
  State<selectrole> createState() => _selectroleState();
}

class _selectroleState extends State<selectrole> {
  String? selectedRole;

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
                onTap: () {
                  setState(() {
                    selectedRole = "user";
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const home(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: selectedRole == "user"
                        ? const Color(0xFF8FBFFF)
                        : const Color(0xFFD5E7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "ผู้ใช้",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedRole = "admin";
                  });

                  final profile = caregiverData(
                    fullName: widget.fullName,
                    phone: widget.phone,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => profilecaregiver_one(
                        profile: profile,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: selectedRole == "admin"
                        ? const Color(0xFF8FBFFF)
                        : const Color(0xFFD5E7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "ผู้ดูแล",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8B8E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("ย้อนกลับ",
                      style: TextStyle(color: Color(0xFF564444))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
