import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/User/HomePages/elderlyStore.dart';
import 'package:carex/map.dart';
import 'package:carex/services/backend_data_service.dart';

class editProfileElderly extends StatefulWidget {
  final ElderlyData elderlyData;
  final int elderlyIndex;

  const editProfileElderly({
    super.key,
    required this.elderlyData,
    required this.elderlyIndex,
  });

  @override
  State<editProfileElderly> createState() => _EditProfileElderlyState();
}

class _EditProfileElderlyState extends State<editProfileElderly> {
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const Color kError = Color(0xFFE95257);
  static const String kFont = 'Sarabun';

  late final TextEditingController fullNameController;
  late final TextEditingController nickNameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  DateTime? selectedBirthDate;
  String? selectedGender;
  int selectedWeight = 69;

  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);

  RangeValues salaryRange = const RangeValues(450, 100000);

  String? selectedScheduleType;
  final Set<String> selectedCustomDays = {};

  List<String?> selectedDiseaseList = [null];
  final List<String> selectedNeeds = [];

  List<String?> eatingSelections = [null];
  List<String?> woundSelections = [null];
  List<String?> respiratorySelections = [null];
  List<String?> monitoringSelections = [null];

  double? selectedLatitude;
  double? selectedLongitude;
  String selectedZipcode = '';

  String? fullNameError;
  String? nickNameError;
  String? phoneError;
  String? birthDateError;
  String? genderError;
  String? weightError;
  String? diseaseError;
  String? addressError;
  String? scheduleTypeError;
  String? customDaysError;
  String? startDateError;
  String? endDateError;
  String? timeError;
  String? selectedNeedsError;

  final List<String> genderItems = ['ชาย', 'หญิง', 'ไม่ระบุ'];

  final List<String> diseaseItems = const [
    'ไม่มีโรค',
    'โรคอัลไซเมอร์',
    'โรคกล้ามเนื้ออ่อนแรง',
    'โรคข้ออักเสบ',
    'โรคข้อเข่าเสื่อม',
    'โรคกระดูกพรุน',
    'โรคปอดอุดกั้นเรื้อรัง',
    'หูตึง/การได้ยินเสื่อม',
    'โรคสมาธิสั้น',
    'อัมพาต',
    'โรคพิการ',
    'โรคไตเรื้อรัง',
    'โรคตับอ่อนอักเสบ',
    'โรคเบาหวาน',
    'ภาวะซึมเศร้า',
    'โรคโลหิตจาง',
    'โรคหอบหืด',
    'โรคตับ',
    'โรคความดันโลหิต',
    'โรคหัวใจและหลอดเลือด',
    'โรคมะเร็ง',
    'โรคหลอดเลือดหัวใจตีบ',
    'โรคเกาต์',
    'โรคอ้วน',
  ];

  final List<String> scheduleOptions = const [
    'ทุกวัน',
    'วันธรรมดา',
    'เสาร์-อาทิตย์',
    'กำหนดวันเอง',
    'ทุกเดือน',
    'ทุกปี',
  ];

  final List<String> weekDays = const [
    'วันจันทร์',
    'วันอังคาร',
    'วันพุธ',
    'วันพฤหัสบดี',
    'วันศุกร์',
    'วันเสาร์',
    'วันอาทิตย์',
  ];

  final List<String> careOptions = const [
    'พักฟื้นหลังการรักษาในโรงพยาบาล',
    'อยู่ระหว่างรักษาภายในโรงพยาบาล',
    'กิจวัตรประจำวัน',
    'เตือนการกินยา',
    'การวัดและจดบันทึกสัญญาณชีพ ความดัน หรือ ออกซิเจน หรือ ไข้',
    'พาไปเดินเล่น',
    'พาไปโรงพยาบาล',
  ];

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

  final List<String> thaiMonths = const [
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

    final data = widget.elderlyData;

    fullNameController = TextEditingController(text: data.fullName);
    nickNameController = TextEditingController(text: data.nickName);
    phoneController = TextEditingController(text: data.phone);
    addressController = TextEditingController(text: data.address);

    selectedBirthDate = _parseThaiDate(data.birthDate);
    selectedGender = data.gender.isEmpty ? null : data.gender;
    selectedWeight = int.tryParse(data.weight) ?? 69;

    startDate = _parseThaiDate(data.startDate);
    endDate = _parseThaiDate(data.endDate);
    startTime = _parseTime(data.startTime);
    endTime = _parseTime(data.endTime);

    // --- ส่วนที่แก้ไข: กู้คืนประเภทระยะเวลาจากการวิเคราะห์ชุดวันที่ใน Database ---
    final List<DateTime> savedDates = _parseServiceDates(data.serviceDatesText);
    
    if (savedDates.isNotEmpty && startDate != null && endDate != null) {
      // พยายามวิเคราะห์จากชุดวันที่ที่มีก่อนเพื่อให้ได้ค่าที่แม่นยำที่สุด
      selectedScheduleType = _inferScheduleType(savedDates, startDate!, endDate!);
    } else if (data.scheduleType.isNotEmpty) {
      selectedScheduleType = data.scheduleType;
    } else {
      selectedScheduleType = null;
    }

    // กู้คืนวันที่เลือกไว้ (Custom Days) - เฉพาะกรณีที่เป็น "กำหนดวันเอง" เท่านั้น
    if (selectedScheduleType == 'กำหนดวันเอง') {
      if (data.customDays.isNotEmpty) {
        selectedCustomDays.addAll(data.customDays);
      } else if (savedDates.isNotEmpty) {
        for (var d in savedDates) {
          selectedCustomDays.add(_thaiWeekdayFromDate(d));
        }
      }
    }
    // ------------------------------------------------------------------

    _loadSalary(data.salaryText);

    selectedDiseaseList =
        _buildInitialDiseaseSelections(data.underlyingDiseases);

    selectedNeeds.addAll(data.selectedNeeds);

    eatingSelections =
        _buildInitialSelections(data.eatingCare, noneValue: 'ไม่มี');
    woundSelections =
        _buildInitialSelections(data.woundCare, noneValue: 'ไม่มี');
    respiratorySelections =
        _buildInitialSelections(data.respiratoryCare, noneValue: 'ไม่มี');
    monitoringSelections =
        _buildInitialSelections(data.monitoringCare, noneValue: 'ไม่มี');

    selectedLatitude = data.latitude;
    selectedLongitude = data.longitude;
    selectedZipcode = data.zipcode;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    nickNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _loadSalary(String salaryText) {
    if (salaryText.trim().isEmpty) return;

    final match = RegExp(r'(\d+)\s*-\s*(\d+)').firstMatch(salaryText);

    if (match != null) {
      salaryRange = RangeValues(
        double.tryParse(match.group(1) ?? '450') ?? 450,
        double.tryParse(match.group(2) ?? '100000') ?? 100000,
      );
    }
  }

  List<DateTime> _parseServiceDates(String text) {
    if (text.isEmpty) return [];
    return text
        .split(',')
        .map((s) {
          final trimmed = s.trim();
          final dt = DateTime.tryParse(trimmed);
          if (dt != null) return dt;
          return _parseThaiDate(trimmed);
        })
        .whereType<DateTime>()
        .toList();
  }

  String _inferScheduleType(List<DateTime> dates, DateTime start, DateTime end) {
    if (dates.isEmpty) return 'กำหนดวันเอง';
    
    // สร้างเซ็ตของวันที่ (ล้างเวลาออก)
    final dateSet = dates.map((d) => DateTime(d.year, d.month, d.day)).toSet();

    // รายการประเภทที่ต้องการตรวจสอบ (จัดลำดับจากประเภทเฉพาะทางก่อน)
    final typesToTry = ['วันธรรมดา', 'เสาร์-อาทิตย์', 'ทุกวัน'];

    for (var type in typesToTry) {
      bool isMatch = true;
      DateTime current = DateTime(start.year, start.month, start.day);
      
      while (!current.isAfter(end)) {
        bool shouldBeIn = false;
        if (type == 'ทุกวัน') {
          shouldBeIn = true;
        } else if (type == 'วันธรรมดา') {
          shouldBeIn = (current.weekday >= 1 && current.weekday <= 5);
        } else if (type == 'เสาร์-อาทิตย์') {
          shouldBeIn = (current.weekday == 6 || current.weekday == 7);
        }

        bool isIn = dateSet.contains(current);

        if (shouldBeIn != isIn) {
          isMatch = false;
          break;
        }
        current = current.add(const Duration(days: 1));
      }

      if (isMatch) return type;
    }

    return 'กำหนดวันเอง';
  }

  DateTime? _parseThaiDate(String value) {
    try {
      final raw = value.trim();
      if (raw.isEmpty) return null;

      final isoDate = DateTime.tryParse(raw);
      if (isoDate != null) return isoDate;

      final parts = raw.split(' ');
      if (parts.length != 3) return null;
      final day = int.tryParse(parts[0]);
      final month = thaiMonths.indexOf(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month <= 0 || year == null) return null;
      final gregorianYear = year > 2400 ? year - 543 : year;
      return DateTime(gregorianYear, month, day);
    } catch (_) {
      return null;
    }
  }

  TimeOfDay _parseTime(String value) {
    final normalized = value.replaceAll('.', ':');
    final parts = normalized.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 9, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  List<String?> _buildInitialDiseaseSelections(List<String> diseases) {
    final actual =
        diseases.where((e) => e.trim().isNotEmpty && e != 'ไม่มีโรค').toList();
    if (actual.isEmpty) return [null];
    return [...actual, null];
  }

  List<String?> _buildInitialSelections(
    String storedValue, {
    required String noneValue,
  }) {
    if (storedValue.trim().isEmpty || storedValue.trim() == noneValue) {
      return [null];
    }

    final items = storedValue
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e != noneValue)
        .toList();

    if (items.isEmpty) return [null];
    return [...items, null];
  }

  List<String?> _normalizeSelections(
    List<String?> values, {
    required String noneValue,
  }) {
    final result = <String?>[];

    for (final value in values) {
      if (value == null) {
        result.add(null);
        break;
      }

      result.add(value);

      if (value == noneValue) {
        return [noneValue];
      }
    }

    final actualItems = result
        .where((e) => e != null && e != noneValue)
        .cast<String>()
        .toList();

    if (actualItems.isEmpty) {
      return [null];
    }

    return [...actualItems, null];
  }

  List<String> _getAvailableOptions({
    required List<String> allOptions,
    required List<String?> currentSelections,
    required int currentIndex,
    required String noneValue,
  }) {
    final currentValue = currentSelections[currentIndex];

    final selectedByOthers = <String>{};
    for (int i = 0; i < currentSelections.length; i++) {
      if (i == currentIndex) continue;
      final value = currentSelections[i];
      if (value != null && value != noneValue) {
        selectedByOthers.add(value);
      }
    }

    return allOptions.where((option) {
      if (option == noneValue) return true;
      if (option == currentValue) return true;
      return !selectedByOthers.contains(option);
    }).toList();
  }

  String _convertSelectionsToStorage(
    List<String?> values, {
    required String noneValue,
  }) {
    final actualValues = values
        .where((e) => e != null && e != noneValue)
        .cast<String>()
        .toList();

    if (actualValues.isEmpty) return noneValue;
    return actualValues.join('|');
  }

  List<String> _extractPipeSelections(
    List<String?> values, {
    required String noneValue,
  }) {
    return values
        .where((e) => e != null && e != noneValue)
        .cast<String>()
        .toList();
  }

  String _extractZipcode(String address) {
    final match = RegExp(r'(\d{5})').firstMatch(address);
    return match?.group(1) ?? '';
  }

  String formatThaiDate(DateTime? date) {
    if (date == null) return '-';
    return BackendDataService.toThaiDate(date);
  }

  String formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget buildBox({
    required Widget child,
    EdgeInsetsGeometry? padding,
    bool hasError = false,
  }) {
    return Container(
      height: 48,
      width: double.infinity,
      alignment: Alignment.center,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? kError : kPrimary,
          width: 1.2,
        ),
      ),
      child: child,
    );
  }

  Widget buildFieldError(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4),
      child: Text(
        error,
        style: const TextStyle(
          color: kError,
          fontSize: 12,
          fontFamily: kFont,
        ),
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        color: kText,
        fontFamily: kFont,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget buildEditableTextField({
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    bool readOnly = false,
    TextAlign textAlign = TextAlign.center,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      textAlign: textAlign,
      cursorColor: kPrimary,
      style: const TextStyle(
        color: kText,
        fontSize: 14,
        fontFamily: kFont,
        height: 1.3,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        isCollapsed: true,
        filled: false,
        contentPadding: EdgeInsets.zero,
      ).copyWith(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: kText,
          fontSize: 14,
          fontFamily: kFont,
        ),
      ),
    );
  }

  Widget buildMultiDropdownGroup({
    required String title,
    required List<String> allOptions,
    required List<String?> values,
    required String noneValue,
    required void Function(List<String?> newValues) onChanged,
    String hintText = 'เลือกข้อมูล',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(title),
        const SizedBox(height: 10),
        ...List.generate(values.length, (index) {
          final availableOptions = _getAvailableOptions(
            allOptions: allOptions,
            currentSelections: values,
            currentIndex: index,
            noneValue: noneValue,
          );

          return Padding(
            padding:
                EdgeInsets.only(bottom: index == values.length - 1 ? 0 : 10),
            child: buildBox(
              child: DropdownButtonFormField<String>(
                value: values[index],
                isExpanded: true,
                isDense: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: kPrimary,
                  size: 20,
                ),
                hint: Text(
                  hintText,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    color: kText,
                    fontSize: 14,
                    fontFamily: kFont,
                  ),
                ),
                dropdownColor: kFieldFill,
                style: const TextStyle(
                  color: kText,
                  fontSize: 14,
                  fontFamily: kFont,
                  overflow: TextOverflow.ellipsis,
                ),
                items: availableOptions.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  final updated = List<String?>.from(values);
                  updated[index] = value;
                  onChanged(
                    _normalizeSelections(updated, noneValue: noneValue),
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget buildNeedBox(String text) {
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
            color: selectedNeedsError != null ? kError : kPrimary,
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: kPrimary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: kText,
                  fontFamily: kFont,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomDayBox(String day) {
    final isSelected = selectedCustomDays.contains(day);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedCustomDays.remove(day);
          } else {
            selectedCustomDays.add(day);
          }

          if (selectedCustomDays.isNotEmpty) {
            customDaysError = null;
          }

          if (startDate != null && !canSelectDate(startDate!, isStart: true)) {
            startDate = null;
          }

          if (endDate != null && !canSelectDate(endDate!, isStart: false)) {
            endDate = null;
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
            color: customDaysError != null ? kError : kPrimary,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: kPrimary,
            ),
            const SizedBox(width: 10),
            Text(
              day,
              style: const TextStyle(
                fontSize: 14,
                color: kText,
                fontFamily: kFont,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickBirthDate() async {
    DateTime tempDate = selectedBirthDate ?? DateTime(1995, 7, 19);

    await showModalBottomSheet(
      context: context,
      backgroundColor: kBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 350,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'เลือกวันเกิด',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kText,
                      fontFamily: kFont,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    BackendDataService.toThaiDate(tempDate),
                    style: const TextStyle(
                      fontSize: 16,
                      color: kPrimary,
                      fontWeight: FontWeight.w500,
                      fontFamily: kFont,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      children: [
                        // วัน
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                                initialItem: tempDate.day - 1),
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempDate = DateTime(
                                    tempDate.year, tempDate.month, index + 1);
                              });
                            },
                            children: List.generate(
                                31,
                                (index) => Center(
                                    child: Text('${index + 1}',
                                        style: const TextStyle(
                                            fontFamily: kFont)))),
                          ),
                        ),
                        // เดือน
                        Expanded(
                          flex: 2,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                                initialItem: tempDate.month - 1),
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempDate = DateTime(
                                    tempDate.year, index + 1, tempDate.day);
                              });
                            },
                            children: List.generate(
                                12,
                                (index) => Center(
                                    child: Text(thaiMonths[index + 1],
                                        style: const TextStyle(
                                            fontFamily: kFont)))),
                          ),
                        ),
                        // ปี (พ.ศ.)
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                                initialItem: (tempDate.year + 543) - 2483),
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempDate = DateTime(2483 + index - 543,
                                    tempDate.month, tempDate.day);
                              });
                            },
                            children: List.generate(
                                100,
                                (index) => Center(
                                    child: Text('${2483 + index}',
                                        style: const TextStyle(
                                            fontFamily: kFont)))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedBirthDate = tempDate;
                        birthDateError = null;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text('ตกลง',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: kFont,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> pickWeightWheel() async {
    int tempWeight = selectedWeight;

    await showModalBottomSheet(
      context: context,
      backgroundColor: kBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: 320,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'เลือกน้ำหนัก',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kText,
                  fontFamily: kFont,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedWeight - 20,
                  ),
                  onSelectedItemChanged: (index) {
                    tempWeight = 20 + index;
                  },
                  children: List.generate(
                    131,
                    (index) => Center(
                      child: Text(
                        '${20 + index}',
                        style: const TextStyle(
                          color: kText,
                          fontFamily: kFont,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedWeight = tempWeight;
                    weightError = null;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
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
            ],
          ),
        );
      },
    );
  }

  String _thaiWeekdayFromDate(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'วันจันทร์';
      case DateTime.tuesday:
        return 'วันอังคาร';
      case DateTime.wednesday:
        return 'วันพุธ';
      case DateTime.thursday:
        return 'วันพฤหัสบดี';
      case DateTime.friday:
        return 'วันศุกร์';
      case DateTime.saturday:
        return 'วันเสาร์';
      case DateTime.sunday:
        return 'วันอาทิตย์';
      default:
        return '';
    }
  }

  bool canSelectDate(DateTime date, {required bool isStart}) {
    if (selectedScheduleType == null) return true;

    switch (selectedScheduleType) {
      case 'ทุกวัน':
        return true;
      case 'วันธรรมดา':
        return date.weekday >= DateTime.monday &&
            date.weekday <= DateTime.friday;
      case 'เสาร์-อาทิตย์':
        return date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;
      case 'กำหนดวันเอง':
        if (selectedCustomDays.isEmpty) return false;
        return selectedCustomDays.contains(_thaiWeekdayFromDate(date));
      case 'ทุกเดือน':
        if (isStart) return true;
        if (startDate == null) return true;
        return date.day == startDate!.day;
      case 'ทุกปี':
        if (isStart) return true;
        if (startDate == null) return true;
        return date.day == startDate!.day && date.month == startDate!.month;
      default:
        return true;
    }
  }

  DateTime findNearestSelectableDate(
    DateTime preferred, {
    required bool isStart,
  }) {
    if (canSelectDate(preferred, isStart: isStart)) return preferred;

    for (int i = 1; i <= 1500; i++) {
      final next = preferred.add(Duration(days: i));
      if (canSelectDate(next, isStart: isStart)) return next;
    }

    for (int i = 1; i <= 1500; i++) {
      final prev = preferred.subtract(Duration(days: i));
      if (!prev.isBefore(DateTime(2024, 1, 1)) &&
          canSelectDate(prev, isStart: isStart)) {
        return prev;
      }
    }

    return preferred;
  }

  void syncDatesWithSchedule() {
    if (startDate != null && !canSelectDate(startDate!, isStart: true)) {
      startDate = null;
    }

    if (endDate != null && !canSelectDate(endDate!, isStart: false)) {
      endDate = null;
    }

    if (startDate != null && endDate != null && endDate!.isBefore(startDate!)) {
      endDate = startDate;
    }
  }

  Future<void> pickDate({required bool isStart}) async {
    if (selectedScheduleType == null) {
      setState(() {
        scheduleTypeError = 'กรุณาเลือกระยะเวลา';
      });
      return;
    }

    if (selectedScheduleType == 'ระยะเวลา' && selectedCustomDays.isEmpty) {
      setState(() {
        customDaysError = 'กรุณาเลือกวันอย่างน้อย 1 วัน';
      });
      return;
    }

    DateTime preferred = isStart
        ? (startDate ?? DateTime.now())
        : (endDate ?? startDate ?? DateTime.now());

    preferred = findNearestSelectableDate(preferred, isStart: isStart);

    final picked = await showDatePicker(
      context: context,
      initialDate: preferred,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      selectableDayPredicate: (date) {
        if (!canSelectDate(date, isStart: isStart)) return false;
        if (!isStart && startDate != null && date.isBefore(startDate!)) {
          return false;
        }
        return true;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimary,
              onPrimary: kWhite,
              onSurface: kText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          startDateError = null;

          if (endDate != null) {
            if (endDate!.isBefore(startDate!) ||
                !canSelectDate(endDate!, isStart: false)) {
              endDate = null;
            }
          }
        } else {
          endDate = picked;
          endDateError = null;
        }
      });
    }
  }

  Future<void> pickTime({required bool isStart}) async {
    final initial = isStart ? startTime : endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimary,
              onPrimary: kWhite,
              onSurface: kText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
        timeError = null;
      });
    }
  }

  Future<void> pickLocationFromMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const map()),
    );

    if (result != null) {
      final address = result['address'] ?? '';
      setState(() {
        addressController.text = address;
        selectedLatitude = result['latitude'];
        selectedLongitude = result['longitude'];
        selectedZipcode = (result['zipcode'] ?? '').toString().trim();
        if (selectedZipcode.isEmpty) {
          selectedZipcode = _extractZipcode(address);
        }
        addressError = null;
      });
    }
  }

  bool isDateMatched(DateTime date) {
    if (selectedScheduleType == null) return false;

    switch (selectedScheduleType) {
      case 'ทุกวัน':
        return true;
      case 'วันธรรมดา':
        return date.weekday >= DateTime.monday &&
            date.weekday <= DateTime.friday;
      case 'เสาร์-อาทิตย์':
        return date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;
      case 'กำหนดวันเอง':
        return selectedCustomDays.contains(_thaiWeekdayFromDate(date));
      case 'ทุกเดือน':
        if (startDate == null) return false;
        return date.day == startDate!.day;
      case 'ทุกปี':
        if (startDate == null) return false;
        return date.day == startDate!.day && date.month == startDate!.month;
      default:
        return false;
    }
  }

  int calculateWorkingDays() {
    if (startDate == null || endDate == null || selectedScheduleType == null) {
      return 0;
    }

    int count = 0;
    DateTime current = startDate!;

    while (!current.isAfter(endDate!)) {
      if (isDateMatched(current)) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }

    return count;
  }

  String _buildDetailedServiceDatesText() {
    if (startDate == null || endDate == null) return '';

    final matchedDates = <DateTime>[];
    DateTime current = startDate!;

    while (!current.isAfter(endDate!)) {
      if (isDateMatched(current)) {
        matchedDates.add(current);
      }
      current = current.add(const Duration(days: 1));
    }

    if (matchedDates.isEmpty) return '';

    return BackendDataService.formatDateRanges(matchedDates);
  }

  Future<void> saveProfile() async {
    FocusScope.of(context).unfocus();

    setState(() {
      fullNameError = null;
      nickNameError = null;
      phoneError = null;
      birthDateError = null;
      genderError = null;
      weightError = null;
      diseaseError = null;
      addressError = null;
      scheduleTypeError = null;
      customDaysError = null;
      startDateError = null;
      endDateError = null;
      timeError = null;
      selectedNeedsError = null;
    });

    bool isValid = true;

    if (fullNameController.text.trim().isEmpty) {
      fullNameError = 'กรุณากรอกชื่อ-นามสกุล';
      isValid = false;
    }
    if (nickNameController.text.trim().isEmpty) {
      nickNameError = 'กรุณากรอกชื่อเล่น';
      isValid = false;
    }
    if (phoneController.text.trim().isEmpty) {
      phoneError = 'กรุณากรอกเบอร์โทรศัพท์';
      isValid = false;
    }
    if (selectedBirthDate == null) {
      birthDateError = 'กรุณาเลือกวันเกิด';
      isValid = false;
    }
    if (selectedGender == null) {
      genderError = 'กรุณาเลือกเพศ';
      isValid = false;
    }
    if (selectedWeight <= 0) {
      weightError = 'กรุณาเลือกน้ำหนัก';
      isValid = false;
    }
    if (selectedDiseaseList.first == null) {
      diseaseError = 'กรุณาเลือกโรคประจำตัว';
      isValid = false;
    }
    if (addressController.text.trim().isEmpty ||
        selectedLatitude == null ||
        selectedLongitude == null) {
      addressError = 'กรุณาเลือกที่อยู่จากแผนที่';
      isValid = false;
    }
    if (selectedScheduleType == null) {
      scheduleTypeError = 'กรุณาเลือกระยะเวลา';
      isValid = false;
    }
    if (selectedScheduleType == 'กำหนดวันเอง' && selectedCustomDays.isEmpty) {
      customDaysError = 'กรุณาเลือกวันอย่างน้อย 1 วัน';
      isValid = false;
    }
    if (startDate == null) {
      startDateError = 'กรุณาเลือกวันที่เริ่ม';
      isValid = false;
    }
    if (endDate == null) {
      endDateError = 'กรุณาเลือกวันที่สิ้นสุด';
      isValid = false;
    }
    if (startDate != null && endDate != null && endDate!.isBefore(startDate!)) {
      endDateError = 'วันสิ้นสุดต้องไม่น้อยกว่าวันที่เริ่ม';
      isValid = false;
    }

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (startMinutes == endMinutes) {
      timeError = 'เวลาเริ่มและเวลาสิ้นสุดต้องไม่เท่ากัน';
      isValid = false;
    }

    final totalDays = calculateWorkingDays();
    if (selectedScheduleType != null &&
        startDate != null &&
        endDate != null &&
        totalDays <= 0) {
      endDateError = 'ไม่พบจำนวนวันทำงาน กรุณาตรวจสอบข้อมูลอีกครั้ง';
      isValid = false;
    }

    if (selectedNeeds.isEmpty) {
      selectedNeedsError = 'กรุณาเลือกอย่างน้อย 1 ข้อ';
      isValid = false;
    }

    setState(() {});
    if (!isValid) return;

    widget.elderlyData.fullName = fullNameController.text.trim();
    widget.elderlyData.nickName = nickNameController.text.trim();
    widget.elderlyData.phone = phoneController.text.trim();
    widget.elderlyData.birthDate = formatThaiDate(selectedBirthDate);
    widget.elderlyData.gender = selectedGender ?? '';
    widget.elderlyData.weight = selectedWeight.toString();
    widget.elderlyData.underlyingDiseases = selectedDiseaseList
        .where((e) => e != null && e != 'ไม่มีโรค')
        .cast<String>()
        .toList();
    widget.elderlyData.address = addressController.text.trim();
    widget.elderlyData.latitude = selectedLatitude ?? 0.0;
    widget.elderlyData.longitude = selectedLongitude ?? 0.0;
    widget.elderlyData.zipcode = selectedZipcode.isEmpty
        ? _extractZipcode(addressController.text.trim())
        : selectedZipcode;
    widget.elderlyData.scheduleType = selectedScheduleType ?? '';
    widget.elderlyData.customDays = selectedCustomDays.toList();
    widget.elderlyData.startDate = formatThaiDate(startDate);
    widget.elderlyData.endDate = formatThaiDate(endDate);
    widget.elderlyData.startTime = formatTime(startTime);
    widget.elderlyData.endTime = formatTime(endTime);
    widget.elderlyData.salaryText =
        '${salaryRange.start.round()} - ${salaryRange.end.round()} บาท / วัน';
    widget.elderlyData.serviceDatesText = _buildDetailedServiceDatesText();

    widget.elderlyData.eatingCare = _convertSelectionsToStorage(
      eatingSelections,
      noneValue: 'ไม่มี',
    );
    widget.elderlyData.woundCare = _convertSelectionsToStorage(
      woundSelections,
      noneValue: 'ไม่มี',
    );
    widget.elderlyData.respiratoryCare = _convertSelectionsToStorage(
      respiratorySelections,
      noneValue: 'ไม่มี',
    );
    widget.elderlyData.monitoringCare = _convertSelectionsToStorage(
      monitoringSelections,
      noneValue: 'ไม่มี',
    );

    final mergedOptionService = <String>[
      ...selectedNeeds,
      ..._extractPipeSelections(eatingSelections, noneValue: 'ไม่มี'),
      ..._extractPipeSelections(woundSelections, noneValue: 'ไม่มี'),
      ..._extractPipeSelections(respiratorySelections, noneValue: 'ไม่มี'),
      ..._extractPipeSelections(monitoringSelections, noneValue: 'ไม่มี'),
    ].toSet().toList();

    widget.elderlyData.selectedNeeds = mergedOptionService;

    final ok =
        await BackendDataService.updateElderlyProfile(widget.elderlyData);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'อัปเดตข้อมูลผู้สูงอายุลงฐานข้อมูลไม่สำเร็จ',
            style: TextStyle(fontFamily: kFont),
          ),
        ),
      );
      return;
    }

    if (widget.elderlyData.elderlyId != null &&
        widget.elderlyData.elderlyId!.isNotEmpty) {
      await BackendDataService.createElderlyNeed(
        elderlyId: widget.elderlyData.elderlyId!,
        mandatoryLevel: widget.elderlyData.needLevel,
        optionService: widget.elderlyData.selectedNeeds,
      );
    }

    await ElderlyStore.replaceAt(widget.elderlyIndex, widget.elderlyData);

    if (!mounted) return;
    Navigator.pop(context, true);
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

  Widget _buildProfileIcon() {
    return const Center(
      child: Icon(
        Icons.account_circle_outlined,
        size: 112,
        color: kPrimary,
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
    final workingDays = calculateWorkingDays();

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
                const SizedBox(height: 12),
                _buildProfileIcon(),
                const SizedBox(height: 18),
                buildSectionHeader('ข้อมูลสุขภาพพื้นฐาน'),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          buildBox(
                            hasError: fullNameError != null,
                            child: buildEditableTextField(
                              controller: fullNameController,
                              hintText: 'ชื่อ-นามสกุล',
                            ),
                          ),
                          buildFieldError(fullNameError),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          buildBox(
                            hasError: nickNameError != null,
                            child: buildEditableTextField(
                              controller: nickNameController,
                              hintText: 'ชื่อเล่น',
                            ),
                          ),
                          buildFieldError(nickNameError),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          buildBox(
                            hasError: phoneError != null,
                            child: buildEditableTextField(
                              controller: phoneController,
                              hintText: 'เบอร์โทรศัพท์',
                            ),
                          ),
                          buildFieldError(phoneError),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          buildBox(
                            hasError: birthDateError != null,
                            child: InkWell(
                              onTap: pickBirthDate,
                              child: Text(
                                selectedBirthDate == null
                                    ? 'วัน/เดือน/ปีเกิด'
                                    : formatThaiDate(selectedBirthDate),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: kText,
                                  fontSize: 14,
                                  fontFamily: kFont,
                                ),
                              ),
                            ),
                          ),
                          buildFieldError(birthDateError),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Column(
                        children: [
                          buildBox(
                            hasError: genderError != null,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonFormField<String>(
                              value: selectedGender,
                              isExpanded: true,
                              isDense: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                filled: false,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: kPrimary,
                                size: 20,
                              ),
                              hint: const Text(
                                'เพศ',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: kText,
                                  fontSize: 14,
                                  fontFamily: kFont,
                                ),
                              ),
                              dropdownColor: kFieldFill,
                              style: const TextStyle(
                                color: kText,
                                fontSize: 14,
                                fontFamily: kFont,
                                overflow: TextOverflow.ellipsis,
                              ),
                              items: genderItems.map((item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value;
                                  genderError = null;
                                });
                              },
                            ),
                          ),
                          buildFieldError(genderError),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          buildBox(
                            hasError: weightError != null,
                            child: InkWell(
                              onTap: pickWeightWheel,
                              child: Text(
                                'น้ำหนัก: $selectedWeight กก.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: kText,
                                  fontSize: 14,
                                  fontFamily: kFont,
                                ),
                              ),
                            ),
                          ),
                          buildFieldError(weightError),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                buildMultiDropdownGroup(
                  title: 'โรคประจำตัว',
                  allOptions: diseaseItems,
                  values: selectedDiseaseList,
                  noneValue: 'ไม่มีโรค',
                  hintText: 'โรคประจำตัว',
                  onChanged: (newValues) {
                    setState(() {
                      selectedDiseaseList = newValues;
                      diseaseError = null;
                    });
                  },
                ),
                buildFieldError(diseaseError),
                const SizedBox(height: 18),
                buildSectionHeader('ที่อยู่'),
                const SizedBox(height: 10),
                buildBox(
                  hasError: addressError != null,
                  child: buildEditableTextField(
                    controller: addressController,
                    hintText: 'พิมพ์ที่อยู่หรือเลือกจากแผนที่',
                    maxLines: 3,
                    readOnly: false,
                    textAlign: TextAlign.left,
                  ),
                ),
                buildFieldError(addressError),
                const SizedBox(height: 8),
                InkWell(
                  onTap: pickLocationFromMap,
                  child: Container(
                    width: double.infinity,
                    height: 98,
                    decoration: BoxDecoration(
                      color: kBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kPrimary, width: 1.2),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.map_outlined, color: kPrimary, size: 30),
                        SizedBox(height: 4),
                        Text(
                          'เลือกจากแผนที่',
                          style: TextStyle(
                            color: kPrimary,
                            fontSize: 14,
                            fontFamily: kFont,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                buildSectionHeader('วันและเวลาที่จะรับบริการ'),
                const SizedBox(height: 4),
                const Text(
                  '*หมายเหตุ : เลือกระยะเวลาทุกรูปแบบ โดยเลือกเป็น ทุกวัน,วันธรรมดา,เสาร์-อาทิตย์,กำหนดวันเอง,ทุกเดือน,ทุกปี',
                  style: TextStyle(
                    fontSize: 12,
                    color: kError,
                    fontFamily: kFont,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          buildBox(
                            hasError: scheduleTypeError != null,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonFormField<String>(
                              value: selectedScheduleType,
                              isDense: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: kPrimary,
                              ),
                              hint: const Text(
                                'ระยะเวลา',
                                style: TextStyle(
                                  color: kText,
                                  fontSize: 14,
                                  fontFamily: kFont,
                                ),
                              ),
                              dropdownColor: kFieldFill,
                              style: const TextStyle(
                                color: kText,
                                fontSize: 14,
                                fontFamily: kFont,
                              ),
                              items: scheduleOptions.map((item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedScheduleType = value;
                                  scheduleTypeError = null;

                                  if (value != 'กำหนดวันเอง') {
                                    selectedCustomDays.clear();
                                    customDaysError = null;
                                  }

                                  syncDatesWithSchedule();
                                });
                              },
                            ),
                          ),
                          buildFieldError(scheduleTypeError),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          buildBox(
                            hasError: startDateError != null,
                            child: InkWell(
                              onTap: () => pickDate(isStart: true),
                              child: Text(
                                startDate == null
                                    ? 'วันที่เริ่ม'
                                    : 'วันที่เริ่ม : ${BackendDataService.toThaiDateWithDay(startDate!)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: kText,
                                  fontSize: 14,
                                  fontFamily: kFont,
                                ),
                              ),
                            ),
                          ),
                          buildFieldError(startDateError),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (selectedScheduleType == 'กำหนดวันเอง') ...[
                  ...weekDays.map(
                    (day) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: buildCustomDayBox(day),
                    ),
                  ),
                  buildFieldError(customDaysError),
                  const SizedBox(height: 2),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildBox(
                        child: Text(
                          '$workingDays วัน',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: kText,
                            fontSize: 16,
                            fontFamily: kFont,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          buildBox(
                            hasError: endDateError != null,
                            child: InkWell(
                              onTap: () => pickDate(isStart: false),
                              child: Text(
                                endDate == null
                                    ? 'วันสิ้นสุด'
                                    : 'วันสิ้นสุด : ${BackendDataService.toThaiDateWithDay(endDate!)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: kText,
                                  fontSize: 14,
                                  fontFamily: kFont,
                                ),
                              ),
                            ),
                          ),
                          buildFieldError(endDateError),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildBox(
                      hasError: timeError != null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => pickTime(isStart: true),
                            child: Text(
                              formatTime(startTime),
                              style: const TextStyle(
                                color: kText,
                                fontSize: 16,
                                fontFamily: kFont,
                              ),
                            ),
                          ),
                          const Text(
                            ' - ',
                            style: TextStyle(
                              color: kText,
                              fontSize: 16,
                              fontFamily: kFont,
                            ),
                          ),
                          InkWell(
                            onTap: () => pickTime(isStart: false),
                            child: Text(
                              formatTime(endTime),
                              style: const TextStyle(
                                color: kText,
                                fontSize: 16,
                                fontFamily: kFont,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    buildFieldError(timeError),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'ราคาค่าจ้าง',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 76,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: kFieldFill,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kPrimary, width: 1.2),
                      ),
                      child: const Text(
                        'วัน',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: kText,
                          fontFamily: kFont,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${salaryRange.start.round()} บาท',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: kText,
                                    fontFamily: kFont,
                                  ),
                                ),
                                Text(
                                  '${salaryRange.end.round()} บาท',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: kText,
                                    fontFamily: kFont,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFFF48A8A),
                              inactiveTrackColor: const Color(0xFF8C817F),
                              thumbColor: const Color(0xFFF04848),
                              overlayColor:
                                  const Color(0xFFF04848).withOpacity(0.15),
                              trackHeight: 1.8,
                              rangeThumbShape: const RoundRangeSliderThumbShape(
                                enabledThumbRadius: 5,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 10,
                              ),
                            ),
                            child: RangeSlider(
                              values: salaryRange,
                              min: 450,
                              max: 100000,
                              divisions: ((100000 - 450) / 5).round(),
                              labels: RangeLabels(
                                salaryRange.start.round().toString(),
                                salaryRange.end.round().toString(),
                              ),
                              onChanged: (RangeValues values) {
                                final double snappedStart =
                                    ((values.start / 5).round() * 5).toDouble();
                                final double snappedEnd =
                                    ((values.end / 5).round() * 5).toDouble();

                                setState(() {
                                  salaryRange = RangeValues(
                                    snappedStart.clamp(450, 100000),
                                    snappedEnd.clamp(450, 100000),
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                buildSectionHeader('ความต้องการในการดูแล'),
                const SizedBox(height: 14),
                ...careOptions.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: buildNeedBox(item),
                  ),
                ),
                buildFieldError(selectedNeedsError),
                const SizedBox(height: 18),
                buildMultiDropdownGroup(
                  title: 'การกินและการขับถ่าย',
                  allOptions: eatingOptions,
                  values: eatingSelections,
                  noneValue: 'ไม่มี',
                  hintText: 'เลือกข้อมูล',
                  onChanged: (newValues) {
                    setState(() {
                      eatingSelections = newValues;
                    });
                  },
                ),
                const SizedBox(height: 18),
                buildMultiDropdownGroup(
                  title: 'การดูแลบาดแผลและอุปกรณ์',
                  allOptions: woundOptions,
                  values: woundSelections,
                  noneValue: 'ไม่มี',
                  hintText: 'เลือกข้อมูล',
                  onChanged: (newValues) {
                    setState(() {
                      woundSelections = newValues;
                    });
                  },
                ),
                const SizedBox(height: 18),
                buildMultiDropdownGroup(
                  title: 'ระบบทางเดินหายใจ',
                  allOptions: respiratoryOptions,
                  values: respiratorySelections,
                  noneValue: 'ไม่มี',
                  hintText: 'เลือกข้อมูล',
                  onChanged: (newValues) {
                    setState(() {
                      respiratorySelections = newValues;
                    });
                  },
                ),
                const SizedBox(height: 18),
                buildMultiDropdownGroup(
                  title: 'การเฝ้าระวังและหัตถการอื่นๆ',
                  allOptions: monitoringOptions,
                  values: monitoringSelections,
                  noneValue: 'ไม่มี',
                  hintText: 'เลือกข้อมูล',
                  onChanged: (newValues) {
                    setState(() {
                      monitoringSelections = newValues;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: saveProfile,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'บันทึก',
                        style: TextStyle(
                          color: kWhite,
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
