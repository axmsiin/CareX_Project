import 'package:flutter/material.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/profileCaregiver.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiver_store.dart';
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
  final List<Map<String, String>> questions = [
    {
      'question':
          'ผู้สูงอายุที่คุณดูแลปฏิเสธจะทำกิจกรรมที่กำหนดในวันนั้น และดูมีอารมณ์ไม่ดี คุณมักจะ…',
      'a': 'หยุดก่อนและถามว่าเขารู้สึกอย่างไรเพื่อทำความเข้าใจสิ่งที่เกิดขึ้น',
      'b': 'อธิบายสั้นๆว่าทำไมกิจกรรมนี้จึงสำคัญและค่อยๆชวนให้เขาลองทำ',
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

  int _calculateScore(List<String> selectedAnswers) {
    final aCount = selectedAnswers.where((e) => e == 'A').length;
    final bCount = selectedAnswers.where((e) => e == 'B').length;
    if (aCount > bCount) return 1;
    if (bCount > aCount) return 2;
    return 3;
  }

  Future<void> nextQuestion() async {
    if (selectedAnswer == null) return;

    answers.add(selectedAnswer!);

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
      });
    } else {
      final score = _calculateScore(answers);
      final now = DateTime.now();

      widget.profile.score = score;
      await CaregiverStore.save(widget.profile);

      await BackendDataService.submitQuestionScore(
        target: 'caregiver',
        score: score,
        relatedId: widget.profile.caregiverId,
        answers: answers,
      );

      await BackendDataService.updateCaregiverScore(
        score: score,
        scoreDate: now,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => profileCaregiver(profile: widget.profile),
        ),
      );
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
        width: 145,
        height: 190,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEE711E) : const Color(0xFFFCFAFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 28,
                color: isSelected ? Colors.white : const Color(0xFF564444),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.3,
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
                ),
                label: const Text(
                  'ย้อนกลับ',
                  style: TextStyle(color: Color(0xFF564444)),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'แบบสอบถาม',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF564444),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFAFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  current['question']!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF564444),
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 18),
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
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: selectedAnswer == null ? null : nextQuestion,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFEE711E),
                    disabledBackgroundColor: const Color(0xFFFCFAFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    currentQuestionIndex == questions.length - 1
                        ? 'เสร็จสิ้น'
                        : 'ถัดไป',
                    style: const TextStyle(color: Color(0xFF564444)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFFFCFAFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.home, size: 36, color: Color(0xFFEE711E)),
            Icon(Icons.notifications, size: 34, color: Color(0xFFEE711E)),
            Icon(Icons.account_circle, size: 36, color: Color(0xFFEE711E)),
          ],
        ),
      ),
    );
  }
}
