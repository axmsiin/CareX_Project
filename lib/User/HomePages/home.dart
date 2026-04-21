import 'package:carex/User/HomePages/addProfileElderly_one.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/User/HomePages/elderlyStore.dart';
import 'package:carex/User/HomePages/profileElderly.dart';
import 'package:carex/User/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carex/User/Profile/profileUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carex/widgets/privacy_consent_dialog.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  String selectedFilter = 'ข้อมูลทั้งหมด';
  bool isLoading = true;
  bool _isShowingConsentDialog = false;

  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const Color kMatched = Color(0xFF35CC2D);
  static const Color kMatching = Color(0xFFE4B700);
  static const Color kFailed = Color(0xFFE95257);
  static const String kFont = 'Sarabun';

  final List<String> filterItems = const [
    'ข้อมูลทั้งหมด',
    'มีผู้ดูแลแล้ว',
    'อยู่ระหว่างการจับคู่',
    'จับคู่ไม่สำเร็จ',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowConsentDialog();
    });
  }

  Future<void> _checkAndShowConsentDialog() async {
    if (_isShowingConsentDialog) return;

    final prefs = await SharedPreferences.getInstance();
    final hasAccepted = prefs.getBool('user_privacy_accepted') ?? false;

    if (hasAccepted || !mounted) return;

    _isShowingConsentDialog = true;

    final accepted = await showPrivacyConsentDialog(context);

    if (!mounted) return;

    if (accepted == true) {
      await prefs.setBool('user_privacy_accepted', true);
    } else {
      Navigator.pop(context);
    }

    _isShowingConsentDialog = false;
  }

  Future<void> _loadData() async {
    await ElderlyStore.syncFromBackend();
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> goToAddElderlyPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const addProfileElderly_one()),
    );
    await _loadData();
  }

  Future<void> goToNotificationPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const notification()),
    );
    await _loadData();
  }

  Future<void> goToProfilePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const profileUser()),
    );
    await _loadData();
  }

  String getStatusText(ElderlyData elderly) {
    final status = elderly.status.trim().toLowerCase();
    switch (status) {
      case 'matched':
        return 'มีผู้ดูแลแล้ว';
      case 'matching':
      case 'pending':
      case 'waiting_confirm':
      case 'รอการจับคู่':
        return 'อยู่ระหว่างการจับคู่';
      case 'failed':
      case 'match_failed':
      case 'caregiver_rejected':
      case 'user_rejected':
        return 'จับคู่ไม่สำเร็จ';
      default:
        return 'อยู่ระหว่างการจับคู่';
    }
  }

  String getCaregiverDisplayText(ElderlyData elderly) {
    final status = elderly.status.trim().toLowerCase();
    if (status == 'matched') {
      return elderly.caregiver.isEmpty ? '-' : elderly.caregiver;
    }
    if (status == 'failed' || status == 'match_failed') {
      return 'จับคู่ไม่สำเร็จ';
    }
    return 'อยู่ระหว่างการจับคู่';
  }

  Color getStatusColor(ElderlyData elderly) {
    final status = getStatusText(elderly);
    if (status == 'มีผู้ดูแลแล้ว') return kMatched;
    if (status == 'จับคู่ไม่สำเร็จ') return kFailed;
    return kMatching;
  }

  List<ElderlyData> getFilteredList(List<ElderlyData> list) {
    if (selectedFilter == 'ข้อมูลทั้งหมด') {
      return list;
    }
    return list.where((e) => getStatusText(e) == selectedFilter).toList();
  }

  Widget buildFilterDropdown() {
    return Container(
      width: 170,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimary, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFilter,
          icon: const Icon(Icons.keyboard_arrow_down, color: kPrimary),
          dropdownColor: kFieldFill,
          style: const TextStyle(
            fontSize: 14,
            color: kText,
            fontFamily: kFont,
          ),
          items: filterItems.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  color: kText,
                  fontFamily: kFont,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              selectedFilter = value;
            });
          },
        ),
      ),
    );
  }

  Widget buildElderlyCard(ElderlyData elderly, int index) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                profileElderly(elderlyData: elderly, elderlyIndex: index),
          ),
        );
        setState(() {});
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kFieldFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kPrimary, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '*${getStatusText(elderly)}',
                      style: TextStyle(
                        color: getStatusColor(elderly),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: kFont,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    elderly.nickName.isEmpty ? '-' : elderly.nickName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: kText,
                      fontFamily: kFont,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ดูแลโดย : ${getCaregiverDisplayText(elderly)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: kText,
                      fontFamily: kFont,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return const Column(
      children: [
        SizedBox(height: 80),
        Center(
          child: Icon(
            Icons.account_circle_outlined,
            size: 170,
            color: kPrimary,
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            "ไม่มีข้อมูล",
            style: TextStyle(
              fontSize: 16,
              color: kText,
              fontFamily: kFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAddButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: goToAddElderlyPage,
        icon: const Icon(Icons.add, color: kWhite, size: 30),
        label: const Text(
          "เพิ่มข้อมูลผู้สูงอายุ",
          style: TextStyle(
            color: kWhite,
            fontSize: 16,
            fontFamily: kFont,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget buildBottomBar() {
    return Container(
      height: 95,
      decoration: const BoxDecoration(
        color: kBottomBar,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.home,
              size: 40,
              color: kBackground,
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
          IconButton(
            onPressed: goToProfilePage,
            icon: const Icon(
              Icons.account_circle,
              size: 44,
              color: kPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ElderlyData> elderlyList = ElderlyStore.elderlyList;
    final filteredList = getFilteredList(elderlyList);

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
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 35),
                      const Text(
                        "ข้อมูลผู้สูงอายุ",
                        style: TextStyle(
                          fontSize: 16,
                          color: kText,
                          fontFamily: kFont,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      buildFilterDropdown(),
                      const SizedBox(height: 20),
                      if (filteredList.isEmpty) ...[
                        buildEmptyState(),
                      ] else ...[
                        Expanded(
                          child: ListView.separated(
                            itemCount: filteredList.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final elderly = filteredList[index];
                              final realIndex = elderlyList.indexOf(elderly);
                              return buildElderlyCard(elderly, realIndex);
                            },
                          ),
                        ),
                      ],
                      if (filteredList.isEmpty) const Spacer(),
                      buildAddButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ),
        bottomNavigationBar: buildBottomBar(),
      ),
    );
  }
}
