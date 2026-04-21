import 'package:carex/User/HomePages/addProfileElderly_five.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class addProfileElderly_four extends StatefulWidget {
  final ElderlyData elderlyData;

  const addProfileElderly_four({super.key, required this.elderlyData});

  @override
  State<addProfileElderly_four> createState() => _addProfileElderly_fourState();
}

class _addProfileElderly_fourState extends State<addProfileElderly_four> {
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const String kFont = 'Sarabun';

  late List<String> selectedNeeds;
  String? selectedNeedsError;

  final List<String> careOptions = const [
    'พักฟื้นหลังการรักษาในโรงพยาบาล',
    'อยู่ระหว่างรักษาภายในโรงพยาบาล',
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

  Widget buildFieldError(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Text(
        error,
        style: const TextStyle(
          color: Color(0xFFF04444),
          fontSize: 14,
          fontFamily: kFont,
        ),
      ),
    );
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
          color: kFieldFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                selectedNeedsError != null ? const Color(0xFFF04444) : kPrimary,
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                color: kPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: kText,
                  fontFamily: kFont,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
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

  Widget _buildNextButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 78,
        height: 40,
        child: ElevatedButton(
          onPressed: goNext,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: kPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: EdgeInsets.zero,
          ),
          child: const Text(
            'ถัดไป',
            style: TextStyle(
              color: kWhite,
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
                const SizedBox(height: 46),
                const Text(
                  'ความต้องการในการดูแล*',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ...careOptions.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: buildOptionBox(item),
                  ),
                ),
                buildFieldError(selectedNeedsError),
                const SizedBox(height: 18),
                _buildNextButton(),
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
