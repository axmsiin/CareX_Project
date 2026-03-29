import 'package:flutter/material.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/User/HomePages/profileElderly.dart';
import 'package:carex/controllers/user_home_controller.dart';

// การแยก Widget เพื่อให้อ่านง่ายขึ้น
class ElderlyCard extends StatelessWidget {
  final ElderlyData elderly;
  final int index;
  final VoidCallback onTap;

  const ElderlyCard({
    super.key,
    required this.elderly,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAFF),
          borderRadius: BorderRadius.circular(14),
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
                      '*${UserHomeController.getStatusText(elderly)}',
                      style: TextStyle(
                        color: UserHomeController.getStatusColor(elderly),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    elderly.nickName.isEmpty ? '-' : elderly.nickName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF564444),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ดูแลโดย : ${elderly.caregiver.isEmpty ? '-' : elderly.caregiver}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF564444),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Color(0xFF564444),
            ),
          ],
        ),
      ),
    );
  }
}
