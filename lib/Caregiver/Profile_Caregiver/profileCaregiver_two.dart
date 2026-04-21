import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carex/Caregiver/Profile_Caregiver/question.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiver_store.dart';

class profileCaregiver_two extends StatefulWidget {
  final caregiverData profile;

  const profileCaregiver_two({super.key, required this.profile});

  @override
  State<profileCaregiver_two> createState() => _profileCaregiver_twoState();
}

class _profileCaregiver_twoState extends State<profileCaregiver_two> {
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const Color kError = Color(0xFFE95257);
  static const String kFont = 'Sarabun';

  final List<String> days = const [
    'วันจันทร์',
    'วันอังคาร',
    'วันพุธ',
    'วันพฤหัสบดี',
    'วันศุกร์',
    'วันเสาร์',
    'วันอาทิตย์',
  ];

  final Set<String> selectedDays = {};

  final List<String> degrees = const [
    'Practical Nurse (PN)',
    'Nursing Assistant (NA)',
    'Caregiver (CG)',
  ];

  String? selectedDegree;
  bool allDayAvailable = false;

  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);

  DateTime? graduationDate;

  String? selectedDaysError;
  String? selectedDegreeError;
  String? graduationDateError;
  String? timeError;

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

    selectedDays.addAll(widget.profile.availableDays);
    allDayAvailable = widget.profile.allDayAvailable;

    if (widget.profile.startTime.isNotEmpty) {
      final normalized = widget.profile.startTime.replaceAll('.', ':');
      final parts = normalized.split(':');
      if (parts.length == 2) {
        startTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    if (widget.profile.endTime.isNotEmpty) {
      final normalized = widget.profile.endTime.replaceAll('.', ':');
      final parts = normalized.split(':');
      if (parts.length == 2) {
        endTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 18,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    if (widget.profile.degree.isNotEmpty) {
      final saved = widget.profile.degree.trim();
      if (saved == 'Practical Nurse') {
        selectedDegree = 'Practical Nurse (PN)';
      } else if (saved == 'Nurse Aide') {
        selectedDegree = 'Nursing Assistant (NA)';
      } else if (saved == 'Caregiver') {
        selectedDegree = 'Caregiver (CG)';
      } else {
        selectedDegree = saved;
      }
    }

    graduationDate = widget.profile.graduationDate;
  }

  String formatThaiDate(DateTime? date) {
    if (date == null) return 'วันที่จบการศึกษา';
    return '${date.day} ${thaiMonths[date.month]} ${date.year + 543}';
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String normalizedDegreeForSave(String? value) {
    switch (value) {
      case 'Practical Nurse (PN)':
        return 'Practical Nurse';
      case 'Nursing Assistant (NA)':
        return 'Nurse Aide';
      case 'Caregiver (CG)':
        return 'Caregiver';
      default:
        return value ?? '';
    }
  }

  List<Map<String, dynamic>> buildTimestampPayload() {
    final effectiveStart = allDayAvailable ? '00:00' : formatTime(startTime);
    final effectiveEnd = allDayAvailable ? '00:00' : formatTime(endTime);

    return selectedDays.map((day) {
      return {
        'day': day,
        'start_time': effectiveStart,
        'end_time': effectiveEnd,
      };
    }).toList();
  }

  Future<void> pickTime({required bool isStartTime}) async {
    final initial = isStartTime ? startTime : endTime;

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
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
        timeError = null;
      });
    }
  }

  Future<void> pickGraduationDate() async {
    DateTime tempDate = graduationDate ?? DateTime(2025, 12, 25);

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
                'เลือกวันที่จบการศึกษา',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kText,
                  fontFamily: kFont,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${tempDate.day} ${thaiMonths[tempDate.month]} ${tempDate.year + 543}',
                style: const TextStyle(
                  fontSize: 14,
                  color: kPrimary,
                  fontWeight: FontWeight.w500,
                  fontFamily: kFont,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 14,
                        color: kText,
                        fontFamily: kFont,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: tempDate,
                    minimumDate: DateTime(1950, 1, 1),
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (DateTime newDate) {
                      tempDate = newDate;
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    graduationDate = tempDate;
                    graduationDateError = null;
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

  Widget buildSelectBox({
    required Widget child,
    EdgeInsetsGeometry? padding,
    bool hasError = false,
  }) {
    return Container(
      width: double.infinity,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
          fontSize: 14,
          fontFamily: kFont,
        ),
      ),
    );
  }

  Widget buildDayBox(String day) {
    final isSelected = selectedDays.contains(day);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedDays.remove(day);
          } else {
            selectedDays.add(day);
          }
          if (selectedDays.isNotEmpty) {
            selectedDaysError = null;
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
            color: selectedDaysError != null ? kError : kPrimary,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: kPrimary,
              size: 24,
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

  Widget buildDegreeBox(String degree) {
    final isSelected = selectedDegree == degree;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDegree = degree;
          selectedDegreeError = null;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: kFieldFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selectedDegreeError != null ? kError : kPrimary,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: kPrimary,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              degree,
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

  Future<void> goNext() async {
    setState(() {
      selectedDaysError = null;
      selectedDegreeError = null;
      graduationDateError = null;
      timeError = null;
    });

    bool isValid = true;

    if (selectedDays.isEmpty) {
      selectedDaysError = 'กรุณาเลือกวันที่สะดวกทำงาน';
      isValid = false;
    }

    if (selectedDegree == null) {
      selectedDegreeError = 'กรุณาเลือกวุฒิประกาศนียบัตร';
      isValid = false;
    }

    if (graduationDate == null) {
      graduationDateError = 'กรุณาเลือกวันที่จบการศึกษา';
      isValid = false;
    }

    if (!allDayAvailable) {
      final startMinutes = startTime.hour * 60 + startTime.minute;
      final endMinutes = endTime.hour * 60 + endTime.minute;

      if (startMinutes == endMinutes) {
        timeError = 'เวลาเริ่มและเวลาสิ้นสุดต้องไม่เท่ากัน';
        isValid = false;
      }
    }

    setState(() {});
    if (!isValid) return;

    widget.profile.availableDays = selectedDays.toList();
    widget.profile.allDayAvailable = allDayAvailable;
    widget.profile.startTime =
        allDayAvailable ? '00:00' : formatTime(startTime);
    widget.profile.endTime = allDayAvailable ? '00:00' : formatTime(endTime);
    widget.profile.degree = normalizedDegreeForSave(selectedDegree);
    widget.profile.graduationDate = graduationDate;

    await CaregiverStore.save(widget.profile);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => question(profile: widget.profile),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'ย้อนกลับ',
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
          Icon(Icons.home, size: 40, color: kPrimary),
          Icon(Icons.notifications, size: 40, color: kPrimary),
          Icon(Icons.account_circle, size: 44, color: kWhite),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayTimeText = allDayAvailable
        ? 'เวลา : ตลอดทั้งวัน'
        : 'เวลา : ${formatTime(startTime)} - ${formatTime(endTime)} น.';

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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 22),
                const Text(
                  'วันและเวลาที่สะดวก',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                ...days.map(
                  (day) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: buildDayBox(day),
                  ),
                ),
                buildFieldError(selectedDaysError),
                const SizedBox(height: 6),
                SizedBox(
                  width: 176,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        allDayAvailable = !allDayAvailable;
                        if (allDayAvailable) {
                          timeError = null;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: kFieldFill,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kPrimary, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            allDayAvailable
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: kPrimary,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'สะดวกทุกช่วงเวลา',
                            style: TextStyle(
                              color: kText,
                              fontSize: 14,
                              fontFamily: kFont,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSelectBox(
                      hasError: timeError != null,
                      child: InkWell(
                        onTap: allDayAvailable
                            ? null
                            : () async {
                                await pickTime(isStartTime: true);
                                if (!mounted) return;
                                await pickTime(isStartTime: false);
                              },
                        child: Text(
                          displayTimeText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: allDayAvailable ? kText : kText,
                            fontFamily: kFont,
                          ),
                        ),
                      ),
                    ),
                    buildFieldError(timeError),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'วุฒิประกาศนียบัตร',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                ...degrees.map(
                  (degree) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: buildDegreeBox(degree),
                  ),
                ),
                buildFieldError(selectedDegreeError),
                const SizedBox(height: 10),
                const Text(
                  'วันที่จบการศึกษา',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: pickGraduationDate,
                      child: buildSelectBox(
                        hasError: graduationDateError != null,
                        child: Text(
                          formatThaiDate(graduationDate),
                          style: const TextStyle(
                            fontSize: 14,
                            color: kText,
                            fontFamily: kFont,
                          ),
                        ),
                      ),
                    ),
                    buildFieldError(graduationDateError),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 86,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: goNext,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'ถัดไป',
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
