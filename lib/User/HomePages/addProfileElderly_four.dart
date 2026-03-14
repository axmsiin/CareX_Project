import 'package:carex/User/HomePages/addProfileElderly_five.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:flutter/material.dart';

class addProfileElderly_four extends StatefulWidget {
  final ElderlyData elderlyData;

  const addProfileElderly_four({super.key, required this.elderlyData});

  @override
  State<addProfileElderly_four> createState() => _addProfileElderly_fourState();
}

class _addProfileElderly_fourState extends State<addProfileElderly_four> {
  late List<String> selectedNeeds;
  String? selectedNeedsError;

  final List<String> careOptions = const [
    'พึ่งฟื้นหลังการรักษาในโรงพยาบาล',
    'อยู่ระหว่างรักษาการในโรงพยาบาล',
    'กิจวัตรประจำวัน',
    'เตือนการกินยา',
    'การวัดและจดบันทึกสัญญาณชีพ\nความดัน หรือ ออกซิเจน หรือ ไข้',
    'พาไปเดินเล่น',
    'พาไปโรงพยาบาล',
  ];

  @override
  void initState() {
    super.initState();
    selectedNeeds = List<String>.from(widget.elderlyData.selectedNeeds);
  }

  Widget buildOptionBox(String text) {
    final isSelected = selectedNeeds.contains(text);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedNeeds.remove(text);
          } else {
            selectedNeeds.add(text);
          }

          if (selectedNeeds.isNotEmpty) {
            selectedNeedsError = null;
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFD5E7FF),
          borderRadius: BorderRadius.circular(14),
          border: selectedNeedsError != null
              ? Border.all(color: const Color(0xFFF04444))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: const Color(0xFF003F91),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 15, color: Color(0xFF564444)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFieldError(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4),
      child: Text(
        error,
        style: const TextStyle(color: const Color(0xFFF04444), fontSize: 12),
      ),
    );
  }

  void goNext() {
    setState(() {
      selectedNeedsError = null;
    });

    if (selectedNeeds.isEmpty) {
      setState(() {
        selectedNeedsError = 'กรุณาเลือกอย่างน้อย 1 ข้อ';
      });
      return;
    }

    widget.elderlyData.selectedNeeds = List<String>.from(selectedNeeds);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            addProfileElderly_five(elderlyData: widget.elderlyData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCE3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF564444),
                ),
                label: const Text(
                  'ข้อมูลผู้สูงอายุ',
                  style: TextStyle(color: Color(0xFF564444)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ความต้องการในการดูแล*',
                style: TextStyle(fontSize: 18, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 14),
              ...careOptions.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: buildOptionBox(item),
                ),
              ),
              buildFieldError(selectedNeedsError),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: goNext,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF8FBFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'ถัดไป',
                    style: TextStyle(color: Color(0xFF564444)),
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
          color: Color(0xFFD5E7FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home, size: 34, color: Color(0xFF8FBFFF)),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications,
                size: 38,
                color: Color(0xFF003F91),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.account_circle,
                size: 42,
                color: Color(0xFF003F91),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
