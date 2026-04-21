import 'package:carex/User/HomePages/question.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class addProfileElderly_five extends StatefulWidget {
  final ElderlyData elderlyData;

  const addProfileElderly_five({super.key, required this.elderlyData});

  @override
  State<addProfileElderly_five> createState() => _addProfileElderly_fiveState();
}

class _addProfileElderly_fiveState extends State<addProfileElderly_five> {
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const String kFont = 'Sarabun';

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
    respiratorySelections =
        _buildInitialSelections(widget.elderlyData.respiratoryCare);
    monitoringSelections =
        _buildInitialSelections(widget.elderlyData.monitoringCare);
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

    if (items.isEmpty) return ['ไม่มี'];
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

  List<String> _extractSelectedItems(List<String> values) {
    return values.where((e) => e != 'ไม่มี').toList();
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

  Widget _buildDropdownBox({
    required List<String> allOptions,
    required List<String> values,
    required ValueChanged<List<String>> onChanged,
  }) {
    return buildSingleBox(
      height: 54,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: values.first,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: kPrimary),
          style: const TextStyle(
            color: kText,
            fontSize: 14,
            fontFamily: kFont,
          ),
          dropdownColor: kFieldFill,
          items: _getAvailableOptions(
            allOptions: allOptions,
            currentSelections: values,
            currentIndex: 0,
          ).map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kText,
                  fontSize: 14,
                  fontFamily: kFont,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _updateSelection(
                targetList: values,
                index: 0,
                newValue: value,
                onDone: onChanged,
              );
            });
          },
        ),
      ),
    );
  }

  Widget buildSingleBox({
    required Widget child,
    double height = 54,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
    AlignmentGeometry alignment = Alignment.centerLeft,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: kPrimary,
          width: 1.2,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSection({
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
          style: const TextStyle(
            fontSize: 16,
            color: kText,
            fontFamily: kFont,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        _buildDropdownBox(
          allOptions: allOptions,
          values: values,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void goNext() {
    widget.elderlyData.eatingCare =
        _convertSelectionsToStorage(eatingSelections);
    widget.elderlyData.woundCare = _convertSelectionsToStorage(woundSelections);
    widget.elderlyData.respiratoryCare =
        _convertSelectionsToStorage(respiratorySelections);
    widget.elderlyData.monitoringCare =
        _convertSelectionsToStorage(monitoringSelections);

    final mergedOptionService = <String>[
      ...widget.elderlyData.selectedNeeds,
      ..._extractSelectedItems(eatingSelections),
      ..._extractSelectedItems(woundSelections),
      ..._extractSelectedItems(respiratorySelections),
      ..._extractSelectedItems(monitoringSelections),
    ].toSet().toList();

    widget.elderlyData.selectedNeeds = mergedOptionService;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => question(elderlyData: widget.elderlyData),
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
                  'ความต้องการในการดูแล',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: 'การกินและการขับถ่าย',
                  allOptions: eatingOptions,
                  values: eatingSelections,
                  onChanged: (newValues) => eatingSelections = newValues,
                ),
                const SizedBox(height: 18),
                _buildSection(
                  title: 'การดูแลบาดแผลและอุปกรณ์',
                  allOptions: woundOptions,
                  values: woundSelections,
                  onChanged: (newValues) => woundSelections = newValues,
                ),
                const SizedBox(height: 18),
                _buildSection(
                  title: 'ระบบทางเดินหายใจ',
                  allOptions: respiratoryOptions,
                  values: respiratorySelections,
                  onChanged: (newValues) => respiratorySelections = newValues,
                ),
                const SizedBox(height: 18),
                _buildSection(
                  title: 'การเฝ้าระวังและหัตถการอื่นๆ',
                  allOptions: monitoringOptions,
                  values: monitoringSelections,
                  onChanged: (newValues) => monitoringSelections = newValues,
                ),
                const SizedBox(height: 26),
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
