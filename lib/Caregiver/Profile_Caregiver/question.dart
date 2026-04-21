import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/profileCaregiver.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiver_store.dart';
import 'package:carex/controllers/profile_controller.dart';
import 'package:carex/models/caregiver_profile_request.dart';
import 'package:carex/services/app_session.dart';
import 'package:carex/services/backend_data_service.dart';

class question extends StatefulWidget {
  final caregiverData profile;

  const question({
    super.key,
    required this.profile,
  });

  @override
  State<question> createState() => _questionState();
}

class _questionState extends State<question> {
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const String kFont = 'Sarabun';

  List<Map<String, String>> questions = [
    {
      'question':
          'ผู้สูงอายุที่คุณดูแลปฏิเสธจะทำกิจกรรมที่กำหนดในวันนั้น และดูมีอารมณ์ไม่ดี คุณมักจะ…',
      'a':
          'หยุดก่อนและถามว่าเขารู้สึกอย่างไร\nเพื่อทำความเข้าใจสิ่ง\nที่เกิดขึ้น',
      'b': 'อธิบายสั้นๆ\nว่าทำไมกิจกรรมนี้\nจึงสำคัญ\nและค่อยๆ\nชวนให้เขาลองทำ',
    },
    {
      'question': 'แจ้งกะทันหันว่าวันนี้มีการเปลี่ยนแปลงตารางกิจวัตร คุณ…',
      'a': 'ปรับตัวได้ทันทีโดยอ่านสถานการณ์ในวันนั้นเป็นหลัก',
      'b': 'ขอรายละเอียดให้ชัดเจนก่อน เพื่อวางแผนกิจวัตรใหม่ได้อย่างรัดกุม',
    },
    {
      'question':
          'ผู้สูงอายุอยู่ในช่วงอารมณ์ดีและอยากพูดคุยกับคุณ แต่ถึงเวลาทำกิจกรรมตามแผนแล้ว คุณให้ความสำคัญกับ…',
      'a': 'ใช้เวลากับเขาในช่วงที่เขาพร้อม เพราะช่วงเวลาแบบนี้มีคุณค่า',
      'b': 'ค่อยๆ พาเขากลับมาทำกิจกรรม เพราะความสม่ำเสมอสำคัญต่อสุขภาพ',
    },
    {
      'question':
          'ครอบครัวของผู้สูงอายุขอให้คุณปฏิบัติบางอย่างที่แตกต่างจากแนวทางที่ทีมกำหนดไว้ คุณมักจะ…',
      'a': 'รับฟังเหตุผลของครอบครัวและพยายามหาทางออกที่ทุกฝ่ายยอมรับได้',
      'b': 'ชี้แจงแนวทางของทีมและแจ้งว่าต้องปรึกษาผู้รับผิดชอบก่อนดำเนินการ',
    },
    {
      'question':
          'ผู้สูงอายุแสดงอาการผิดปกติที่คุณไม่เคยเจอมาก่อน ขณะที่คุณอยู่คนเดียวกับเขา คุณจะ…',
      'a': 'ประเมินสถานการณ์และตัดสินใจด้วยวิจารณญาณของตัวเองในขณะนั้น',
      'b': 'ทำตามขั้นตอนที่ได้รับการฝึกมา',
    },
    {
      'question':
          'ผู้สูงอายุใช้เวลานานกว่าปกติมากในการทำกิจกรรมประจำวัน ส่งผลให้กิจกรรมถัดไปล่าช้า คุณมักจะ…',
      'a': 'ให้เวลาเขาทำในจังหวะของตัวเอง และยืดหยุ่นกิจกรรมถัดไปตามสถานการณ์',
      'b': 'ช่วยเร่งกระบวนการอย่างนุ่มนวล เพื่อให้กิจวัตรทั้งวันเป็นไปตามแผน',
    },
  ];

  int currentQuestionIndex = 0;
  String? selectedAnswer;
  final List<String> answers = [];
  bool isSubmitting = false;

  static const List<String> thaiMonths = [
    '',
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final apiQuestions =
        await BackendDataService.fetchQuestions('question_caregiver');
    if (apiQuestions.isEmpty || !mounted) return;

    setState(() {
      questions = apiQuestions.map((q) {
        return {
          'question': (q['question'] ?? '').trim(),
          'a': (q['a'] ?? '').trim(),
          'b': (q['b'] ?? '').trim(),
        };
      }).toList();
    });
  }

  String _formatThaiBirthday(DateTime date) {
    return '${date.day} ${thaiMonths[date.month]} ${date.year + 543}';
  }

  int _calculateScore(List<String> selectedAnswers) {
    final aCount = selectedAnswers.where((e) => e == 'A').length;
    final bCount = selectedAnswers.where((e) => e == 'B').length;
    if (aCount > bCount) return 1;
    if (bCount > aCount) return 2;
    return 3;
  }

