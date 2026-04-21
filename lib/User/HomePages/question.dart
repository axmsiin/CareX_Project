import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carex/User/HomePages/home.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/User/HomePages/elderlyStore.dart';
import 'package:carex/services/backend_data_service.dart';

class question extends StatefulWidget {
  final ElderlyData elderlyData;

  const question({super.key, required this.elderlyData});

  @override
  State<question> createState() => _questionState();
}

class _questionState extends State<question> {
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kGreen = Color(0xFF35CC2D);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kPopupText = Color(0xFFE95257);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const String kFont = 'Sarabun';

  List<Map<String, String>> questions = [
    {
      'question':
          'เมื่อผู้สูงอายุรู้สึกไม่พอใจหรืออารมณ์ไม่ดี ผู้สูงอายุมักจะ...',
      'a': 'พูดหรือแสดงให้คนรอบข้างรู้ได้เลย เช่น บ่น หรือแสดงสีหน้า',
      'b': 'เก็บเงียบไว้ ไม่พูดถึง หรืออยากอยู่เงียบๆ คนเดียว',
    },
    {
      'question':
          'เวลาลูกหลานพาไปทำกิจกรรมใหม่ที่ไม่เคยทำมาก่อน เช่น ร้านอาหารใหม่ หรือสถานที่ใหม่ ผู้สูงอายุมักจะ...',
      'a': 'ลองได้โดยไม่ติดขัด เปิดรับสิ่งใหม่ได้ตามสถานการณ์',
      'b': 'รู้สึกไม่แน่ใจหรืออยากกลับไปทำสิ่งที่คุ้นเคยมากกว่า',
    },
    {
      'question':
          'เมื่อมีคนที่ไม่รู้จักมาเยี่ยมบ้านหรือพบเจอในงานสังสรรค์ ผู้สูงอายุมักจะ...',
      'a': 'ทักทายและเริ่มพูดคุยได้เองอย่างเป็นธรรมชาติ',
      'b': 'รอให้มีคนแนะนำก่อน หรือตอบสั้นๆ ไม่เริ่มบทสนทนาเอง',
    },
    {
      'question':
          'เวลารู้สึกไม่สบายหรือไม่สดชื่น เช่น ปวด หรือเพลีย ผู้สูงอายุมักจะ...',
      'a': 'บอกลูกหลานหรือคนรอบข้างให้รู้ได้เลย',
      'b': 'ไม่บอก และพยายามจัดการหรือทนด้วยตัวเองก่อน',
    },
    {
      'question':
          'เมื่อต้องตัดสินใจเรื่องทั่วไป เช่น จะกินอะไร จะออกไปไหน ผู้สูงอายุมักจะ...',
      'a': 'ให้คนอื่นเป็นคนเลือกแทนได้ ไม่ยึดติดกับความเห็นตัวเอง',
      'b': 'มีความเห็นของตัวเองชัดเจน และมักเป็นคนตัดสินใจเอง',
    },
    {
      'question':
          'เมื่อสิ่งต่างๆ ไม่เป็นไปตามเวลาหรือแผนที่วางไว้ ผู้สูงอายุมักจะ...',
      'a': 'รับได้ ไม่แสดงความกังวลถ้าแผนเปลี่ยนหรือช้าไป',
      'b': 'รู้สึกไม่สบายใจ และมักแสดงออกเมื่อสิ่งต่างๆ ไม่เป็นไปตามที่คาดไว้',
    },
  ];

