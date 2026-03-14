import 'package:carex/Caregiver/HomePages/home.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/profileCaregiver.dart';
import 'package:carex/Caregiver/notification/notification.dart';
import 'package:flutter/material.dart';

class elderlyPage extends StatelessWidget {
  final caregiverData profile;
  final ElderlyMatchData elderly;
  final List<ElderlyMatchData> matchedElders;

  const elderlyPage({
    super.key,
    required this.profile,
    required this.elderly,
    required this.matchedElders,
  });

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

  void _goToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(profile: profile),
      ),
    );
  }

  void _goToNotification(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => notification(
          profile: profile,
          startWithMatch: false,
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
              _buildBox(elderly.fullName),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildBox(elderly.phone)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildBox(elderly.birthDateText)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildBox(
                      elderly.gender,
                      trailing: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF564444),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildBox('น้ำหนัก : ${elderly.weightText}'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildBox(
                elderly.chronicDiseaseText,
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
              _buildBox(elderly.address),
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
              _buildBox(elderly.serviceDateText),
              const SizedBox(height: 10),
              _buildBox(elderly.serviceTimeText),
              const SizedBox(height: 18),
              const Text(
                'ราคาค่าจ้าง',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF564444),
                ),
              ),
              const SizedBox(height: 10),
              _buildBox(elderly.wageText),
              const SizedBox(height: 18),
              const Text(
                'ความต้องการในการดูแล',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF564444),
                ),
              ),
              const SizedBox(height: 10),
              ...elderly.careNeeds.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildBox(item),
                ),
              ),
              const SizedBox(height: 30),
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
              onPressed: () => _goToHome(context),
              icon: const Icon(
                Icons.home,
                size: 38,
                color: Color(0xFF003F91),
              ),
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
