import 'package:carex/User/HomePages/addProfileElderly_three.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/services/backend_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class addProfileElderly_two extends StatefulWidget {
  final ElderlyData elderlyData;

  const addProfileElderly_two({super.key, required this.elderlyData});

  @override
  State<addProfileElderly_two> createState() => _addProfileElderly_twoState();
}

class _addProfileElderly_twoState extends State<addProfileElderly_two> {
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const String kFont = 'Sarabun';

  final List<String> scheduleOptions = [
    'ทุกวัน',
    'วันธรรมดา',
    'เสาร์-อาทิตย์',
    'กำหนดวันเอง',
    'ทุกเดือน',
    'ทุกปี',
  ];

  final List<String> weekDays = [
    'วันจันทร์',
    'วันอังคาร',
    'วันพุธ',
    'วันพฤหัสบดี',
    'วันศุกร์',
    'วันเสาร์',
    'วันอาทิตย์',
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

  String? selectedScheduleType;
  final Set<String> selectedCustomDays = {};

  DateTime? startDate;
  DateTime? endDate;

  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);

  RangeValues salaryRange = const RangeValues(450, 100000);

  String? scheduleTypeError;
  String? customDaysError;
  String? startDateError;
  String? endDateError;
  String? timeError;

  @override
  void initState() {
    super.initState();

    selectedScheduleType = widget.elderlyData.scheduleType.isEmpty
        ? null
        : widget.elderlyData.scheduleType;
    selectedCustomDays.addAll(widget.elderlyData.customDays);

    if (widget.elderlyData.startDate.isNotEmpty) {
      startDate = _parseThaiDate(widget.elderlyData.startDate);
    }
    if (widget.elderlyData.endDate.isNotEmpty) {
      endDate = _parseThaiDate(widget.elderlyData.endDate);
    }
    if (widget.elderlyData.startTime.isNotEmpty) {
      startTime = _parseTime(widget.elderlyData.startTime);
    }
    if (widget.elderlyData.endTime.isNotEmpty) {
      endTime = _parseTime(widget.elderlyData.endTime);
    }

    if (widget.elderlyData.salaryText.isNotEmpty) {
      final match = RegExp(r'(\d+)\s*-\s*(\d+)')
          .firstMatch(widget.elderlyData.salaryText);
      if (match != null) {
        salaryRange = RangeValues(
          double.tryParse(match.group(1) ?? '450') ?? 450,
          double.tryParse(match.group(2) ?? '100000') ?? 100000,
        );
      }
    }
  }

  DateTime? _parseThaiDate(String value) {
    try {
      final parts = value.split(' ');
      if (parts.length != 3) return null;
      final day = int.tryParse(parts[0]);
      final month = thaiMonths.indexOf(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month <= 0 || year == null) return null;
      return DateTime(year - 543, month, day);
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

  String formatThaiDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day} ${thaiMonths[date.month]} ${date.year + 543}';
  }

  String formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
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

