import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/User/HomePages/elderlyStore.dart';
import 'package:carex/map.dart';

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
  String salaryUnit = 'วัน';

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

  String? fullNameError;
  String? nickNameError;
  String? phoneError;
  String? birthDateError;
  String? genderError;
  String? weightError;
  String? diseaseError;
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
    'พึ่งฟื้นหลังการรักษาในโรงพยาบาล',
    'อยู่ระหว่างรักษาการในโรงพยาบาล',
    'กิจวัตรประจำวัน',
    'เตือนการกินยา',
    'การวัดและจดบันทึกสัญญาณชีพ\nความดัน หรือ ออกซิเจน หรือ ไข้',
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

    selectedScheduleType =
        data.scheduleType.trim().isEmpty ? null : data.scheduleType;
    selectedCustomDays.addAll(data.customDays);

    _loadSalary(data.salaryText);

    selectedDiseaseList = _buildInitialSelections(
      data.disease,
      noneValue: 'ไม่มีโรค',
    );

    selectedNeeds.addAll(data.selectedNeeds);

    eatingSelections = _buildInitialSelections(
      data.eatingCare,
      noneValue: 'ไม่มี',
    );
    woundSelections = _buildInitialSelections(
      data.woundCare,
      noneValue: 'ไม่มี',
    );
    respiratorySelections = _buildInitialSelections(
      data.respiratoryCare,
      noneValue: 'ไม่มี',
    );
    monitoringSelections = _buildInitialSelections(
      data.monitoringCare,
      noneValue: 'ไม่มี',
    );
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

    final match = RegExp(
      r'(\d+)\s*-\s*(\d+)\s*บาท\s*/\s*(\S+)',
    ).firstMatch(salaryText);

    if (match != null) {
      salaryRange = RangeValues(
        double.tryParse(match.group(1) ?? '450') ?? 450,
        double.tryParse(match.group(2) ?? '100000') ?? 100000,
      );
      salaryUnit = match.group(3) ?? 'วัน';
    }
  }

  DateTime? _parseThaiDate(String value) {
    try {
      final parts = value.trim().split(' ');
      if (parts.length != 3) return null;
      final day = int.tryParse(parts[0]);
      final month = thaiMonths.indexOf(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month <= 0 || year == null) return null;
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split('.');
    if (parts.length != 2) return const TimeOfDay(hour: 9, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
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

  String formatThaiDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day} ${thaiMonths[date.month]} ${date.year}';
  }

  String formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h.$m';
  }

  Widget buildBox({
    required Widget child,
    EdgeInsetsGeometry? padding,
    bool hasError = false,
  }) {
    return Container(
      width: double.infinity,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD5E7FF),
        borderRadius: BorderRadius.circular(14),
        border: hasError ? Border.all(color: const Color(0xFFF04444)) : null,
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
        style: const TextStyle(color: const Color(0xFFF04444), fontSize: 12),
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, color: Color(0xFF564444)),
    );
  }

  Widget buildEditableTextField({
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration.collapsed(hintText: hintText),
      style: const TextStyle(color: Color(0xFF564444), fontSize: 14),
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
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: Color(0xFF564444)),
        ),
        const SizedBox(height: 10),
        ...List.generate(values.length, (index) {
          final availableOptions = _getAvailableOptions(
            allOptions: allOptions,
            currentSelections: values,
            currentIndex: index,
            noneValue: noneValue,
          );

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == values.length - 1 ? 0 : 10,
            ),
            child: buildBox(
              child: DropdownButtonFormField<String>(
                value: values[index],
                decoration: const InputDecoration(border: InputBorder.none),
                hint: Text(hintText),
                items: availableOptions.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, overflow: TextOverflow.ellipsis),
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
          color: const Color(0xFFD5E7FF),
          borderRadius: BorderRadius.circular(14),
          border: customDaysError != null
              ? Border.all(color: const Color(0xFFF04444))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: const Color(0xFF003F91),
            ),
            const SizedBox(width: 10),
            Text(
              day,
              style: const TextStyle(fontSize: 15, color: Color(0xFF564444)),
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
      builder: (context) {
        return Container(
          height: 320,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'เลือกวันเกิด',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempDate,
                  minimumDate: DateTime(1940, 1, 1),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    tempDate = newDate;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedBirthDate = tempDate;
                    birthDateError = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickWeightWheel() async {
    int tempWeight = selectedWeight;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 320,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'เลือกน้ำหนัก',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    (index) => Center(child: Text('${20 + index}')),
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
                child: const Text('ตกลง'),
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

    if (selectedScheduleType == 'กำหนดวันเอง' && selectedCustomDays.isEmpty) {
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
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDatePickerMode: DatePickerMode.day,
      helpText: 'เลือกวันที่',
      cancelText: 'ยกเลิก',
      confirmText: 'ตกลง',
      selectableDayPredicate: (date) {
        if (!canSelectDate(date, isStart: isStart)) return false;

        if (!isStart && startDate != null && date.isBefore(startDate!)) {
          return false;
        }

        return true;
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

    final picked = await showTimePicker(context: context, initialTime: initial);

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
      setState(() {
        addressController.text = result['address'] ?? '';
        selectedLatitude = result['latitude'];
        selectedLongitude = result['longitude'];
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

    final Map<int, Map<int, List<int>>> groupedByYearAndMonth = {};

    for (final date in matchedDates) {
      groupedByYearAndMonth.putIfAbsent(date.year, () => {});
      groupedByYearAndMonth[date.year]!.putIfAbsent(date.month, () => []);
      groupedByYearAndMonth[date.year]![date.month]!.add(date.day);
    }

    final sortedYears = groupedByYearAndMonth.keys.toList()..sort();
    final List<String> yearParts = [];

    for (final year in sortedYears) {
      final monthsMap = groupedByYearAndMonth[year]!;
      final sortedMonths = monthsMap.keys.toList()..sort();

      final List<String> monthParts = [];

      for (final month in sortedMonths) {
        final days = monthsMap[month]!..sort();

        final List<String> ranges = [];
        int start = days.first;
        int end = days.first;

        for (int i = 1; i < days.length; i++) {
          if (days[i] == end + 1) {
            end = days[i];
          } else {
            ranges.add(start == end ? '$start' : '$start-$end');
            start = days[i];
            end = days[i];
          }
        }

        ranges.add(start == end ? '$start' : '$start-$end');
        monthParts.add('${ranges.join(', ')} ${thaiMonths[month]}');
      }

      yearParts.add('${monthParts.join(', ')} $year');
    }

    return yearParts.join(', ');
  }

  void saveProfile() {
    FocusScope.of(context).unfocus();

    setState(() {
      fullNameError = null;
      nickNameError = null;
      phoneError = null;
      birthDateError = null;
      genderError = null;
      weightError = null;
      diseaseError = null;
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
    widget.elderlyData.disease = _convertSelectionsToStorage(
      selectedDiseaseList,
      noneValue: 'ไม่มีโรค',
    );
    widget.elderlyData.address = addressController.text.trim();
    widget.elderlyData.scheduleType = selectedScheduleType ?? '';
    widget.elderlyData.customDays = selectedCustomDays.toList();
    widget.elderlyData.startDate = formatThaiDate(startDate);
    widget.elderlyData.endDate = formatThaiDate(endDate);
    widget.elderlyData.startTime = formatTime(startTime);
    widget.elderlyData.endTime = formatTime(endTime);
    widget.elderlyData.salaryText =
        '${salaryRange.start.round()} - ${salaryRange.end.round()} บาท / $salaryUnit';
    widget.elderlyData.serviceDatesText = _buildDetailedServiceDatesText();
    widget.elderlyData.selectedNeeds = List<String>.from(selectedNeeds);
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

    ElderlyStore.elderlyList[widget.elderlyIndex] = widget.elderlyData;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final workingDays = calculateWorkingDays();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCE3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF564444),
                ),
                label: const Text(
                  'ข้อมูลผู้สูงอายุ',
                  style: TextStyle(color: Color(0xFF564444)),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Icon(
                  Icons.account_circle_outlined,
                  size: 110,
                  color: Color(0xFFD5E7FF),
                ),
              ),
              const SizedBox(height: 20),
              buildSectionHeader('ข้อมูลสุขภาพพื้นฐาน'),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildBox(
                          hasError: birthDateError != null,
                          child: InkWell(
                            onTap: pickBirthDate,
                            child: Text(
                              selectedBirthDate == null
                                  ? 'วันเกิด'
                                  : formatThaiDate(selectedBirthDate),
                              style: const TextStyle(
                                color: Color(0xFF564444),
                                fontSize: 14,
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
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildBox(
                          hasError: genderError != null,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonFormField<String>(
                            value: selectedGender,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            hint: const Text('เพศ'),
                            items: genderItems.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(item),
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
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildBox(
                          hasError: weightError != null,
                          child: InkWell(
                            onTap: pickWeightWheel,
                            child: Text(
                              'น้ำหนัก : $selectedWeight กก.',
                              style: const TextStyle(
                                color: Color(0xFF564444),
                                fontSize: 14,
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
              const Text(
                'ที่อยู่',
                style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 10),
              buildBox(
                child: buildEditableTextField(
                  controller: addressController,
                  hintText: 'เลือกจากแผนที่',
                  maxLines: 3,
                  readOnly: true,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: pickLocationFromMap,
                child: Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBEB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text('แตะเพื่อปักหมุดบนแผนที่'),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'วันและเวลาที่จะรับบริการ',
                style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 4),
              const Text(
                '*หมายเหตุ : เลือกระยะเวลาทุกรูปแบบ โดยเลือกเป็น ทุกวัน,วันธรรมดา,เสาร์-อาทิตย์,กำหนดวันเอง,ทุกเดือน,ทุกปี',
                style: TextStyle(fontSize: 12, color: const Color(0xFFF04444)),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildBox(
                          hasError: scheduleTypeError != null,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonFormField<String>(
                            value: selectedScheduleType,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            hint: const Text('ระยะเวลา'),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildBox(
                          hasError: startDateError != null,
                          child: InkWell(
                            onTap: () => pickDate(isStart: true),
                            child: Text(
                              startDate == null
                                  ? 'วันที่เริ่ม'
                                  : 'วันที่เริ่ม : ${formatThaiDate(startDate)}',
                              style: const TextStyle(
                                color: Color(0xFF564444),
                                fontSize: 14,
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
                          color: Color(0xFF564444),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildBox(
                          hasError: endDateError != null,
                          child: InkWell(
                            onTap: () => pickDate(isStart: false),
                            child: Text(
                              endDate == null
                                  ? 'วันสิ้นสุด'
                                  : 'วันสิ้นสุด : ${formatThaiDate(endDate)}',
                              style: const TextStyle(
                                color: Color(0xFF564444),
                                fontSize: 14,
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
                              color: Color(0xFF564444),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Text(
                          ' - ',
                          style: TextStyle(
                            color: Color(0xFF564444),
                            fontSize: 16,
                          ),
                        ),
                        InkWell(
                          onTap: () => pickTime(isStart: false),
                          child: Text(
                            formatTime(endTime),
                            style: const TextStyle(
                              color: Color(0xFF564444),
                              fontSize: 16,
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
                style: TextStyle(fontSize: 18, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5E7FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: salaryUnit,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'วัน', child: Text('วัน')),
                        DropdownMenuItem(value: 'เดือน', child: Text('เดือน')),
                        DropdownMenuItem(value: 'ปี', child: Text('ปี')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          salaryUnit = value!;
                        });
                      },
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
                              Text('${salaryRange.start.round()} บาท'),
                              Text('${salaryRange.end.round()} บาท'),
                            ],
                          ),
                        ),
                        RangeSlider(
                          values: salaryRange,
                          min: 450,
                          max: 100000,
                          divisions: 99550,
                          labels: RangeLabels(
                            salaryRange.start.round().toString(),
                            salaryRange.end.round().toString(),
                          ),
                          onChanged: (RangeValues values) {
                            setState(() {
                              salaryRange = values;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'ความต้องการในการดูแล',
                style: TextStyle(fontSize: 18, color: Color(0xFF564444)),
              ),
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
                child: ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF8FBFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'บันทึก',
                    style: TextStyle(color: Color(0xFF564444)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
