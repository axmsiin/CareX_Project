import 'package:flutter/material.dart';
import 'package:carex/Caregiver/notification/notification.dart';

// การแยก Widget เพื่อให้อ่านง่ายขึ้น
class MatchCard extends StatelessWidget {
  final ElderlyMatchData matchData;
  final Duration decisionRemaining;
  final String Function(Duration) formatDuration;

  const MatchCard({
    super.key,
    required this.matchData,
    required this.decisionRemaining,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE6F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              'ยืนยันภายใน ${formatDuration(decisionRemaining)}',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF3B6EA5),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF564444),
                    height: 1.55,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ชื่อผู้สูงอายุ : ${matchData.fullName}'),
                      Text('อายุ : ${matchData.age} ปี'),
                      Text('เพศ : ${matchData.gender}'),
                      Text('จังหวัด : ${matchData.province}'),
                      Text('รายละเอียด : ${matchData.detail}'),
                      Text('โรคประจำตัว : ${matchData.disease}'),
                      Text('เวลาที่ต้องการ : ${matchData.schedule}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
