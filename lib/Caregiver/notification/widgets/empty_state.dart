import 'package:flutter/material.dart';

// การแยก Widget เพื่อให้อ่านง่ายขึ้น
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: ValueKey('empty'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 180,
            color: Color(0xFFFCFAFF),
          ),
          SizedBox(height: 12),
          Text(
            'ไม่มีข้อมูล',
            style: TextStyle(fontSize: 18, color: Color(0xFF564444)),
          ),
        ],
      ),
    );
  }
}
