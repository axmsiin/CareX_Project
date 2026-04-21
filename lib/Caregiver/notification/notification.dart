import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carex/Caregiver/HomePages/home.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/profileCaregiver.dart';
import 'package:carex/services/backend_data_service.dart';

class ElderlyMatchData {
  final String? elderlyId;
  final String? matchId; // เพิ่ม matchId เพื่อใช้ในการ respond API
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
    this.elderlyId,
    this.matchId,
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
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const Color kGreen = Color(0xFF35CC2D);
  static const Color kRed = Color(0xFFE95257);
  static const Color kTimerRed = Color(0xFFF08A8A);
  static const String kFont = 'Sarabun';

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

  bool _isLoadingMatch = false;
  bool _hasBackendError = false; // สำหรับจัดการ Error 500
  ElderlyMatchData? _backendMatch;

  ElderlyMatchData get matchData =>
      _backendMatch ??
      widget.mockMatch ??
      const ElderlyMatchData(
        elderlyId: null,
        matchId: null,
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
    currentStep = NotificationFlowStep.empty;
    _loadPendingMatch();
  }

  Future<void> _loadPendingMatch() async {
    setState(() {
      _isLoadingMatch = true;
      _hasBackendError = false;
    });

    try {
      final matchMap = await BackendDataService.fetchPendingMatchForCaregiver();
      if (!mounted) return;

      if (matchMap != null) {
        final fetched = ElderlyMatchData(
          elderlyId: matchMap['elderlyId'],
          matchId: matchMap['matchId'],
          fullName: matchMap['fullName'] ?? '-',
          age: matchMap['age'] ?? 0,
          gender: matchMap['gender'] ?? '-',
          province: matchMap['province'] ?? '-',
          detail: matchMap['detail'] ?? '-',
          disease: matchMap['disease'] ?? '-',
          schedule: matchMap['schedule'] ?? '-',
          phone: matchMap['phone'] ?? '-',
          birthDateText: matchMap['birthDateText'] ?? '-',
          weightText: matchMap['weightText'] ?? '-',
          chronicDiseaseText: matchMap['chronicDiseaseText'] ?? '-',
          address: matchMap['address'] ?? '-',
          serviceDateText: matchMap['serviceDateText'] ?? '-',
          serviceTimeText: matchMap['serviceTimeText'] ?? '-',
          wageText: matchMap['wageText'] ?? '-',
          careNeeds: (matchMap['careNeeds'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
        );

        setState(() {
          _backendMatch = fetched;
          currentStep = NotificationFlowStep.waitingDecision;
          _isLoadingMatch = false;
        });
        _startDecisionTimer();
      } else {
        // ถ้าได้ null อาจเป็นเพราะไม่มีข้อมูล หรือ Error 500
        setState(() {
          currentStep = NotificationFlowStep.empty;
          _isLoadingMatch = false;
          // เราอาศัยการเช็ค log จาก BackendDataService ประกอบ
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMatch = false;
        _hasBackendError = true;
      });
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
        _showTimeoutDialog();
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

  List<String> _diseaseLines() {
    final raw = matchData.disease.trim();
    if (raw.isEmpty || raw == '-') return [];
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> rejectMatch() async {
    final eId = matchData.elderlyId;
    if (eId != null) {
      await BackendDataService.respondToMatch(eId, 'reject');
    }

    _decisionTimer?.cancel();
    _uploadTimer?.cancel();
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
              insetPadding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                width: 380,
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
                decoration: BoxDecoration(
                  color: kFieldFill,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: kPrimary, width: 1.2),
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
                        child: const Icon(
                          Icons.close,
                          size: 36,
                          color: kText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'อัปโหลดใบประกาศนียบัตร/วุฒิบัตร',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: kText,
                        fontFamily: kFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '*จบหลักสูตรดูแลผู้สูงอายุ(อย่างน้อย 420 ชั่วโมง) หรือมีใบอนุญาตประกอบวิชาชีพพยาบาล(PN/NA)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: kRed,
                        fontFamily: kFont,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 18),
                    InkWell(
                      onTap: () => _pickDocument(setDialogState),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0E6E0),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, color: kPrimary, size: 24),
                            const SizedBox(width: 4),
                            Text(
                              selectedDocumentName ?? 'เลือกไฟล์อัปโหลด',
                              style: const TextStyle(
                                fontSize: 14,
                                color: kText,
                                fontFamily: kFont,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 54),
                    Text(
                      'อัปโหลดภายใน ${formatUploadCountdown(uploadRemaining)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: kRed,
                        fontFamily: kFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 44),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 114,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreen,
                            disabledBackgroundColor: const Color(0xFFCFCFCF),
                            foregroundColor: kWhite,
                            elevation: 0,
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
                              fontSize: 14,
                              fontFamily: kFont,
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

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                width: 380,
                padding: const EdgeInsets.fromLTRB(26, 20, 26, 26),
                decoration: BoxDecoration(
                  color: kFieldFill,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: kPrimary, width: 1.2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          rejectMatch();
                        },
                        child: const Icon(
                          Icons.close,
                          size: 36,
                          color: kText,
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '*กรณีติดต่อฉุกเฉิน หากติดต่อผู้ดูแลไม่ได้',
                        style: TextStyle(
                          fontSize: 14,
                          color: kRed,
                          fontFamily: kFont,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ผู้รับรอง',
                        style: TextStyle(
                          fontSize: 20,
                          color: kText,
                          fontFamily: kFont,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _dialogField(
                      controller: guarantorNameController,
                      hintText: 'ชื่อผู้รับรอง',
                      errorText: guarantorNameError,
                      onChanged: (_) {
                        guarantorNameError = null;
                        refreshErrors();
                      },
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    _dialogField(
                      controller: guarantorRelationController,
                      hintText: 'ความสัมพันธ์',
                      errorText: guarantorRelationError,
                      onChanged: (_) {
                        guarantorRelationError = null;
                        refreshErrors();
                      },
                    ),
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 100,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreen,
                            foregroundColor: kWhite,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
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
                          child: const Text(
                            'ยืนยัน',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: kFont,
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
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8E2),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: errorText != null ? kRed : kPrimary,
              width: 1.2,
            ),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            cursorColor: kPrimary,
            style: const TextStyle(
              fontSize: 16,
              color: kText,
              fontFamily: kFont,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 16,
                color: kText,
                fontFamily: kFont,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                fontSize: 12,
                color: kRed,
                fontFamily: kFont,
              ),
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 50),
          child: Container(
            width: 320,
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 26),
            decoration: BoxDecoration(
              color: kFieldFill,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: kPrimary, width: 1.2),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                    onTap: _completeMatchAndGoHome,
                    child: const Icon(
                      Icons.close,
                      size: 36,
                      color: kText,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 26, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: kGreen,
                        child: Icon(Icons.check, color: Colors.white, size: 42),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'ยืนยันสำเร็จ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: kText,
                          fontFamily: kFont,
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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: kFieldFill,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kPrimary, width: 1.2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'หมดเวลา',
                  style: TextStyle(
                    fontSize: 20,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'การส่งเอกสารเกินเวลาที่กำหนด กรุณาลองใหม่อีกครั้ง',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: kText,
                    fontFamily: kFont,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 88,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _resetToEmpty();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'ตกลง',
                      style: TextStyle(
                        color: kWhite,
                        fontFamily: kFont,
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
  }

  Future<void> _completeMatchAndGoHome() async {
    final eId = matchData.elderlyId;
    if (eId == null) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }

    // 1. ส่งการตอบรับไปยัง Backend (v4)
    final ok = await BackendDataService.respondToMatch(eId, 'accept');

    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('ไม่สามารถยืนยันการจับคู่ได้ กรุณาลองใหม่')),
      );
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }

    // 2. อัปเดตข้อมูลผู้รับรองใน Profile (v4)
    final profile = widget.profile;
    profile.guarantorName = guarantorNameController.text.trim();
    profile.guarantorPhone = guarantorPhoneController.text.trim();
    profile.guarantorRelation = guarantorRelationController.text.trim();

    await BackendDataService.updateCaregiverProfile(profile);

    // 3. ปิด Dialog และไปหน้า Home
    Navigator.of(context, rootNavigator: true).pop();

    notification.confirmedGuarantor = GuarantorData(
      name: guarantorNameController.text.trim(),
      phone: guarantorPhoneController.text.trim(),
      relation: guarantorRelationController.text.trim(),
    );

    Home.confirmedElderly = matchData;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home(profile: widget.profile)),
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
    final bool showMatched = currentStep != NotificationFlowStep.empty;

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
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(width: 4),
                    const Text(
                      'ข้อมูลผู้สูงอายุที่ต้องการดูแล',
                      style: TextStyle(
                        fontSize: 16,
                        color: kText,
                        fontFamily: kFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: _isLoadingMatch
                      ? const Center(
                          child: CircularProgressIndicator(color: kPrimary),
                        )
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: showMatched
                              ? _buildMatchedState()
                              : _buildEmptyState(),
                        ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildMatchedState() {
    return Column(
      key: const ValueKey('matched'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _matchCard(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _actionButton(
              text: 'ยืนยัน',
              backgroundColor: const Color(0xFF7BCF6A),
              onPressed: acceptMatch,
            ),
            const SizedBox(width: 12),
            _actionButton(
              text: 'ปฏิเสธ',
              backgroundColor: const Color(0xFFF08A8A),
              onPressed: rejectMatch,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      key: const ValueKey('empty'),
      children: [
        const SizedBox(height: 70),
        Center(
          child: Icon(
            Icons.account_circle_outlined,
            size: 250,
            color: kPrimary,
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'ไม่มีข้อมูล',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: kFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _matchCard() {
    final diseases = _diseaseLines();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kPrimary, width: 1.2),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              'ยืนยันภายใน ${formatDuration(decisionRemaining)}',
              style: const TextStyle(
                fontSize: 16,
                color: kTimerRed,
                fontFamily: kFont,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Icon(
                  Icons.shield_outlined,
                  color: kPrimary,
                  size: 74,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 14,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                    height: 1.42,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ราคาค่าจ้าง : ${matchData.wageText}'),
                      Text('ผู้สูงอายุ : ${matchData.detail}'),
                      const Text('โรคประจำตัว :'),
                      if (diseases.isEmpty)
                        const Text('• -')
                      else
                        ...diseases.map((e) => Text('• $e')),
                      Text('วันที่ : ${matchData.serviceDateText}'),
                      Text('เวลา : ${matchData.serviceTimeText}'),
                      Text('ระยะทาง : ${matchData.province}'),
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

  Widget _actionButton({
    required String text,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 114,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: kWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: kFont,
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  Widget _buildBottomNav() {
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
            onPressed: _goToHome,
            icon: const Icon(
              Icons.home,
              size: 42,
              color: kPrimary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications,
              size: 42,
              color: kWhite,
            ),
          ),
          IconButton(
            onPressed: _goToProfile,
            icon: const Icon(
              Icons.account_circle,
              size: 46,
              color: kPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
