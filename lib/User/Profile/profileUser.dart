import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const String kFont = 'Sarabun';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimary, width: 1.2),
      ),
      child: Text(
        text.isEmpty ? '-' : text,
        style: const TextStyle(
          fontSize: 14,
          color: kText,
          fontFamily: kFont,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> goToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const editProfileUser()),
    );
    await _loadProfile();
  }

  Future<void> logout() async {
    await AppSession.clearSession();
    await UserStore.clear();
    await ElderlyStore.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  Widget _buildTopHeader() {
    return Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: goToEditProfile,
              child: const Text(
                'แก้ไข',
                style: TextStyle(
                  color: kText,
                  fontSize: 14,
                  fontFamily: kFont,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(width: 28),
            GestureDetector(
              onTap: logout,
              child: const Text(
                'ออกจากระบบ',
                style: TextStyle(
                  color: kText,
                  fontSize: 14,
                  fontFamily: kFont,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildProfileIcon() {
    return const Center(
      child: Icon(
        Icons.account_circle_outlined,
        size: 122,
        color: kPrimary,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 95,
      decoration: const BoxDecoration(
        color: kBottomBar,
        borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const home()),
            ),
            icon: const Icon(
              Icons.home,
              size: 40,
              color: kPrimary,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const notification()),
            ),
            icon: const Icon(
              Icons.notifications,
              size: 40,
              color: kPrimary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.account_circle,
              size: 44,
              color: kWhite,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserStore.currentUser;

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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildTopHeader(),
                      const SizedBox(height: 34),
                      _buildProfileIcon(),
                      const SizedBox(height: 34),
                      const Text(
                        'ข้อมูลส่วนตัว',
                        style: TextStyle(
                          fontSize: 16,
                          color: kText,
                          fontFamily: kFont,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildBox(user.fullName),
                      const SizedBox(height: 18),
                      buildBox(user.phone),
                    ],
                  ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}
