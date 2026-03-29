import 'package:flutter/material.dart';
import 'package:carex/User/HomePages/elderlyStore.dart';
import 'package:carex/User/HomePages/home.dart';
import 'package:carex/User/Profile/profileUser.dart';
import 'package:carex/User/Profile/profileUser.dart';

class notification extends StatefulWidget {
  const notification({super.key});

  @override
  State<notification> createState() => _NotificationState();
}

class _NotificationState extends State<notification> {
  final List<Map<String, dynamic>> mockCaregivers = const [];

  List<int> get pendingIndexes {
    final indexes = <int>[];
    for (int i = 0; i < ElderlyStore.elderlyList.length; i++) {
      final item = ElderlyStore.elderlyList[i];
      if (item.status == 'matching' || item.status == 'รอการจับคู่') {
        indexes.add(i);
      }
    }
    return indexes;
  }

  List<int> get resultIndexes {
    final indexes = <int>[];
    for (int i = 0; i < ElderlyStore.elderlyList.length; i++) {
      final item = ElderlyStore.elderlyList[i];
      if (item.status == 'matched' ||
          item.status == 'match_failed' ||
          item.status == 'caregiver_rejected') {
        indexes.add(i);
      }
    }
    return indexes;
  }

  int? get currentPendingElderlyIndex {
    if (pendingIndexes.isEmpty) return null;
    return pendingIndexes.first;
  }

  List<Map<String, dynamic>> getSortedTopMatches() {
    final list = List<Map<String, dynamic>>.from(mockCaregivers);
    list.sort(
      (a, b) => (b['matchPercent'] as int).compareTo(a['matchPercent'] as int),
    );
    return list.take(5).toList();
  }

  String showStatusText(String status) {
    switch (status) {
      case 'matching':
        return 'อยู่ระหว่างการจับคู่';
      case 'waiting_confirm':
        return 'รอการยืนยันผู้ดูแล';
      case 'matched':
        return 'มีผู้ดูแลแล้ว';
      case 'match_failed':
        return 'จับคู่ไม่สำเร็จ';
      case 'caregiver_rejected':
        return 'ผู้ดูแลปฏิเสธ';
      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'matched':
        return const Color(0xFF39C327);
      case 'match_failed':
      case 'caregiver_rejected':
        return const Color(0xFFE53935);
      case 'waiting_confirm':
      case 'matching':
        return const Color(0xFFE3B400);
      default:
        return const Color(0xFF0D47A1);
    }
  }

