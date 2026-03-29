import 'package:flutter/material.dart';
import 'package:carex/User/HomePages/elderlyData.dart';

// การดึง Logic ไปไว้ใน Controller ตามหลัก MVC
class UserHomeController {
  static String getStatusText(ElderlyData elderly) {
    switch (elderly.status.trim()) {
      case 'matched':
        return 'มีผู้ดูแลแล้ว';
      case 'matching':
      case 'waiting_confirm':
        return 'อยู่ระหว่างการจับคู่';
      case 'match_failed':
      case 'caregiver_rejected':
      case 'user_rejected':
        return 'จับคู่ไม่สำเร็จ';
      default:
        return elderly.status.trim().isEmpty
            ? 'อยู่ระหว่างการจับคู่'
            : elderly.status.trim();
    }
  }

  static Color getStatusColor(ElderlyData elderly) {
    switch (elderly.status.trim()) {
      case 'matched':
        return const Color(0xFF39C327);
      case 'matching':
      case 'waiting_confirm':
        return const Color(0xFFE3B400);
      case 'match_failed':
      case 'caregiver_rejected':
      case 'user_rejected':
        return const Color(0xFFFF5A5A);
      default:
        return const Color(0xFFE3B400);
    }
  }

  static List<ElderlyData> getFilteredList(
      List<ElderlyData> list, String selectedFilter) {
    switch (selectedFilter) {
      case 'มีผู้ดูแลแล้ว':
        return list.where((e) => e.status == 'matched').toList();

      case 'อยู่ระหว่างการจับคู่':
        return list
            .where(
              (e) =>
                  e.status == 'matching' ||
                  e.status == 'waiting_confirm' ||
                  e.status == 'รอการจับคู่',
            )
            .toList();

      case 'จับคู่ไม่สำเร็จ':
        return list
            .where(
              (e) =>
                  e.status == 'match_failed' ||
                  e.status == 'caregiver_rejected' ||
                  e.status == 'user_rejected',
            )
            .toList();

      case 'ข้อมูลทั้งหมด':
      default:
        return list;
    }
  }
}
