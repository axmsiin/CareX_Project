import 'package:carex/User/HomePages/addProfileElderly_three.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:flutter/material.dart';

class addProfileElderly_two extends StatefulWidget {
  final ElderlyData elderlyData;

  const addProfileElderly_two({super.key, required this.elderlyData});

  @override
  State<addProfileElderly_two> createState() => _addProfileElderly_twoState();
}

class _addProfileElderly_twoState extends State<addProfileElderly_two> {
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
      final match = RegExp(
        r'(\d+)\s*-\s*(\d+)',
      ).firstMatch(widget.elderlyData.salaryText);
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

  String formatThaiDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day} ${thaiMonths[date.month]} ${date.year + 543}';
  }

  String formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h.$m';
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

  List<DateTime> getMatchedDates() {
    if (startDate == null || endDate == null || selectedScheduleType == null) {
      return [];
    }

    final List<DateTime> dates = [];
    DateTime current = startDate!;

    while (!current.isAfter(endDate!)) {
      if (isDateMatched(current)) {
        dates.add(current);
      }
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  String buildDetailedServiceDatesText() {
    final dates = getMatchedDates();
    if (dates.isEmpty) return '';

    final Map<int, Map<int, List<int>>> groupedByYearAndMonth = {};

    for (final date in dates) {
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

  Widget buildBox({
    required Widget child,
    EdgeInsetsGeometry? padding,
    bool hasError = false,
  }) {
    return Container(
      width: double.infinity,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAFF),
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
        style: const TextStyle(color: Color(0xFFF04444), fontSize: 12),
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
          color: const Color(0xFFFCFAFF),
          borderRadius: BorderRadius.circular(14),
          border: customDaysError != null
              ? Border.all(color: const Color(0xFFF04444))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: const Color(0xFFEE711E),
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

    setState(() {});

    if (!isValid) return;

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

  @override
  Widget build(BuildContext context) {
    final workingDays = calculateWorkingDays();

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
                'วันและเวลาที่จะรับบริการ',
                style: TextStyle(fontSize: 18, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 4),
              const Text(
                '*หมายเหตุ : เลือกระยะเวลาทุกรูปแบบ โดยเลือกเป็น ทุกวัน,วันธรรมดา,เสาร์-อาทิตย์,กำหนดวันเอง,ทุกเดือน,ทุกปี',
                style: TextStyle(fontSize: 12, color: Color(0xFFF04444)),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCFAFF),
                            borderRadius: BorderRadius.circular(14),
                            border: scheduleTypeError != null
                                ? Border.all(color: const Color(0xFFF04444))
                                : null,
                          ),
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
                        InkWell(
                          onTap: () => pickDate(isStart: true),
                          child: buildBox(
                            hasError: startDateError != null,
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
                        InkWell(
                          onTap: () => pickDate(isStart: false),
                          child: buildBox(
                            hasError: endDateError != null,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFAFF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'วัน',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF564444),
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
                                  color: Color(0xFF564444),
                                ),
                              ),
                              Text(
                                '${salaryRange.end.round()} บาท',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF564444),
                                ),
                              ),
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
              const SizedBox(height: 16),
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
