import 'package:flutter/material.dart';
import 'package:carex/Caregiver/notification/notification.dart';

// การแยก Widget Page ออกมาต่างหากเพื่อให้อ่านง่ายขึ้น
class ElderlyDetailPage extends StatelessWidget {
  final ElderlyMatchData data;

  const ElderlyDetailPage({super.key, required this.data});

  Widget _buildBox(String text, {Widget? trailing}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAFF),
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
      backgroundColor: const Color(0xFFFDF0E8),
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
                  color: Color(0xFFFCFAFF),
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
