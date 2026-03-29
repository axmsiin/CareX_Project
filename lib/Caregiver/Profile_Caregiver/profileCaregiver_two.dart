import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carex/Caregiver/Profile_Caregiver/question.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';

class profileCaregiver_two extends StatefulWidget {
  final caregiverData profile;

  const profileCaregiver_two({super.key, required this.profile});

  @override
  State<profileCaregiver_two> createState() => _profileCaregiver_twoState();
}

class _profileCaregiver_twoState extends State<profileCaregiver_two> {
  final List<String> days = [
    'วันจันทร์',
    'วันอังคาร',
    'วันพุธ',
    'วันพฤหัสบดี',
    'วันศุกร์',
    'วันเสาร์',
    'วันอาทิตย์',
  ];

  final Set<String> selectedDays = {};

  final List<String> degrees = [
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

  final List<String> thaiMonths = [
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
      selectedDegree = widget.profile.degree;
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

    final picked = await showTimePicker(context: context, initialTime: initial);

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
      builder: (context) {
        return Container(
          height: 320,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'เลือกวันที่จบการศึกษา',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
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
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    graduationDate = tempDate;
                    graduationDateError = null;
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAFF),
          borderRadius: BorderRadius.circular(14),
          border: selectedDaysError != null
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
              style: const TextStyle(fontSize: 16, color: Color(0xFF564444)),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAFF),
          borderRadius: BorderRadius.circular(14),
          border: selectedDegreeError != null
              ? Border.all(color: const Color(0xFFF04444))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: const Color(0xFFEE711E),
            ),
            const SizedBox(width: 10),
            Text(
              degree,
              style: const TextStyle(fontSize: 16, color: Color(0xFF564444)),
            ),
          ],
        ),
      ),
    );
  }

  void goNext() {
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
    widget.profile.degree = selectedDegree ?? '';
    widget.profile.graduationDate = graduationDate;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => question(profile: widget.profile),
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
                  'ย้อนกลับ',
                  style: TextStyle(color: Color(0xFF564444)),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'วันและเวลาที่สะดวก',
                style: TextStyle(fontSize: 18, color: Color(0xFF564444)),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSelectBox(
                    hasError: timeError != null,
                    child: Column(
                      children: [
                        CheckboxListTile(
                          value: allDayAvailable,
                          onChanged: (value) {
                            setState(() {
                              allDayAvailable = value ?? false;
                              if (allDayAvailable) {
                                timeError = null;
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text(
                            'สะดวกตลอดเวลา',
                            style: TextStyle(color: Color(0xFF564444)),
                          ),
                          activeColor: const Color(0xFFEE711E),
                        ),
                        if (!allDayAvailable)
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => pickTime(isStartTime: true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      formatTime(startTime),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF564444),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                ' - ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF564444),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => pickTime(isStartTime: false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      formatTime(endTime),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF564444),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                ' น.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF564444),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  buildFieldError(timeError),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'วุฒิประกาศนียบัตร',
                style: TextStyle(fontSize: 18, color: Color(0xFF564444)),
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
                style: TextStyle(fontSize: 18, color: Color(0xFF564444)),
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
                          fontSize: 16,
                          color: Color(0xFF564444),
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
