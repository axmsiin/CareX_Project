import 'package:flutter/material.dart';
import 'package:carex/Caregiver/notification/notification.dart';
import 'package:carex/Caregiver/HomePages/elderly_detail_page.dart';

// การแยก Widget เพื่อให้อ่านง่ายขึ้น
class ElderlyMatchedCard extends StatelessWidget {
  final ElderlyMatchData data;

  const ElderlyMatchedCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
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
          color: const Color(0xFFFCFAFF),
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
}
