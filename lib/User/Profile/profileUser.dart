import 'package:flutter/material.dart';
import 'package:carex/User/HomePages/home.dart';
import 'package:carex/User/notification/notification.dart';
import 'package:carex/User/Profile/userStore.dart';
import 'package:carex/User/Profile/editProfileUser.dart';
import 'package:carex/authentication/login.dart';
import 'package:carex/User/HomePages/elderlyStore.dart';
import 'package:carex/services/app_session.dart';

class profileUser extends StatefulWidget {
  const profileUser({super.key});

  @override
  State<profileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<profileUser> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await UserStore.syncFromBackend();
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Widget buildBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.isEmpty ? '-' : text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF564444)),
      ),
    );
  }

  Future<void> goToEditProfile() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const editProfileUser()));
    await _loadProfile();
  }

  Future<void> logout() async {
    await AppSession.clearSession();
    await UserStore.clear();
    await ElderlyStore.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserStore.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('ข้อมูลผู้ใช้', style: TextStyle(color: Color(0xFF564444), fontSize: 15)),
                        ),
                        TextButton(
                          onPressed: goToEditProfile,
                          child: const Text('แก้ไข', style: TextStyle(color: Color(0xFF564444), fontSize: 15, decoration: TextDecoration.underline)),
                        ),
                        TextButton(
                          onPressed: logout,
                          child: const Text('ออกจากระบบ', style: TextStyle(color: Color(0xFF564444), fontSize: 15, decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Center(child: Icon(Icons.account_circle_outlined, size: 110, color: Color(0xFFFCFAFF))),
                    const SizedBox(height: 30),
                    const Text('ข้อมูลส่วนตัว', style: TextStyle(fontSize: 16, color: Color(0xFF564444))),
                    const SizedBox(height: 14),
                    buildBox(user.fullName),
                    const SizedBox(height: 12),
                    buildBox(user.phone),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 85,
        decoration: const BoxDecoration(color: Color(0xFFFCFAFF), borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const home())),
              icon: const Icon(Icons.home, size: 38, color: Color(0xFFEE711E)),
            ),
            IconButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const notification())),
              icon: const Icon(Icons.notifications, size: 38, color: Color(0xFFEE711E)),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.account_circle, size: 42, color: Color(0xFFEE711E)),
            ),
          ],
        ),
      ),
    );
  }
}
