import 'package:carex/Caregiver/notification/notification.dart';
import 'package:carex/Caregiver/HomePages/widgets/elderly_matched_card.dart';
import 'package:flutter/material.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/profileCaregiver.dart';

class Home extends StatelessWidget {
  final caregiverData profile;

  const Home({super.key, required this.profile});

  static const bool testHasMatch = false;

  static ElderlyMatchData? confirmedElderly;
  static bool pendingNotificationActive = true;

  void _goToNotification(BuildContext context) {
    final bool shouldShowPending =
        testHasMatch && pendingNotificationActive && confirmedElderly == null;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => notification(
          profile: profile,
          startWithMatch: shouldShowPending,
          mockMatch: shouldShowPending
              ? const ElderlyMatchData(
                  fullName: 'สมหมาย',
                  age: 79,
                  gender: 'เพศ',
                  province: 'กรุงเทพมหานคร',
                  detail: 'ช่วยดูแลกิจวัตรประจำวัน / เตือนกินยา',
                  disease: 'เบาหวาน, ความดันโลหิตสูง',
                  schedule: 'จ.-ศ. 08.00 - 17.00 น.',
                  phone: '0965738701',
                  birthDateText: '19 กรกฎาคม 1995',
                  weightText: '69 กก.',
                  chronicDiseaseText: 'โรคประจำตัว',
                  address:
                      '95/675 หมู่บ้านชาย ถนนสุขสวัสดิ์ แขวงบางชื่อ เขตบางชื่อ กรุงเทพมหานคร',
                  serviceDateText: 'วันที่ : 5-9 มีนาคม 2026',
                  serviceTimeText: 'เวลา : 09.00 - 18.00 น.',
                  wageText: 'วันละ : 1,500 บาท',
                  careNeeds: [
                    'กิจวัตรประจำวัน',
                    'เตือนการกินยา',
                    'การทำแผล\nแผลสด / แผลกดทับ',
                    'การเฝ้าสังเกตอาการข้างเคียง\nเหลว / ปั๊ม',
                    'การนวดแผนไทย / กายภาพเบื้องต้น',
                    'กำหนดการกินอาหาร\nอาหารอ่อน / อาหารเฉพาะโรค',
                  ],
                )
              : null,
        ),
      ),
    );
  }

  void _goToProfile(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => profileCaregiver(profile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ElderlyMatchData? data = confirmedElderly;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),
              const Text(
                "ข้อมูลผู้สูงอายุที่ดูแล",
                style: TextStyle(fontSize: 20, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 40),
              if (data == null) ...[
                const SizedBox(height: 30),
                const Center(
                  child: Icon(
                    Icons.account_circle_outlined,
                    size: 220,
                    color: Color(0xFFFCFAFF),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "ไม่มีข้อมูล",
                    style: TextStyle(fontSize: 20, color: Color(0xFF564444)),
                  ),
                ),
              ] else ...[
                ElderlyMatchedCard(data: data),
              ],
            ],
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
              onPressed: () {},
              icon: const Icon(Icons.home, size: 34, color: Color(0xFFEE711E)),
            ),
            IconButton(
              onPressed: () => _goToNotification(context),
              icon: const Icon(
                Icons.notifications,
                size: 38,
                color: Color(0xFFEE711E),
              ),
            ),
            IconButton(
              onPressed: () => _goToProfile(context),
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
