import 'package:flutter/material.dart';
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
  final List<Map<String, String>> questions = [
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

  int _calculateScore(List<String> selectedAnswers) {
    final aCount = selectedAnswers.where((e) => e == 'A').length;
    final bCount = selectedAnswers.where((e) => e == 'B').length;
    if (aCount > bCount) return 1;
    if (bCount > aCount) return 2;
    return 3;
  }

  Future<void> finishAndGoHome() async {
    Navigator.of(context, rootNavigator: true).pop();

    final score = _calculateScore(answers);
    widget.elderlyData.score = score;
    widget.elderlyData.status = 'matching';
    widget.elderlyData.caregiver = '';
    widget.elderlyData.matchPercent = '';

    final created = await BackendDataService.createElderlyProfile(widget.elderlyData);
    if (created != null) {
      created.score = score;
      created.status = created.status.isEmpty ? 'matching' : created.status;
      widget.elderlyData.elderlyId = created.elderlyId;
      widget.elderlyData.status = created.status;
      await ElderlyStore.upsert(created);
    } else {
      await ElderlyStore.upsert(widget.elderlyData);
    }

    await BackendDataService.submitQuestionScore(
      target: 'elderly',
      score: score,
      relatedId: created?.elderlyId ?? widget.elderlyData.elderlyId,
      answers: answers,
    );
    await BackendDataService.requestMatch(
      created ?? widget.elderlyData,
      elderlyId: created?.elderlyId ?? widget.elderlyData.elderlyId,
      questionScore: score,
    );

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const home()),
      (route) => false,
    );
  }

  void showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 38),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFCFAFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEE711E), width: 1.4),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      const Text(
                        '*หากกดยืนยันแล้วระบบจะมีการ Matching ข้อมูลของผู้สูงอายุและผู้ดูแล',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFE95257),
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 82,
                          height: 34,
                          child: ElevatedButton(
                            onPressed: finishAndGoHome,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF39C327),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'ตกลง',
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 20, color: Colors.black87),
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
    if (selectedAnswer == null) return;

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
      onTap: onTap,
      child: Container(
        width: 135,
        height: 155,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEE711E) : const Color(0xFFFCFAFF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 22,
                color: isSelected ? Colors.white : const Color(0xFF7B6B6B),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.25,
                    color: isSelected ? Colors.white : const Color(0xFF564444),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
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
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF564444),
                  size: 18,
                ),
                label: const Text(
                  'ข้อมูลผู้สูงอายุ',
                  style: TextStyle(color: Color(0xFF564444), fontSize: 15),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'แบบสอบถาม',
                style: TextStyle(fontSize: 17, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFAFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  current['question']!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF564444),
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildAnswerBox(
                    label: 'A',
                    text: current['a']!,
                    isSelected: selectedAnswer == 'A',
                    onTap: () {
                      setState(() {
                        selectedAnswer = 'A';
                      });
                    },
                  ),
                  buildAnswerBox(
                    label: 'B',
                    text: current['b']!,
                    isSelected: selectedAnswer == 'B',
                    onTap: () {
                      setState(() {
                        selectedAnswer = 'B';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 84,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: selectedAnswer == null ? null : nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE711E),
                      disabledBackgroundColor: const Color(0xFFFCFAFF),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      currentQuestionIndex == questions.length - 1
                          ? 'ยืนยัน'
                          : 'ถัดไป',
                      style: const TextStyle(
                        color: Color(0xFF564444),
                        fontSize: 14,
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
      bottomNavigationBar: Container(
        height: 85,
        decoration: const BoxDecoration(
          color: Color(0xFFFCFAFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.home, size: 38, color: Color(0xFFEE711E)),
            Icon(Icons.notifications, size: 38, color: Color(0xFF0D47A1)),
            Icon(Icons.account_circle, size: 42, color: Color(0xFF0D47A1)),
          ],
        ),
      ),
    );
  }
}
