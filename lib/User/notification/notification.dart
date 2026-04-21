import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carex/User/HomePages/elderlyStore.dart';
import 'package:carex/User/HomePages/home.dart';
import 'package:carex/User/Profile/profileUser.dart';
import 'package:carex/services/app_session.dart';
import 'package:carex/services/backend_data_service.dart';

class notification extends StatefulWidget {
  const notification({super.key});

  @override
  State<notification> createState() => _NotificationState();
}

class _NotificationState extends State<notification> {
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const Color kGreen = Color(0xFF35CC2D);
  static const Color kRed = Color(0xFFE95257);
  static const String kFont = 'Sarabun';

  // เก็บรายการผู้ดูแลแยกตาม ID ของผู้สูงอายุ
  Map<String, List<Map<String, dynamic>>> matchesPerElderly = {};
  bool isLoadingMatches = false;
  final List<String> rejectedCaregiverIds = [];

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches({bool shouldSync = true}) async {
    if (!mounted) return;
    setState(() {
      isLoadingMatches = true;
      matchesPerElderly.clear();
    });

    if (shouldSync) {
      print('DEBUG: [Notification] Syncing from backend...');
      await ElderlyStore.syncFromBackend();
    } else {
      print('DEBUG: [Notification] Skipping sync to preserve local status.');
    }
    
    final pIndexes = pendingIndexes;
    print('DEBUG: [Notification] Found ${pIndexes.length} pending elderly profiles.');

    for (int idx in pIndexes) {
      final elderly = ElderlyStore.elderlyList[idx];
      final String? eId = elderly.elderlyId;
      
      if (eId == null || eId.isEmpty) continue;

      // ถ้าคนนี้กดยืนยันไปแล้วในเซสชันนี้ ให้ข้ามการโหลด matches
      if (ElderlyStore.isConfirmed(eId)) continue;

      print('DEBUG: [Notification] Loading matches for: ${elderly.nickName} ($eId)');
      final matches = await BackendDataService.fetchMatchSuggestions(eId);
      print('DEBUG: [Notification] Matches for ${elderly.nickName}: ${matches.length}');

      matchesPerElderly[eId] = matches;

      // อัปเดต status เป็น matching ถ้ามีผลลัพธ์
      if (matches.isNotEmpty && (elderly.status.isEmpty || elderly.status.trim().toLowerCase() == 'no_match')) {
        elderly.status = 'matching';
      }
    }

    if (!mounted) return;
    setState(() {
      isLoadingMatches = false;
    });
  }

  List<int> get pendingIndexes {
    final indexes = <int>[];
    for (int i = 0; i < ElderlyStore.elderlyList.length; i++) {
      final item = ElderlyStore.elderlyList[i];
      final s = item.status.trim().toLowerCase();
      final String eId = item.elderlyId ?? '';

      // ถ้าเลือกผู้ดูแลไปแล้ว (จดจำในเครื่อง หรือ Backend ยืนยัน) ไม่ต้องแสดงในส่วน Matching
      if (ElderlyStore.isConfirmed(eId)) continue;

      // เฉพาะสถานะที่ยังไม่ได้เลือกผู้ดูแลเท่านั้นที่แสดงในส่วน Matching
      // เอา 'pending' และ 'waiting_confirm' ออก เพื่อไม่ให้แสดงซ้ำเมื่อเลือกไปแล้ว
      if (s == 'matching' || s == 'รอการจับคู่' || s == 'no_match' || s == '') {
        indexes.add(i);
      }
    }
    return indexes;
  }

  List<int> get resultIndexes {
    final indexes = <int>[];
    for (int i = 0; i < ElderlyStore.elderlyList.length; i++) {
      final item = ElderlyStore.elderlyList[i];
      final s = item.status.trim().toLowerCase();
      final String eId = item.elderlyId ?? '';

      // ถ้าเลือกไปแล้วในเซสชันนี้ หรือ Backend บอกว่าเป็นสถานะรอการตอบรับ
      if (ElderlyStore.isConfirmed(eId) || 
          s == 'waiting_confirm' || 
          s == 'pending' || 
          s == 'matched' || 
          s == 'match_failed' || 
          s == 'caregiver_rejected' || 
          s == 'user_rejected' || 
          s == 'confirmed' || 
          s == 'rejected') {
        if (!indexes.contains(i)) indexes.add(i);
      }
    }
    return indexes;
  }

  int? get currentPendingElderlyIndex {
    if (pendingIndexes.isEmpty) return null;
    return pendingIndexes.first;
  }