  Future<void> goToProfilePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const profileUser()),
    );
    setState(() {});
  }

  Future<void> confirmCandidate(int candidateIndex) async {
    final elderlyIndex = currentPendingElderlyIndex;
    if (elderlyIndex == null) return;

    final elderly = ElderlyStore.elderlyList[elderlyIndex];
    final candidate = getSortedTopMatches()[candidateIndex];

    elderly.status = 'matched';
    elderly.caregiver = candidate['name'] as String;
    elderly.matchPercent = '${candidate['matchPercent']}%';
    elderly.caregiverPhone = candidate['phone'] as String;
    elderly.caregiverGender = candidate['gender'] as String;
    elderly.caregiverAge = candidate['age'] as String;
    elderly.caregiverProvince = candidate['province'] as String;
    elderly.caregiverExperience = candidate['experience'] as String;
    elderly.caregiverRating = candidate['rating'] as String;
    elderly.caregiverReviewCount = candidate['reviewCount'] as String;
    elderly.caregiverBio = candidate['bio'] as String;
    await ElderlyStore.saveToCache();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF39C327),
                  size: 38,
                ),
                const SizedBox(height: 12),
                const Text(
                  'ยืนยันสำเร็จ',
                  style: TextStyle(fontSize: 18, color: Color(0xFF564444)),
                ),
                const SizedBox(height: 8),
                Text(
                  'ระบบได้บันทึกผู้ดูแลให้ ${elderly.nickName} แล้ว',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF564444),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF39C327),
                  ),
                  child: const Text(
                    'ตกลง',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    setState(() {});
  }

  void rejectCurrentMatching() {
    final elderlyIndex = currentPendingElderlyIndex;
    if (elderlyIndex == null) return;

    final elderly = ElderlyStore.elderlyList[elderlyIndex];
    elderly.status = 'match_failed';
    elderly.caregiver = 'ยังไม่มีผู้ดูแล';
    elderly.matchPercent = '';

    setState(() {});
  }

  Widget buildMiniReviewCard({
    required String caregiverName,
    required String rating,
    required String reviewText,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8DC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                rating,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF564444),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Color(0xFFE3B400), size: 20),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'คะแนนการบริการ',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF564444),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFF564444),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFFD9C7A1),
                        child: Text(
                          caregiverName.isNotEmpty ? caregiverName[0] : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          caregiverName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF564444),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFE3B400), size: 22),
                      Icon(Icons.star, color: Color(0xFFE3B400), size: 22),
                      Icon(Icons.star, color: Color(0xFFE3B400), size: 22),
                      Icon(Icons.star, color: Color(0xFFE3B400), size: 22),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Text(
                      reviewText,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF564444),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCandidateCard({
    required Map<String, dynamic> candidate,
    required int rank,
    required VoidCallback onConfirm,
    required VoidCallback onReject,
  }) {
    final reviews = (candidate['reviews'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF0D47A1),
                size: 34,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ผู้ดูแล : ${candidate['caregiverType']}',
                      style: const TextStyle(
                        fontSize: 17,
                        color: Color(0xFF564444),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ประสบการณ์ : ${candidate['experience']}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF564444),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Text(
                    '*Matching ${candidate['matchPercent']}%',
                    style: const TextStyle(
                      color: Color(0xFFE85B5B),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF39C327),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return buildMiniReviewCard(
                  caregiverName: candidate['name'] as String,
                  rating: candidate['rating'] as String,
                  reviewText: reviews[index],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 88,
                height: 36,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF39C327),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'ยืนยัน',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 88,
                height: 36,
                child: ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE85B5B),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'ปฏิเสธ',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildResultCard(int elderlyIndex) {
    final elderly = ElderlyStore.elderlyList[elderlyIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            elderly.status == 'matched'
                ? Icons.check_circle_outline
                : Icons.info_outline,
            color: statusColor(elderly.status),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${elderly.nickName} : ${showStatusText(elderly.status)}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF564444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topMatches = getSortedTopMatches();
    final elderlyIndex = currentPendingElderlyIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'ข้อมูลของผู้ดูแลที่ให้บริการ',
                style: TextStyle(fontSize: 20, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    if (elderlyIndex == null && resultIndexes.isEmpty) ...[
                      const SizedBox(height: 140),
                      const Center(
                        child: Icon(
                          Icons.account_circle_outlined,
                          size: 160,
                          color: Color(0xFFFCFAFF),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'ไม่มีข้อมูล',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF564444),
                          ),
                        ),
                      ),
                    ],
                    if (elderlyIndex != null) ...[
                      Text(
                        'ตัวเลือกผู้ดูแลสำหรับ : ${ElderlyStore.elderlyList[elderlyIndex].nickName}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF564444),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(topMatches.length, (index) {
                        return buildCandidateCard(
                          candidate: topMatches[index],
                          rank: index + 1,
                          onConfirm: () => confirmCandidate(index),
                          onReject: rejectCurrentMatching,
                        );
                      }),
                      const SizedBox(height: 10),
                    ],
                    ...resultIndexes.map((index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: buildResultCard(index),
                      );
                    }),
                  ],
                ),
              ),
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
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const home()),
                );
              },
              icon: const Icon(Icons.home, size: 38, color: Color(0xFF0D47A1)),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications,
                size: 38,
                color: Color(0xFFEE711E),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const profileUser()),
                );
              },
              icon: const Icon(
                Icons.account_circle,
                size: 42,
                color: Color(0xFF0D47A1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
