import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:carex/Caregiver/HomePages/home.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/profileCaregiver.dart';
import 'package:carex/Caregiver/notification/widgets/action_button.dart';
import 'package:carex/Caregiver/notification/widgets/empty_state.dart';
import 'package:carex/Caregiver/notification/widgets/match_card.dart';

class ElderlyMatchData {
  final String fullName;
  final int age;
  final String gender;
  final String province;
  final String detail;
  final String disease;
  final String schedule;

  final String phone;
  final String birthDateText;
  final String weightText;
  final String chronicDiseaseText;
  final String address;
  final String serviceDateText;
  final String serviceTimeText;
  final String wageText;
  final List<String> careNeeds;

  const ElderlyMatchData({
    required this.fullName,
    required this.age,
    required this.gender,
    required this.province,
    required this.detail,
    required this.disease,
    required this.schedule,
    required this.phone,
    required this.birthDateText,
    required this.weightText,
    required this.chronicDiseaseText,
    required this.address,
    required this.serviceDateText,
    required this.serviceTimeText,
    required this.wageText,
    required this.careNeeds,
  });
}

class GuarantorData {
  final String name;
  final String phone;
  final String relation;

  const GuarantorData({
    required this.name,
    required this.phone,
    required this.relation,
  });
}

enum NotificationFlowStep {
  empty,
  waitingDecision,
  uploadDocument,
  guarantorForm,
  completed,
}

class notification extends StatefulWidget {
  final caregiverData profile;
  final ElderlyMatchData? mockMatch;
  final bool startWithMatch;

  static GuarantorData? confirmedGuarantor;

  const notification({
    super.key,
    required this.profile,
    this.mockMatch,
    this.startWithMatch = true,
  });

  @override
  State<notification> createState() => _NotificationState();
}

class _NotificationState extends State<notification> {
  late NotificationFlowStep currentStep;
  Timer? _decisionTimer;
  Timer? _uploadTimer;

  Duration decisionRemaining = const Duration(hours: 24);
  Duration uploadRemaining = const Duration(minutes: 5);

  String? selectedDocumentName;

  final TextEditingController guarantorNameController = TextEditingController();
  final TextEditingController guarantorPhoneController =
      TextEditingController();
  final TextEditingController guarantorRelationController =
      TextEditingController();

  String? guarantorNameError;
  String? guarantorPhoneError;
  String? guarantorRelationError;

  ElderlyMatchData get matchData =>
      widget.mockMatch ??
      const ElderlyMatchData(
        fullName: '-',
        age: 0,
        gender: '-',
        province: '-',
        detail: '-',
        disease: '-',
        schedule: '-',
        phone: '-',
        birthDateText: '-',
        weightText: '-',
        chronicDiseaseText: '-',
        address: '-',
        serviceDateText: '-',
        serviceTimeText: '-',
        wageText: '-',
        careNeeds: [],
      );

  @override
  void initState() {
    super.initState();
    currentStep = widget.startWithMatch
        ? NotificationFlowStep.waitingDecision
        : NotificationFlowStep.empty;

    if (currentStep == NotificationFlowStep.waitingDecision) {
      _startDecisionTimer();
    }
  }

  @override
  void dispose() {
    _decisionTimer?.cancel();
    _uploadTimer?.cancel();
    guarantorNameController.dispose();
    guarantorPhoneController.dispose();
    guarantorRelationController.dispose();
    super.dispose();
  }