  int currentQuestionIndex = 0;
  String? selectedAnswer;
  final List<String> answers = [];
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final apiQuestions =
        await BackendDataService.fetchQuestions('question_elderly');
    if (apiQuestions.isEmpty || !mounted) return;
    setState(() {
      questions = apiQuestions;
    });
  }

  int _calculateScore(List<String> selectedAnswers) {
    final aCount = selectedAnswers.where((e) => e == 'A').length;
    final bCount = selectedAnswers.where((e) => e == 'B').length;
    if (aCount > bCount) return 1;
    if (bCount > aCount) return 2;
    return 3;
  }

  Future<void> finishAndGoHome() async {
    Navigator.of(context, rootNavigator: true).pop();

    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final score = _calculateScore(answers);
      widget.elderlyData.score = score;
      widget.elderlyData.status = 'matching';
      widget.elderlyData.caregiver = '';
      widget.elderlyData.matchPercent = '';

      final created =
          await BackendDataService.createElderlyProfile(widget.elderlyData);

      if (created == null ||
          created.elderlyId == null ||
          created.elderlyId!.isEmpty) {
        throw Exception('สร้างข้อมูลผู้สูงอายุไม่สำเร็จ');
      }

      created.score = score;
      created.status = created.status.isEmpty ? 'matching' : created.status;

      widget.elderlyData.elderlyId = created.elderlyId;
      widget.elderlyData.status = created.status;

      await BackendDataService.submitQuestionScore(
        target: 'elderly',
        score: score,
        relatedId: created.elderlyId,
        answers: answers,
      );

      // requestMatch คืน true ถ้ามี caregiver ที่ match >= 75% อย่างน้อย 1 คน
      // status 'matching' = กำลังรอผู้ดูแลยืนยัน (มีผลลัพธ์แล้ว)
      // status 'no_match'  = ยังไม่มี caregiver ที่ตรงเงื่อนไข
      final hasMatch = await BackendDataService.requestMatch(
        elderlyId: created.elderlyId!,
      );
      created.status = hasMatch ? 'matching' : 'no_match';

      await ElderlyStore.upsert(created);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const home()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'บันทึกข้อมูลไม่สำเร็จ กรุณาลองใหม่อีกครั้ง',
            style: TextStyle(fontFamily: kFont),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
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
                        '*หากกดยืนยันแล้ว\nระบบจะทำการ Matching\nข้อมูลของผู้ดูแลให้แก่ผู้สูงอายุ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kPopupText,
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
                            onPressed: isSubmitting ? null : finishAndGoHome,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kGreen,
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

  void nextQuestion() {
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
          border: Border.all(
            color: kPrimary,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? kWhite : kText,
                fontFamily: kFont,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.25,
                    color: isSelected ? kWhite : kText,
                    fontFamily: kFont,
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
              size: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'ข้อมูลผู้สูงอายุ',
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

  Widget _buildQuestionTitle() {
    return const Text(
      'แบบสอบถาม',
      style: TextStyle(
        fontSize: 16,
        color: kText,
        fontFamily: kFont,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildQuestionBox(Map<String, String> current) {
    String questionText = current['question'] ?? '';
    if (currentQuestionIndex == questions.length - 1) {
      questionText =
          'จากพฤติกรรมที่เห็นเป็นประจำ ข้อใด\nตรงกับผู้สูงอายุของคุณมากที่สุด ระหว่าง A กับ B';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: kPrimary,
          width: 1.2,
        ),
      ),
      child: Text(
        questionText,
        style: const TextStyle(
          fontSize: 14,
          color: kText,
          height: 1.28,
          fontFamily: kFont,
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 78,
        height: 36,
        child: ElevatedButton(
          onPressed:
              selectedAnswer == null || isSubmitting ? null : nextQuestion,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            disabledBackgroundColor: kFieldFill,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            isSubmitting
                ? 'รอ...'
                : currentQuestionIndex == questions.length - 1
                    ? 'ยืนยัน'
                    : 'ถัดไป',
            style: TextStyle(
              color: selectedAnswer == null || isSubmitting ? kText : kWhite,
              fontSize: 14,
              fontFamily: kFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
          Icon(Icons.home, size: 42, color: kWhite),
          Icon(Icons.notifications, size: 40, color: kPrimary),
          Icon(Icons.account_circle, size: 46, color: kPrimary),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = questions[currentQuestionIndex];

    String answerAText = current['a'] ?? '';
    String answerBText = current['b'] ?? '';

    if (currentQuestionIndex == questions.length - 1) {
      answerAText =
          'เมื่อรู้สึกไม่พอใจ\nมักจะแสดงออกทาง\nคำพูดหรือท่าทางให้\nรู้ทันที';
      answerBText =
          'เมื่อรู้สึกไม่พอใจ\nมักจะนั่งเงียบ\nไม่พูดว่า\nหรือเลี่ยงไปอยู่คน\nเดียว';
    }

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
                _buildQuestionTitle(),
                const SizedBox(height: 12),
                _buildQuestionBox(current),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildAnswerBox(
                      label: 'A',
                      text: answerAText,
                      isSelected: selectedAnswer == 'A',
                      onTap: () {
                        setState(() {
                          selectedAnswer = 'A';
                        });
                      },
                    ),
                    buildAnswerBox(
                      label: 'B',
                      text: answerBText,
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
                _buildConfirmButton(),
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
