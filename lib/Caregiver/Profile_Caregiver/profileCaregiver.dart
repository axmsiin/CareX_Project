import 'package:carex/Caregiver/HomePages/home.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiver_store.dart';
import 'package:carex/Caregiver/Profile_Caregiver/editprofileCaregiver.dart';
import 'package:carex/Caregiver/notification/notification.dart';
import 'package:carex/authentication/login.dart';
import 'package:carex/services/app_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class profileCaregiver extends StatefulWidget {
  final caregiverData profile;

  const profileCaregiver({super.key, required this.profile});

  @override
  State<profileCaregiver> createState() => _ProfileCaregiverState();
}

class _ProfileCaregiverState extends State<profileCaregiver> {
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const Color kHintRed = Color(0xFFE95257);
  static const String kFont = 'Sarabun';

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

  Widget buildBox(
    String text, {
    TextAlign textAlign = TextAlign.center,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimary, width: 1.2),
      ),
      child: Text(
        text.trim().isEmpty ? '-' : text,
        textAlign: textAlign,
        style: const TextStyle(
          color: kText,
          fontSize: 14,
          fontFamily: kFont,
          fontWeight: FontWeight.w500,
          height: 1.25,
        ),
      ),
    );
  }

  Widget buildSelectedDayBox(String day) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimary, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_box, color: kPrimary, size: 24),
          const SizedBox(width: 8),
          Text(
            day,
            style: const TextStyle(
              color: kText,
              fontSize: 14,
              fontFamily: kFont,
              fontWeight: FontWeight.w500,
            ),
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
        const SnackBar(
          content: Text(
            'บันทึกข้อมูลเรียบร้อย',
            style: TextStyle(fontFamily: kFont),
          ),
        ),
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

  Widget _buildTopActions() {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: goToEditPage,
            child: const Text(
              'แก้ไข',
              style: TextStyle(
                color: kText,
                fontSize: 14,
                fontFamily: kFont,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(width: 18),
          GestureDetector(
            onTap: logout,
            child: const Text(
              'ออกจากระบบ',
              style: TextStyle(
                color: kText,
                fontSize: 14,
                fontFamily: kFont,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileIcon() {
    return const Center(
      child: Icon(
        Icons.account_circle_outlined,
        size: 112,
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
            onPressed: goToHomePage,
            icon: const Icon(
              Icons.home,
              size: 40,
              color: kPrimary,
            ),
          ),
          IconButton(
            onPressed: goToNotificationPage,
            icon: const Icon(
              Icons.notifications,
              size: 40,
              color: kPrimary,
            ),
          ),
          const Icon(
            Icons.account_circle,
            size: 44,
            color: kWhite,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final guarantor = notification.confirmedGuarantor;
    final bool hasGuarantor = guarantor != null &&
        guarantor.name.trim().isNotEmpty &&
        guarantor.phone.trim().isNotEmpty &&
        guarantor.relation.trim().isNotEmpty;

    final timeText = profile.allDayAvailable
        ? 'เวลา : สะดวกตลอดเวลา'
        : 'เวลา : ${profile.startTime} - ${profile.endTime} น.';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: kTopBar,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: kPrimary),
                )
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  color: kPrimary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopActions(),
                        const SizedBox(height: 8),
                        _buildProfileIcon(),
                        const SizedBox(height: 22),
                        const Text(
                          'ข้อมูลสุขภาพพื้นฐาน',
                          style: TextStyle(
                            fontSize: 16,
                            color: kText,
                            fontFamily: kFont,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: buildBox(profile.fullName)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: buildBox(
                                profile.nickName.isEmpty
                                    ? '-'
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
                                  buildBox(formatThaiDate(profile.birthDate)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: buildBox('น้ำหนัก : ${profile.weight}'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: buildBox('ส่วนสูง : ${profile.height}'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: buildBox(
                                profile.gender.isEmpty ? 'เพศ' : profile.gender,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'ที่อยู่',
                          style: TextStyle(
                            fontSize: 16,
                            color: kText,
                            fontFamily: kFont,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildBox(
                          profile.address,
                          textAlign: TextAlign.left,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                        if (profile.guarantorName.trim().isNotEmpty ||
                            profile.guarantorPhone.trim().isNotEmpty ||
                            profile.guarantorRelation.trim().isNotEmpty) ...[
                          const SizedBox(height: 18),
                          const Text(
                            'ผู้รับรอง',
                            style: TextStyle(
                              fontSize: 16,
                              color: kText,
                              fontFamily: kFont,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '*หากติดต่อผู้ดูแลไม่ได้ ต้องสามารถติดต่อฉุกเฉินได้',
                              style: TextStyle(
                                fontSize: 14,
                                color: kHintRed,
                                fontFamily: kFont,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          buildBox(profile.guarantorName),
                          const SizedBox(height: 10),
                          buildBox(profile.guarantorPhone),
                          const SizedBox(height: 10),
                          buildBox(profile.guarantorRelation),
                        ],
                        const SizedBox(height: 18),
                        const Text(
                          'ระยะทางที่สะดวก',
                          style: TextStyle(
                            fontSize: 16,
                            color: kText,
                            fontFamily: kFont,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildBox(
                          profile.province.isEmpty
                              ? 'จังหวัด'
                              : 'จังหวัด : ${profile.province}',
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'วันและเวลาที่สะดวก',
                          style: TextStyle(
                            fontSize: 16,
                            color: kText,
                            fontFamily: kFont,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (profile.availableDays.isEmpty)
                          buildBox('-')
                        else
                          ...profile.availableDays.map(
                            (day) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: buildSelectedDayBox(day),
                            ),
                          ),
                        buildBox(timeText),
                        const SizedBox(height: 18),
                        const Text(
                          'วุฒิประกาศนียบัตร',
                          style: TextStyle(
                            fontSize: 16,
                            color: kText,
                            fontFamily: kFont,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildBox(profile.degree),
                        const SizedBox(height: 18),
                        const Text(
                          'วันที่จบการศึกษา',
                          style: TextStyle(
                            fontSize: 16,
                            color: kText,
                            fontFamily: kFont,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildBox(formatThaiDate(profile.graduationDate)),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}