  String showStatusText(String status) {
    switch (status) {
      case 'matching':
      case 'รอการจับคู่':
        return 'อยู่ระหว่างการจับคู่';
      case 'waiting_confirm':
        return 'รอการตอบรับจากผู้ดูแล';
      case 'no_match':
        return 'ยังไม่พบผู้ดูแลที่เหมาะสม';
      case 'matched':
        return 'มีผู้ดูแลแล้ว';
      case 'match_failed':
      case 'caregiver_rejected':
      case 'user_rejected':
        return 'จับคู่ไม่สำเร็จ';
      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'matched':
        return kGreen;
      case 'match_failed':
      case 'caregiver_rejected':
      case 'user_rejected':
        return kRed;
      case 'waiting_confirm':
      case 'matching':
      case 'รอการจับคู่':
        return const Color(0xFFE4B700);
      default:
        return kText;
    }
  }

  List<Map<String, dynamic>> getFilteredMatches(String elderlyId) {
    final rawMatches = matchesPerElderly[elderlyId] ?? [];
    final list = rawMatches.where((c) {
      final id = (c['caregiverId'] as String? ?? '');
      return !rejectedCaregiverIds.contains(id);
    }).toList();

    list.sort((a, b) => (b['matchPercent'] as int).compareTo(a['matchPercent'] as int));
    return list.take(5).toList();
  }

  Future<void> confirmCandidate(String elderlyId, int candidateIndex) async {
    final elderly = ElderlyStore.elderlyList.firstWhere((e) => e.elderlyId == elderlyId);
    final candidate = getFilteredMatches(elderlyId)[candidateIndex];

    // ใช้ raw ID โดยตรง (ห้าม trim) เพื่อให้ตรงกับข้อมูลใน DB ของ backend ที่อาจมีช่องว่าง
    final String cId = (candidate['caregiverId'] as String? ?? '');

    print('DEBUG: [Confirm] Sending selection to backend -> Elderly: $elderlyId, Caregiver: "$cId"');

    if (elderlyId.isEmpty || cId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ข้อมูลไม่ครบถ้วน')));
      return;
    }

    setState(() { isLoadingMatches = true; });
    final ok = await BackendDataService.selectCaregiver(elderlyId, cId);
    setState(() { isLoadingMatches = false; });

    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่สามารถยืนยันได้ กรุณาลองใหม่')));
      return;
    }

    // บันทึกสถานะการยืนยันลงใน Store กลาง
    print('DEBUG: [Confirm] Marking $elderlyId as confirmed in Store');
    ElderlyStore.markAsConfirmed(elderlyId);

    // อัปเดตสถานะเป็นรอการยืนยันทันทีใน local state
    setState(() {
      elderly.status = 'waiting_confirm';
      elderly.caregiver = candidate['name'] as String;
      elderly.matchPercent = '${candidate['matchPercent']}%';
      elderly.caregiverPhone = candidate['phone'] as String;
      elderly.caregiverGender = candidate['gender'] as String;
      elderly.caregiverAge = candidate['age'] as String;
      elderly.caregiverProvince = candidate['province'] as String;
      elderly.caregiverExperience = candidate['caregiverType'] as String;
      elderly.caregiverRating = candidate['rating'] as String;
      elderly.caregiverReviewCount = candidate['reviewCount'] as String;
      elderly.caregiverBio = candidate['bio'] as String;
    });

    await ElderlyStore.saveToCache();
    if (!mounted) return;
    