  void _startDecisionTimer() {
    _decisionTimer?.cancel();
    decisionRemaining = const Duration(hours: 24);
    _decisionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (decisionRemaining.inSeconds <= 1) {
        timer.cancel();
        Navigator.of(context, rootNavigator: true).maybePop();
        Home.pendingNotificationActive = false;
        setState(() {
          currentStep = NotificationFlowStep.empty;
          selectedDocumentName = null;
        });
        return;
      }

      setState(() {
        decisionRemaining -= const Duration(seconds: 1);
      });
    });
  }

  void _startUploadTimer() {
    _uploadTimer?.cancel();
    uploadRemaining = const Duration(minutes: 5);
    _uploadTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (uploadRemaining.inSeconds <= 1) {
        timer.cancel();
        Navigator.of(context, rootNavigator: true).maybePop();
        setState(() {
          currentStep = NotificationFlowStep.waitingDecision;
          selectedDocumentName = null;
        });
        return;
      }

      setState(() {
        uploadRemaining -= const Duration(seconds: 1);
      });
    });
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String formatUploadCountdown(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void rejectMatch() {
    _decisionTimer?.cancel();
    _uploadTimer?.cancel();
    Home.pendingNotificationActive = false;
    setState(() {
      currentStep = NotificationFlowStep.empty;
      selectedDocumentName = null;
    });
  }

  void acceptMatch() {
    setState(() {
      currentStep = NotificationFlowStep.uploadDocument;
    });
    _showUploadDialog();
  }

  Future<void> _pickDocument(StateSetter setDialogState) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedDocumentName = result.files.single.name;
      });
      setDialogState(() {});
    }
  }

  void _showUploadDialog() {
    _startUploadTimer();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 380,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFAFF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFEE711E),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          _uploadTimer?.cancel();
                          Navigator.pop(context);
                          setState(() {
                            currentStep = NotificationFlowStep.waitingDecision;
                            selectedDocumentName = null;
                          });
                        },
                        child: const Icon(Icons.close, size: 32),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'อัปโหลดใบประกาศนียบัตร/วุฒิบัตร',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        color: Color(0xFF564444),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '*ใบหลักสูตรดูแลผู้สูงอายุ(อย่างน้อย 420 ชั่วโมง) หรือเป็นอนุญาตประกอบวิชาชีพพยาบาล(PN/NA)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: const Color(0xFFF04444)),
                    ),
                    const SizedBox(height: 18),
                    InkWell(
                      onTap: () => _pickDocument(setDialogState),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCFAFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, color: Color(0xFFEE711E)),
                            const SizedBox(width: 6),
                            Text(
                              selectedDocumentName ?? 'เลือกไฟล์อัปโหลด',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF564444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'อัปโหลดภายใน ${formatUploadCountdown(uploadRemaining)}',
                      style: const TextStyle(
                          fontSize: 18, color: const Color(0xFFF04444)),
                    ),
                    const SizedBox(height: 28),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 104,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF35CC2D),
                            disabledBackgroundColor: const Color(0xFFEBEBEB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: selectedDocumentName == null
                              ? null
                              : () {
                                  _uploadTimer?.cancel();
                                  Navigator.pop(context);
                                  _showGuarantorDialog();
                                },
                          child: const Text(
                            'ถัดไป',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showGuarantorDialog() {
    setState(() {
      currentStep = NotificationFlowStep.guarantorForm;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void refreshErrors() => setDialogState(() {});

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFEE711E)),
              ),
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'กรอกข้อมูลผู้รับรองเพิ่มเติม',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF564444),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            rejectMatch();
                          },
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _dialogField(
                      controller: guarantorNameController,
                      hintText: 'ชื่อผู้รับรอง',
                      errorText: guarantorNameError,
                      onChanged: (_) {
                        guarantorNameError = null;
                        refreshErrors();
                      },
                    ),
                    const SizedBox(height: 8),
                    _dialogField(
                      controller: guarantorPhoneController,
                      hintText: 'เบอร์โทรศัพท์',
                      keyboardType: TextInputType.phone,
                      errorText: guarantorPhoneError,
                      onChanged: (_) {
                        guarantorPhoneError = null;
                        refreshErrors();
                      },
                    ),
                    const SizedBox(height: 8),
                    _dialogField(
                      controller: guarantorRelationController,
                      hintText: 'ความสัมพันธ์',
                      errorText: guarantorRelationError,
                      onChanged: (_) {
                        guarantorRelationError = null;
                        refreshErrors();
                      },
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF35CC2D),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(64, 30),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          if (_validateGuarantor()) {
                            Navigator.pop(context);
                            _showCompletedDialog();
                          } else {
                            refreshErrors();
                          }
                        },
                        child: const Text('ยืนยัน'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _validateGuarantor() {
    guarantorNameError = null;
    guarantorPhoneError = null;
    guarantorRelationError = null;

    bool valid = true;

    if (guarantorNameController.text.trim().isEmpty) {
      guarantorNameError = 'กรุณากรอกชื่อผู้รับรอง';
      valid = false;
    }

    if (guarantorPhoneController.text.trim().isEmpty) {
      guarantorPhoneError = 'กรุณากรอกเบอร์โทรศัพท์';
      valid = false;
    }

    if (guarantorRelationController.text.trim().isEmpty) {
      guarantorRelationError = 'กรุณากรอกความสัมพันธ์';
      valid = false;
    }

    return valid;
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String hintText,
    String? errorText,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFAFF),
            borderRadius: BorderRadius.circular(8),
            border: errorText != null
                ? Border.all(color: const Color(0xFFF04444))
                : null,
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              errorText,
              style:
                  const TextStyle(fontSize: 11, color: const Color(0xFFF04444)),
            ),
          ),
      ],
    );
  }

  void _showCompletedDialog() {
    setState(() {
      currentStep = NotificationFlowStep.completed;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 350,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFAFF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEE711E), width: 1.2),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Home.confirmedElderly = matchData;
                      Home.pendingNotificationActive = false;
                      notification.confirmedGuarantor = GuarantorData(
                        name: guarantorNameController.text.trim(),
                        phone: guarantorPhoneController.text.trim(),
                        relation: guarantorRelationController.text.trim(),
                      );
                      _resetToEmpty();
                    },
                    child: const Icon(Icons.close, size: 32),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 18, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFF35CC2D),
                        child: Icon(Icons.check, color: Colors.white, size: 34),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'ยืนยันสำเร็จ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF564444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('หมดเวลา'),
          content: const Text(
            'การส่งเอกสารเกินเวลาที่กำหนด ระบบจะกลับไปเป็นไม่มีข้อมูล',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetToEmpty();
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  void _resetToEmpty() {
    _decisionTimer?.cancel();
    _uploadTimer?.cancel();
    setState(() {
      currentStep = NotificationFlowStep.empty;
      selectedDocumentName = null;
      guarantorNameController.clear();
      guarantorPhoneController.clear();
      guarantorRelationController.clear();
      guarantorNameError = null;
      guarantorPhoneError = null;
      guarantorRelationError = null;
    });
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home(profile: widget.profile)),
    );
  }

  void _goToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => profileCaregiver(profile: widget.profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showMatched = currentStep != NotificationFlowStep.empty &&
        currentStep != NotificationFlowStep.completed;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Text(
                'ข้อมูลผู้สูงอายุที่ต้องการดูแล',
                style: TextStyle(fontSize: 14, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child:
                      showMatched ? _buildMatchedState() : _buildEmptyState(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMatchedState() {
    return Column(
      key: const ValueKey('matched'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MatchCard(
          matchData: matchData,
          decisionRemaining: decisionRemaining,
          formatDuration: formatDuration,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ActionButton(
              text: 'รับ',
              backgroundColor: const Color(0xFF35CC2D),
              onPressed: acceptMatch,
            ),
            const SizedBox(width: 8),
            ActionButton(
              text: 'ปฏิเสธ',
              backgroundColor: const Color(0xFFFF6B6B),
              onPressed: rejectMatch,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const EmptyState();
  }

  Widget _buildBottomNav() {
    return Container(
      height: 85,
      decoration: const BoxDecoration(
        color: Color(0xFFFCFAFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: _goToHome,
            icon: const Icon(Icons.home, size: 34, color: Color(0xFFEE711E)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications,
              size: 34,
              color: Color(0xFFEE711E),
            ),
          ),
          IconButton(
            onPressed: _goToProfile,
            icon: const Icon(
              Icons.account_circle,
              size: 38,
              color: Color(0xFFEE711E),
            ),
          ),
        ],
      ),
    );
  }
}