  DateTime findNearestSelectableDate(DateTime preferred,
      {required bool isStart}) {
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
            textTheme: Theme.of(context).textTheme.apply(
                  fontFamily: kFont,
                  bodyColor: kText,
                  displayColor: kText,
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
          if (endDate != null &&
              (endDate!.isBefore(startDate!) ||
                  !canSelectDate(endDate!, isStart: false))) {
            endDate = null;
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
            textTheme: Theme.of(context).textTheme.apply(
                  fontFamily: kFont,
                  bodyColor: kText,
                  displayColor: kText,
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
      if (isDateMatched(current)) count++;
      current = current.add(const Duration(days: 1));
    }

    return count;
  }

  String buildDetailedServiceDatesText() {
    if (startDate == null || endDate == null) return '';
    final List<DateTime> dates = [];
    DateTime current = startDate!;

    while (!current.isAfter(endDate!)) {
      if (isDateMatched(current)) dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    if (dates.isEmpty) return '';

    return BackendDataService.formatDateRanges(dates);
  }

  Widget buildBox({
    required Widget child,
    bool hasError = false,
    double height = 42,
    EdgeInsetsGeometry? padding,
    AlignmentGeometry alignment = Alignment.center,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: alignment,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? const Color(0xFFF04444) : kPrimary,
          width: 1.2,
        ),
      ),
      child: child,
    );
  }

  Widget buildFieldError(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Text(
        error,
        style: const TextStyle(
          color: Color(0xFFF04444),
          fontSize: 12,
          fontFamily: kFont,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: kFieldFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: customDaysError != null ? const Color(0xFFF04444) : kPrimary,
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

  void goNext() {
    setState(() {
      scheduleTypeError = null;
      customDaysError = null;
      startDateError = null;
      endDateError = null;
      timeError = null;
    });

    bool isValid = true;

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

    final totalDays = calculateWorkingDays();
    if (selectedScheduleType != null &&
        startDate != null &&
        endDate != null &&
        totalDays <= 0) {
      endDateError = 'ไม่พบจำนวนวันทำงาน กรุณาตรวจสอบข้อมูลอีกครั้ง';
      isValid = false;
    }

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    if (startMinutes == endMinutes) {
      timeError = 'เวลาเริ่มและเวลาสิ้นสุดต้องไม่เท่ากัน';
      isValid = false;
    }

    setState(() {});
    if (!isValid) return;

    widget.elderlyData.scheduleType = selectedScheduleType ?? '';
    widget.elderlyData.customDays = selectedCustomDays.toList();
    widget.elderlyData.startDate = formatThaiDate(startDate);
    widget.elderlyData.endDate = formatThaiDate(endDate);
    widget.elderlyData.startTime = formatTime(startTime);
    widget.elderlyData.endTime = formatTime(endTime);
    widget.elderlyData.salaryText =
        '${salaryRange.start.round()} - ${salaryRange.end.round()} บาท / วัน';
    widget.elderlyData.serviceDatesText = buildDetailedServiceDatesText();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            addProfileElderly_three(elderlyData: widget.elderlyData),
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

  Widget _buildDropdownSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildBox(
          hasError: scheduleTypeError != null,
          height: 40,
          alignment: Alignment.centerLeft,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedScheduleType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: kPrimary),
              hint: const Text(
                'ระยะเวลา',
                style: TextStyle(
                  color: kText,
                  fontSize: 14,
                  fontFamily: kFont,
                ),
              ),
              items: scheduleOptions
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: kText,
                          fontSize: 14,
                          fontFamily: kFont,
                        ),
                      ),
                    ),
                  )
                  .toList(),
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
        ),
        buildFieldError(scheduleTypeError),
      ],
    );
  }

  Widget _buildDateStartField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => pickDate(isStart: true),
          child: buildBox(
            hasError: startDateError != null,
            height: 40,
            alignment: Alignment.center,
            child: Text(
              startDate == null
                  ? 'วันที่เริ่ม'
                  : 'วันที่เริ่ม : ${BackendDataService.toThaiDateWithDay(startDate!)}',
              style: const TextStyle(
                color: kText,
                fontSize: 14,
                fontFamily: kFont,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        buildFieldError(startDateError),
      ],
    );
  }

  Widget _buildWorkingDaysField(int workingDays) {
    return buildBox(
      height: 40,
      child: Text(
        '$workingDays วัน',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: kText,
          fontSize: 16,
          fontFamily: kFont,
        ),
      ),
    );
  }

  Widget _buildDateEndField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => pickDate(isStart: false),
          child: buildBox(
            hasError: endDateError != null,
            height: 40,
            alignment: Alignment.center,
            child: Text(
              endDate == null
                  ? 'วันที่สิ้นสุด'
                  : 'วันที่สิ้นสุด : ${BackendDataService.toThaiDateWithDay(endDate!)}',
              style: const TextStyle(
                color: kText,
                fontSize: 14,
                fontFamily: kFont,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        buildFieldError(endDateError),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildBox(
          hasError: timeError != null,
          height: 40,
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
    );
  }

  Widget _buildSalarySection() {
    final double startValue = salaryRange.start;
    final double endValue = salaryRange.end;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              width: 64,
              height: 40,
              alignment: Alignment.center,
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
              child: SizedBox(
                height: 52,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${startValue.round()} บาท',
                            style: const TextStyle(
                              fontSize: 11,
                              color: kText,
                              fontFamily: kFont,
                            ),
                          ),
                          Text(
                            '${endValue.round()} บาท',
                            style: const TextStyle(
                              fontSize: 11,
                              color: kText,
                              fontFamily: kFont,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 10,
                      bottom: 0,
                      child: SliderTheme(
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
                          showValueIndicator: ShowValueIndicator.never,
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
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
              fontSize: 16,
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
                const SizedBox(height: 36),
                const Text(
                  'วันและเวลาที่จะรับบริการ',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '*หมายเหตุ : เลือกระยะที่ต้องการดูแล โดยเลือกเป็น ทุกวัน,วันธรรมดา,เสาร์-อาทิตย์,\nกำหนดวันเอง,ทุกเดือน,ทุกปี',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFF04444),
                    fontFamily: kFont,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildDropdownSchedule(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: _buildDateStartField(),
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
                      flex: 4,
                      child: _buildWorkingDaysField(workingDays),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: _buildDateEndField(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildTimeField(),
                const SizedBox(height: 14),
                _buildSalarySection(),
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