    // Show Dialog and reload WITHOUT syncing from backend
    _showSuccessDialog(elderly.nickName);
    await _loadMatches(shouldSync: false);
  }

  void _showSuccessDialog(String nickName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: kFieldFill, borderRadius: BorderRadius.circular(18), border: Border.all(color: kPrimary, width: 1.2)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: kGreen, size: 40),
              const SizedBox(height: 12),
              Text('ระบบได้บันทึกผู้ดูแลให้ $nickName แล้ว', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: kText, fontFamily: kFont)),
              const SizedBox(height: 14),
              ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: kGreen), child: const Text('ตกลง', style: TextStyle(color: kWhite))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handleRejectCandidate(String caregiverId) async {
    if (caregiverId.isNotEmpty) {
      setState(() {
        rejectedCaregiverIds.add(caregiverId);
      });
      print('DEBUG: [Reject] Caregiver ID "$caregiverId" added to session blacklist.');
    }
  }

  Future<void> rejectCurrentMatching() async {
    final elderlyIndex = currentPendingElderlyIndex;
    if (elderlyIndex == null) return;

    final elderly = ElderlyStore.elderlyList[elderlyIndex];
    elderly.status = 'match_failed';
    elderly.caregiver = 'ยังไม่มีผู้ดูแล';
    elderly.matchPercent = '';

    await ElderlyStore.saveToCache();
    await _loadMatches();

    if (mounted) {
      setState(() {});
    }
  }

  Widget buildMiniReviewCard({
    required String caregiverName,
    required String rating,
    required String reviewText,
  }) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E4DA),
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
                  fontSize: 14,
                  color: kText,
                  fontFamily: kFont,
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
                    fontSize: 14,
                    color: kText,
                    fontFamily: kFont,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: kText,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kFieldFill,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: kWhite,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          caregiverName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: kText,
                            fontFamily: kFont,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFE3B400), size: 24),
                      Icon(Icons.star, color: Color(0xFFE3B400), size: 24),
                      Icon(Icons.star, color: Color(0xFFE3B400), size: 24),
                      Icon(Icons.star, color: Color(0xFFE3B400), size: 24),
                      Icon(Icons.star, color: Color(0xFFE3B400), size: 24),
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
                        color: kText,
                        fontFamily: kFont,
                        height: 1.25,
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
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kPrimary, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ส่วน Matching Percent (มุมขวาบนสุด)
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Matching ${candidate['matchPercent']}%',
                  style: const TextStyle(
                    color: kRed,
                    fontSize: 15,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.check_circle, color: kGreen, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // 2. ส่วนข้อมูลหลัก (ไอคอน และ ข้อความ อยู่ระนาบเดียวกัน)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.shield_outlined,
                color: kPrimary,
                size: 58,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ผู้ดูแล : ${candidate['caregiverType']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: kText,
                        fontFamily: kFont,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ประสบการณ์ : ${candidate['experience']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: kText,
                        fontFamily: kFont,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFE3B400), size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${candidate['rating']} (${candidate['reviewCount']} รีวิว)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: kText,
                            fontFamily: kFont,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. ส่วนรีวิว (ListView แนวนอน)
          SizedBox(
            height: 185,
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
          const SizedBox(height: 16),

          // 4. ส่วนปุ่ม (ชิดขวา และเล็กลง)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 100,
                height: 44,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'ยืนยัน',
                    style: TextStyle(
                      fontSize: 15,
                      color: kWhite,
                      fontFamily: kFont,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                height: 44,
                child: ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kRed,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'ปฏิเสธ',
                    style: TextStyle(
                      fontSize: 15,
                      color: kWhite,
                      fontFamily: kFont,
                      fontWeight: FontWeight.w700,
                    ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimary, width: 1.2),
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
                color: kText,
                fontFamily: kFont,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return const Text(
      'ข้อมูลของผู้ดูแลที่ให้บริการ',
      style: TextStyle(
        fontSize: 16,
        color: kText,
        fontFamily: kFont,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 95,
      decoration: const BoxDecoration(
        color: kBottomBar,
        borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
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
            icon: const Icon(
              Icons.home,
              size: 40,
              color: kPrimary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications,
              size: 40,
              color: kWhite,
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
              size: 44,
              color: kPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pIndexes = pendingIndexes;
    final rIndexes = resultIndexes;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: kTopBar,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildTopHeader(),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    children: [
                      if (isLoadingMatches)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator(color: kPrimary)),
                        ),

                      if (!isLoadingMatches && pIndexes.isEmpty && rIndexes.isEmpty) ...[
                        const SizedBox(height: 140),
                        const Center(child: Icon(Icons.account_circle_outlined, size: 170, color: kPrimary)),
                        const SizedBox(height: 12),
                        const Center(child: Text('ไม่มีข้อมูล', style: TextStyle(fontSize: 16, color: kText, fontFamily: kFont, fontWeight: FontWeight.w500))),
                      ],

                      // แสดงรายการผู้ดูแลแยกตามผู้สูงอายุที่กำลัง Matching
                      ...pIndexes.map((idx) {
                        final elderly = ElderlyStore.elderlyList[idx];
                        final eId = elderly.elderlyId ?? '';
                        final matches = getFilteredMatches(eId);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'สำหรับ : คุณ${elderly.nickName}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kPrimary, fontFamily: kFont),
                              ),
                            ),
                            if (matches.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 24),
                                child: Text('ยังไม่พบผู้ดูแลที่เหมาะสม', style: TextStyle(color: kText, fontFamily: kFont)),
                              ),
                            ...List.generate(matches.length, (mIdx) {
                              return buildCandidateCard(
                                candidate: matches[mIdx],
                                rank: mIdx + 1,
                                onConfirm: () => confirmCandidate(eId, mIdx),
                                onReject: () => handleRejectCandidate(matches[mIdx]['caregiverId']),
                              );
                            }),
                          ],
                        );
                      }),

                      // แสดงรายการที่จับคู่เสร็จแล้วหรือรอยืนยัน
                      if (rIndexes.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('ผลการจับคู่ล่าสุด', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kText, fontFamily: kFont)),
                        ),
                        ...rIndexes.map((idx) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: buildResultCard(idx),
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}
