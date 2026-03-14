import 'package:carex/Caregiver/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/profileCaregiver.dart';

class Home extends StatelessWidget {
  final caregiverData profile;

  const Home({super.key, required this.profile});

  static const bool testHasMatch = true;

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

  Widget _buildMatchedCard(BuildContext context, ElderlyMatchData data) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ElderlyDetailPage(data: data),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFD5E7FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                data.fullName,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF564444),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 30,
              color: Color(0xFF564444),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ElderlyMatchData? data = confirmedElderly;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCE3),
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
                    color: Color(0xFFD5E7FF),
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
                _buildMatchedCard(context, data),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 85,
        decoration: const BoxDecoration(
          color: Color(0xFFD5E7FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home, size: 34, color: Color(0xFF003F91)),
            ),
            IconButton(
              onPressed: () => _goToNotification(context),
              icon: const Icon(
                Icons.notifications,
                size: 38,
                color: Color(0xFF8FBFFF),
              ),
            ),
            IconButton(
              onPressed: () => _goToProfile(context),
              icon: const Icon(
                Icons.account_circle,
                size: 42,
                color: Color(0xFF8FBFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ElderlyDetailPage extends StatelessWidget {
  final ElderlyMatchData data;

  const ElderlyDetailPage({super.key, required this.data});

  Widget _buildBox(String text, {Widget? trailing}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD5E7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF564444),
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCE3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Color(0xFF564444),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'ข้อมูลผู้สูงอายุที่ดูแล',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF564444),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Icon(
                  Icons.account_circle_outlined,
                  size: 90,
                  color: Color(0xFFD5E7FF),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'ข้อมูลสุขภาพพื้นฐาน',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF564444),
                ),
              ),
              const SizedBox(height: 12),
              _buildBox(data.fullName),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildBox(data.phone)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildBox(data.birthDateText)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildBox(
                      data.gender,
                      trailing: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF564444),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildBox('น้ำหนัก : ${data.weightText}'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildBox(
                data.chronicDiseaseText,
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF564444),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'ที่อยู่',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF564444),
                ),
              ),
              const SizedBox(height: 10),
              _buildBox(data.address),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                height: 98,
                alignment: Alignment.center,
                color: const Color(0xFFEBEBEB),
                child: const Text(
                  'แผนที่',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF564444),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'วันและเวลาที่จะรับบริการ',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF564444),
                ),
              ),
              const SizedBox(height: 10),
              _buildBox(data.serviceDateText),
              const SizedBox(height: 10),
              _buildBox(data.serviceTimeText),
              const SizedBox(height: 18),
              const Text(
                'ราคาค่าจ้าง',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF564444),
                ),
              ),
              const SizedBox(height: 10),
              _buildBox(data.wageText),
              const SizedBox(height: 18),
              const Text(
                'ความต้องการในการดูแล',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF564444),
                ),
              ),
              const SizedBox(height: 10),
              ...data.careNeeds.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildBox(item),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