  Future<void> nextQuestion() async {
    if (selectedAnswer == null || isSubmitting) return;

    answers.add(selectedAnswer!);

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
      });
    } else {
      showFinishDialog();
    }
  }

  void showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 48),
          child: Container(
            decoration: BoxDecoration(
              color: kFieldFill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kPrimary, width: 1.2),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),
                      const Text(
                        '*หากกดยืนยันแล้ว\nข้อมูลของคุณจะถูกใช้ในการ Matching\nให้แก่ผู้สูงอายุ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kText,
                          fontSize: 14,
                          height: 1.28,
                          fontWeight: FontWeight.w500,
                          fontFamily: kFont,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 86,
                          height: 32,
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : submitProfileAndFinish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF35CC2D),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              isSubmitting ? 'รอ...' : 'ตกลง',
                              style: const TextStyle(
                                color: kWhite,
                                fontSize: 14,
                                fontFamily: kFont,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: isSubmitting
                        ? null
                        : () {
                            Navigator.pop(dialogContext);
                          },
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.close,
                        size: 22,
                        color: Colors.black,
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

  Future<void> submitProfileAndFinish() async {
    final score = _calculateScore(answers);

    if (widget.profile.birthDate == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ไม่พบวันเกิดของผู้ดูแล กรุณากรอกข้อมูลใหม่',
            style: TextStyle(fontFamily: kFont),
          ),
        ),
      );
      return;
    }

    final token = await AppSession.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ไม่พบ token กรุณาเข้าสู่ระบบใหม่',
            style: TextStyle(fontFamily: kFont),
          ),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    widget.profile.score = score;
    await CaregiverStore.save(widget.profile);

    final request = CaregiverProfileRequest(
      fullname: widget.profile.fullName.trim(),
      alias: widget.profile.nickName.trim(),
      tel: widget.profile.phone.trim(),
      gender: widget.profile.gender.trim(),
      weight: widget.profile.weight,
      height: widget.profile.height,
      address: widget.profile.address.trim(),
      latitude: widget.profile.latitude,
      longitude: widget.profile.longitude,
      province: widget.profile.province.trim(),
      birthday: _formatThaiBirthday(widget.profile.birthDate!),
      score: score,
      timestamp: widget.profile.availableDays
          .map(
            (day) => {
              'day': day,
              'start_time': widget.profile.allDayAvailable
                  ? '00:00'
                  : widget.profile.startTime,
              'end_time': widget.profile.allDayAvailable
                  ? '00:00'
                  : widget.profile.endTime,
            },
          )
          .toList(),
      certificateType: widget.profile.degree.trim(),
      certificateDate: widget.profile.graduationDate == null
          ? ''
          : _formatThaiBirthday(widget.profile.graduationDate!),
    );

    final result = await ProfileController.createCaregiverProfile(
      request: request,
      token: token,
    );

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message,
            style: const TextStyle(fontFamily: kFont),
          ),
        ),
      );
      return;
    }

    if (result.caregiverId != null && result.caregiverId!.isNotEmpty) {
      await AppSession.saveCaregiverId(result.caregiverId!);
    }

    if (!mounted) return;
    Navigator.of(context).pop(); // ปิด dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => profileCaregiver(profile: widget.profile),
      ),
    );
  }

  Widget buildAnswerBox({
    required String label,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isSubmitting ? null : onTap,
      child: Container(
        width: 160,
        height: 168,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : kFieldFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kPrimary, width: 1.2),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 28,
                color: isSelected ? kWhite : kText,
                fontFamily: kFont,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.28,
                    color: isSelected ? kWhite : kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          IconButton(
            onPressed: isSubmitting
                ? null
                : () {
                    if (currentQuestionIndex == 0) {
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        currentQuestionIndex--;
                        if (answers.isNotEmpty) {
                          answers.removeLast();
                        }
                        selectedAnswer = null;
                      });
                    }
                  },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'ย้อนกลับ',
            style: TextStyle(
              color: kText,
              fontSize: 16,
              fontFamily: kFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
        children: const [
          Icon(Icons.home, size: 40, color: kPrimary),
          Icon(Icons.notifications, size: 40, color: kPrimary),
          Icon(Icons.account_circle, size: 44, color: kWhite),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = questions[currentQuestionIndex];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: kTopBar,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 44),
                const Text(
                  'แบบสอบถาม',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: kFieldFill,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kPrimary, width: 1.2),
                  ),
                  child: Text(
                    current['question'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: kText,
                      height: 1.28,
                      fontFamily: kFont,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildAnswerBox(
                      label: 'A',
                      text: current['a'] ?? '',
                      isSelected: selectedAnswer == 'A',
                      onTap: () {
                        setState(() {
                          selectedAnswer = 'A';
                        });
                      },
                    ),
                    buildAnswerBox(
                      label: 'B',
                      text: current['b'] ?? '',
                      isSelected: selectedAnswer == 'B',
                      onTap: () {
                        setState(() {
                          selectedAnswer = 'B';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 78,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: selectedAnswer == null || isSubmitting
                          ? null
                          : nextQuestion,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: kPrimary,
                        disabledBackgroundColor: kFieldFill,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isSubmitting
                            ? 'รอ...'
                            : currentQuestionIndex == questions.length - 1
                                ? 'เสร็จสิ้น'
                                : 'ถัดไป',
                        style: TextStyle(
                          color: selectedAnswer == null && !isSubmitting
                              ? kText
                              : kWhite,
                          fontSize: 14,
                          fontFamily: kFont,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}
