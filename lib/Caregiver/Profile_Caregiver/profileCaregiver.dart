import 'package:carex/Caregiver/HomePages/home.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiver_store.dart';
import 'package:carex/Caregiver/Profile_Caregiver/editProfileCaregiver.dart';
import 'package:carex/Caregiver/notification/notification.dart';
import 'package:carex/authentication/login.dart';
import 'package:carex/services/app_session.dart';
import 'package:flutter/material.dart';

class profileCaregiver extends StatefulWidget {
  final caregiverData profile;

  const profileCaregiver({super.key, required this.profile});

  @override
  State<profileCaregiver> createState() => _ProfileCaregiverState();
}

class _ProfileCaregiverState extends State<profileCaregiver> {
  bool isLoading = true;
  caregiverData _profile = caregiverData();

  final List<String> thaiMonths = const [
    '',
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _loadProfile();
  }

  bool _hasMeaningfulProfileData(caregiverData profile) {
    return (profile.caregiverId != null) ||
        profile.fullName.trim().isNotEmpty ||
        profile.phone.trim().isNotEmpty ||
        profile.address.trim().isNotEmpty ||
        profile.province.trim().isNotEmpty ||
        profile.nickName.trim().isNotEmpty ||
        profile.degree.trim().isNotEmpty;
  }

  caregiverData _pickBestProfile() {
    final storeProfile = CaregiverStore.currentProfile;
    final widgetProfile = widget.profile;

    if (_hasMeaningfulProfileData(storeProfile)) {
      return storeProfile;
    }

    if (_hasMeaningfulProfileData(widgetProfile)) {
      return widgetProfile;
    }

    return storeProfile;
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      await CaregiverStore.syncFromBackend();
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _profile = _pickBestProfile();
      isLoading = false;
    });
  }

  String formatThaiDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day} ${thaiMonths[date.month]} ${date.year + 543}';
  }

  Widget buildBox(String text, {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.trim().isEmpty ? '-' : text,
        style: const TextStyle(color: Color(0xFF564444), fontSize: 14),
      ),
    );
  }

  Widget buildSelectedDayBox(String day) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_box, color: Color(0xFFEE711E)),
          const SizedBox(width: 8),
          Text(
            day,
            style: const TextStyle(color: Color(0xFF564444), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> goToEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => editprofileCaregiver(profile: _profile),
      ),
    );

    if (result == true) {
      await _loadProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')),
      );
    }
  }

  void goToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home(profile: _profile)),
    );
  }

  void goToNotificationPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            notification(profile: _profile, startWithMatch: false),
      ),
    );
  }

  Future<void> logout() async {
    await AppSession.clearSession();
    await CaregiverStore.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final timeText = profile.allDayAvailable
        ? 'เวลา : สะดวกตลอดเวลา'
        : 'เวลา : ${profile.startTime} - ${profile.endTime} น.';

    final guarantor = notification.confirmedGuarantor;
    final bool hasGuarantor = guarantor != null &&
        guarantor.name.trim().isNotEmpty &&
        guarantor.phone.trim().isNotEmpty &&
        guarantor.relation.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0E8),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: goToEditPage,
                              child: const Text(
                                'แก้ไข',
                                style: TextStyle(
                                  color: Color(0xFF564444),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: logout,
                              child: const Text(
                                'ออกจากระบบ',
                                style: TextStyle(
                                  color: Color(0xFF564444),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Icon(
                          Icons.account_circle_outlined,
                          size: 100,
                          color: Color(0xFFFCFAFF),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'ข้อมูลสุขภาพพื้นฐาน',
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFF564444)),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: buildBox(profile.fullName)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: buildBox(
                              profile.nickName.isEmpty
                                  ? 'ชื่อ : -'
                                  : profile.nickName,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: buildBox(profile.phone)),
                          const SizedBox(width: 10),
                          Expanded(
                              child:
                                  buildBox(formatThaiDate(profile.birthDate))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: buildBox(
                              profile.gender.isEmpty ? '-' : profile.gender,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: buildBox('น้ำหนัก ${profile.weight} กก.')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      buildBox('ส่วนสูง ${profile.height} ซม.'),
                      const SizedBox(height: 20),
                      const Text(
                        'ข้อมูลตารางเวลา',
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFF564444)),
                      ),
                      const SizedBox(height: 14),
                      if (profile.availableDays.isEmpty)
                        buildBox('-')
                      else
                        ...profile.availableDays.map(buildSelectedDayBox),
                      const SizedBox(height: 10),
                      buildBox(timeText),
                      const SizedBox(height: 20),
                      const Text(
                        'ที่อยู่ปัจจุบัน',
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFF564444)),
                      ),
                      const SizedBox(height: 14),
                      buildBox(profile.address),
                      const SizedBox(height: 10),
                      buildBox(profile.province),
                      const SizedBox(height: 20),
                      const Text(
                        'ข้อมูลการศึกษา/ใบรับรอง',
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFF564444)),
                      ),
                      const SizedBox(height: 14),
                      buildBox(profile.degree),
                      const SizedBox(height: 10),
                      buildBox(formatThaiDate(profile.graduationDate)),
                      const SizedBox(height: 20),
                      const Text(
                        'ข้อมูลผู้ค้ำประกัน',
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFF564444)),
                      ),
                      const SizedBox(height: 14),
                      if (hasGuarantor) ...[
                        buildBox(guarantor.name),
                        const SizedBox(height: 10),
                        buildBox(guarantor.phone),
                        const SizedBox(height: 10),
                        buildBox(guarantor.relation),
                      ] else
                        buildBox('-'),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: Container(
        height: 85,
        decoration: const BoxDecoration(
          color: Color(0xFFFCFAFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: goToHomePage,
              icon: const Icon(
                Icons.home,
                size: 38,
                color: Color(0xFFEE711E),
              ),
            ),
            IconButton(
              onPressed: goToNotificationPage,
              icon: const Icon(
                Icons.notifications,
                size: 38,
                color: Color(0xFFEE711E),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.account_circle,
                size: 42,
                color: Color(0xFFEE711E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
