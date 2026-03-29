import 'package:carex/User/HomePages/question.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:flutter/material.dart';

class addProfileElderly_five extends StatefulWidget {
  final ElderlyData elderlyData;

  const addProfileElderly_five({super.key, required this.elderlyData});

  @override
  State<addProfileElderly_five> createState() => _addProfileElderly_fiveState();
}

class _addProfileElderly_fiveState extends State<addProfileElderly_five> {
  late List<String> eatingSelections;
  late List<String> woundSelections;
  late List<String> respiratorySelections;
  late List<String> monitoringSelections;

  final List<String> eatingOptions = const [
    'ไม่มี',
    'ช่วยป้อนอาหาร หรือ เตรียมอาหารเฉพาะโรค',
    'การให้อาหารทางสายยาง (สายจมูก หรือ สายผ่านหน้าท้อง)',
    'การช่วยสวนปัสสาวะ หรือ ดูแลถุงเก็บปัสสาวะ',
    'การดูแลถุงทวารเทียม (หน้าท้อง)',
    'การสวนอุจจาระ',
  ];

  final List<String> woundOptions = const [
    'ไม่มี',
    'การทำแผลทั่วไป (แผลสด หรือ แผลถลอก)',
    'การทำแผลกดทับ (แผลลึก หรือ แผลเปื่อย)',
    'การทำแผลเบาหวาน',
    'การทำแผลเจาะคอ',
    'การเปลี่ยนสายหรืออุปกรณ์ทางการแพทย์ต่างๆ',
  ];

  final List<String> respiratoryOptions = const [
    'ไม่มี',
    'การดูดเสมหะ (ทางปาก หรือ ทางจมูก)',
    'การดูแลเครื่องผลิตออกซิเจน หรือ ถังออกซิเจน',
    'การใช้เครื่องช่วยหายใจ',
    'การพ่นยาขยายหลอดลม',
  ];

  final List<String> monitoringOptions = const [
    'ไม่มี',
    'การเจาะน้ำตาลปลายนิ้ว (เช็คเบาหวาน)',
    'การฉีดอินซูลิน',
    'การทำกายภาพบำบัด หรือ บริหารกล้ามเนื้อตามคำแนะนำหมอ',
    'การประคองและเคลื่อนย้ายผู้ป่วยน้ำหนักตัวเยอะ',
    'ใช้อุปกรณ์ช่วยยก',
  ];

  @override
  void initState() {
    super.initState();
    eatingSelections = _buildInitialSelections(widget.elderlyData.eatingCare);
    woundSelections = _buildInitialSelections(widget.elderlyData.woundCare);
    respiratorySelections = _buildInitialSelections(
      widget.elderlyData.respiratoryCare,
    );
    monitoringSelections = _buildInitialSelections(
      widget.elderlyData.monitoringCare,
    );
  }

  List<String> _buildInitialSelections(String storedValue) {
    if (storedValue.trim().isEmpty || storedValue.trim() == 'ไม่มี') {
      return ['ไม่มี'];
    }

    final items = storedValue
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e != 'ไม่มี')
        .toList();

    if (items.isEmpty) {
      return ['ไม่มี'];
    }

    return [...items, 'ไม่มี'];
  }

  List<String> _normalizeSelections(List<String> values) {
    final selected =
        values.where((e) => e.trim().isNotEmpty && e != 'ไม่มี').toList();

    return [...selected, 'ไม่มี'];
  }

  List<String> _getAvailableOptions({
    required List<String> allOptions,
    required List<String> currentSelections,
    required int currentIndex,
  }) {
    final currentValue = currentSelections[currentIndex];

    final selectedByOthers = <String>{};
    for (int i = 0; i < currentSelections.length; i++) {
      if (i == currentIndex) continue;
      final value = currentSelections[i];
      if (value != 'ไม่มี') {
        selectedByOthers.add(value);
      }
    }

    return allOptions.where((option) {
      if (option == 'ไม่มี') return true;
      if (option == currentValue) return true;
      return !selectedByOthers.contains(option);
    }).toList();
  }

  void _updateSelection({
    required List<String> targetList,
    required int index,
    required String newValue,
    required void Function(List<String>) onDone,
  }) {
    final updated = List<String>.from(targetList);
    updated[index] = newValue;

    onDone(_normalizeSelections(updated));
  }

  String _convertSelectionsToStorage(List<String> values) {
    final actualValues = values.where((e) => e != 'ไม่มี').toList();
    if (actualValues.isEmpty) return 'ไม่มี';
    return actualValues.join('|');
  }

  Widget buildDynamicDropdownGroup({
    required String title,
    required List<String> allOptions,
    required List<String> values,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, color: Color(0xFF564444)),
        ),
        const SizedBox(height: 8),
        ...List.generate(values.length, (index) {
          final availableOptions = _getAvailableOptions(
            allOptions: allOptions,
            currentSelections: values,
            currentIndex: index,
          );

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == values.length - 1 ? 0 : 10,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFAFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonFormField<String>(
                value: values[index],
                decoration: const InputDecoration(border: InputBorder.none),
                items: availableOptions.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF564444),
                        fontSize: 15,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _updateSelection(
                      targetList: values,
                      index: index,
                      newValue: value,
                      onDone: onChanged,
                    );
                  });
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  void goNext() {
    widget.elderlyData.eatingCare = _convertSelectionsToStorage(
      eatingSelections,
    );
    widget.elderlyData.woundCare = _convertSelectionsToStorage(woundSelections);
    widget.elderlyData.respiratoryCare = _convertSelectionsToStorage(
      respiratorySelections,
    );
    widget.elderlyData.monitoringCare = _convertSelectionsToStorage(
      monitoringSelections,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => question(elderlyData: widget.elderlyData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                'ความต้องการในการดูแล',
                style: TextStyle(fontSize: 18, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 18),
              buildDynamicDropdownGroup(
                title: 'การกินและการขับถ่าย',
                allOptions: eatingOptions,
                values: eatingSelections,
                onChanged: (newValues) {
                  eatingSelections = newValues;
                },
              ),
              const SizedBox(height: 18),
              buildDynamicDropdownGroup(
                title: 'การดูแลบาดแผลและอุปกรณ์',
                allOptions: woundOptions,
                values: woundSelections,
                onChanged: (newValues) {
                  woundSelections = newValues;
                },
              ),
              const SizedBox(height: 18),
              buildDynamicDropdownGroup(
                title: 'ระบบทางเดินหายใจ',
                allOptions: respiratoryOptions,
                values: respiratorySelections,
                onChanged: (newValues) {
                  respiratorySelections = newValues;
                },
              ),
              const SizedBox(height: 18),
              buildDynamicDropdownGroup(
                title: 'การเฝ้าระวังและหัตถการอื่นๆ',
                allOptions: monitoringOptions,
                values: monitoringSelections,
                onChanged: (newValues) {
                  monitoringSelections = newValues;
                },
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: goNext,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFEE711E),
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
          color: Color(0xFFFCFAFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home, size: 34, color: Color(0xFFEE711E)),
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
              onPressed: () {},
              icon: const Icon(
                Icons.account_circle,
                size: 42,
                color: Color(0xFFEE711E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
