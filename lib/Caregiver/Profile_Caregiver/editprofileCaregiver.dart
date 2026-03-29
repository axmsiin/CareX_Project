import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/map.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiver_store.dart';
import 'package:carex/services/backend_data_service.dart';

class editprofileCaregiver extends StatefulWidget {
  final caregiverData profile;

  const editprofileCaregiver({
    super.key,
    required this.profile,
  });

  @override
  State<editprofileCaregiver> createState() => _EditProfileCaregiverPageState();
}

class _EditProfileCaregiverPageState extends State<editprofileCaregiver> {
  late final TextEditingController fullNameController;
  late final TextEditingController nickNameController;
  late final TextEditingController phoneController;
  final TextEditingController addressController = TextEditingController();

  DateTime? selectedBirthDate;
  int selectedWeight = 65;
  int selectedHeight = 175;
  String? selectedGender;

  final List<String> selectedDays = [];
  bool allDayAvailable = false;
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);

  String? selectedDegree;
  DateTime? selectedGraduationDate;
  String selectedProvince = '';

  double? selectedLatitude;
  double? selectedLongitude;

  final List<String> genderItems = ['ชาย', 'หญิง', 'ไม่ระบุ'];

  final List<String> days = [
    'วันจันทร์',
    'วันอังคาร',
    'วันพุธ',
    'วันพฤหัสบดี',
    'วันศุกร์',
    'วันเสาร์',
    'วันอาทิตย์',
  ];

  final List<String> degrees = [
    'Practical Nurse (PN)',
    'Nursing Assistant (NA)',
    'Caregiver (CG)',
  ];

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

  final List<String> provinces = const [
    'กรุงเทพมหานคร',
    'กระบี่',
    'กาญจนบุรี',
    'กาฬสินธุ์',
    'กำแพงเพชร',
    'ขอนแก่น',
    'จันทบุรี',
    'ฉะเชิงเทรา',
    'ชลบุรี',
    'ชัยนาท',
    'ชัยภูมิ',
    'ชุมพร',
    'เชียงราย',
    'เชียงใหม่',
    'ตรัง',
    'ตราด',
    'ตาก',
    'นครนายก',
    'นครปฐม',
    'นครพนม',
    'นครราชสีมา',
    'นครศรีธรรมราช',
    'นครสวรรค์',
    'นนทบุรี',
    'นราธิวาส',
    'น่าน',
    'บึงกาฬ',
    'บุรีรัมย์',
    'ปทุมธานี',
    'ประจวบคีรีขันธ์',
    'ปราจีนบุรี',
    'ปัตตานี',
    'พระนครศรีอยุธยา',
    'พังงา',
    'พัทลุง',
    'พิจิตร',
    'พิษณุโลก',
    'เพชรบุรี',
    'เพชรบูรณ์',
    'แพร่',
    'พะเยา',
    'ภูเก็ต',
    'มหาสารคาม',
    'มุกดาหาร',
    'แม่ฮ่องสอน',
    'ยโสธร',
    'ยะลา',
    'ร้อยเอ็ด',
    'ระนอง',
    'ระยอง',
    'ราชบุรี',
    'ลพบุรี',
    'ลำปาง',
    'ลำพูน',
    'เลย',
    'ศรีสะเกษ',
    'สกลนคร',
    'สงขลา',
    'สตูล',
    'สมุทรปราการ',
    'สมุทรสงคราม',
    'สมุทรสาคร',
    'สระแก้ว',
    'สระบุรี',
    'สิงห์บุรี',
    'สุโขทัย',
    'สุพรรณบุรี',
    'สุราษฎร์ธานี',
    'สุรินทร์',
    'หนองคาย',
    'หนองบัวลำภู',
    'อ่างทอง',
    'อำนาจเจริญ',
    'อุดรธานี',
    'อุตรดิตถ์',
    'อุทัยธานี',
    'อุบลราชธานี',
  ];

  @override
  void initState() {
    super.initState();

    fullNameController = TextEditingController(text: widget.profile.fullName);
    nickNameController = TextEditingController(text: widget.profile.nickName);
    phoneController = TextEditingController(text: widget.profile.phone);
    addressController.text = widget.profile.address;

    selectedBirthDate = widget.profile.birthDate;
    selectedWeight = widget.profile.weight == 0 ? 65 : widget.profile.weight;
    selectedHeight = widget.profile.height == 0 ? 175 : widget.profile.height;
    selectedGender =
        widget.profile.gender.isEmpty ? null : widget.profile.gender;

    selectedDays.addAll(widget.profile.availableDays);
    allDayAvailable = widget.profile.allDayAvailable;
    selectedProvince = widget.profile.province;

    if (widget.profile.startTime.isNotEmpty) {
      final parts = widget.profile.startTime.split('.');
      if (parts.length == 2) {
        startTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    if (widget.profile.endTime.isNotEmpty) {
      final parts = widget.profile.endTime.split('.');
      if (parts.length == 2) {
        endTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 18,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    selectedDegree =
        widget.profile.degree.isEmpty ? null : widget.profile.degree;
    selectedGraduationDate = widget.profile.graduationDate;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    nickNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  String formatThaiDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day} ${thaiMonths[date.month]} ${date.year + 543}';
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
  }

  Future<void> pickBirthDate() async {
    DateTime tempDate = selectedBirthDate ?? DateTime(2004, 3, 2);

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

  Future<void> pickGraduationDate() async {
    DateTime tempDate = selectedGraduationDate ?? DateTime(2025, 12, 25);

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
                    selectedGraduationDate = tempDate;
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

  Future<void> pickNumberWheel({
    required String title,
    required int min,
    required int max,
    required int currentValue,
    required ValueChanged<int> onSelected,
  }) async {
    int tempValue = currentValue;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 320,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: currentValue - min,
                  ),
                  onSelectedItemChanged: (index) {
                    tempValue = min + index;
                  },
                  children: List.generate(
                    max - min + 1,
                    (index) => Center(child: Text('${min + index}')),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  onSelected(tempValue);
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

  Future<void> pickTime({required bool isStartTime}) async {
    int selectedHour = isStartTime ? startTime.hour : endTime.hour;
    int selectedMinute = isStartTime ? startTime.minute : endTime.minute;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 320,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    isStartTime ? 'เลือกเวลาเริ่ม' : 'เลือกเวลาสิ้นสุด',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedHour,
                            ),
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                selectedHour = index;
                              });
                            },
                            children: List.generate(
                              24,
                              (index) => Center(
                                child: Text(index.toString().padLeft(2, '0')),
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          ':',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedMinute ~/ 5,
                            ),
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                selectedMinute = index * 5;
                              });
                            },
                            children: List.generate(
                              12,
                              (index) => Center(
                                child: Text(
                                    (index * 5).toString().padLeft(2, '0')),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (isStartTime) {
                          startTime = TimeOfDay(
                            hour: selectedHour,
                            minute: selectedMinute,
                          );
                        } else {
                          endTime = TimeOfDay(
                            hour: selectedHour,
                            minute: selectedMinute,
                          );
                        }
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
      },
    );
  }

  Future<void> pickProvinceSearchable() async {
    final TextEditingController searchController = TextEditingController();
    List<String> filtered = List.from(provinces);
    String tempProvince =
        selectedProvince.isEmpty ? provinces.first : selectedProvince;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            int currentIndex = filtered.indexOf(tempProvince);
            if (currentIndex < 0) currentIndex = 0;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                height: 420,
                child: Column(
                  children: [
                    const Text(
                      'ค้นหาจังหวัด',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'พิมพ์ชื่อจังหวัด',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFFCFAFF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          filtered = provinces
                              .where((p) => p.contains(value.trim()))
                              .toList();
                          if (filtered.isNotEmpty &&
                              !filtered.contains(tempProvince)) {
                            tempProvince = filtered.first;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('ไม่พบจังหวัด'))
                          : CupertinoPicker(
                              itemExtent: 40,
                              scrollController: FixedExtentScrollController(
                                initialItem: currentIndex,
                              ),
                              onSelectedItemChanged: (index) {
                                tempProvince = filtered[index];
                              },
                              children: filtered
                                  .map((province) =>
                                      Center(child: Text(province)))
                                  .toList(),
                            ),
                    ),
                    ElevatedButton(
                      onPressed: filtered.isEmpty
                          ? null
                          : () {
                              setState(() {
                                selectedProvince = tempProvince;
                              });
                              Navigator.pop(context);
                            },
                      child: const Text('ตกลง'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> pickLocationFromMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const map()),
    );

    if (result != null) {
      setState(() {
        addressController.text = result['address'] ?? '';
        selectedProvince = result['province'] ?? '';
        selectedLatitude = result['latitude'];
        selectedLongitude = result['longitude'];
      });
    }
  }

  Widget buildBox({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
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
      decoration: InputDecoration.collapsed(
        hintText: hintText,
      ),
      style: const TextStyle(
        color: Color(0xFF564444),
        fontSize: 14,
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
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: const Color(0xFFEE711E),
            ),
            const SizedBox(width: 8),
            Text(
              day,
              style: const TextStyle(color: Color(0xFF564444), fontSize: 14),
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
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: const Color(0xFFEE711E),
            ),
            const SizedBox(width: 8),
            Text(
              degree,
              style: const TextStyle(color: Color(0xFF564444), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveProfile() async {
    FocusScope.of(context).unfocus();

    widget.profile.fullName = fullNameController.text.trim();
    widget.profile.nickName = nickNameController.text.trim();
    widget.profile.phone = phoneController.text.trim();
    widget.profile.birthDate = selectedBirthDate;
    widget.profile.weight = selectedWeight;
    widget.profile.height = selectedHeight;
    widget.profile.gender = selectedGender ?? '';
    widget.profile.address = addressController.text.trim();
    widget.profile.province = selectedProvince;
    widget.profile.availableDays = List.from(selectedDays);
    widget.profile.allDayAvailable = allDayAvailable;
    widget.profile.startTime = formatTime(startTime);
    widget.profile.endTime = formatTime(endTime);
    widget.profile.degree = selectedDegree ?? '';
    widget.profile.graduationDate = selectedGraduationDate;

    final ok = await BackendDataService.updateCaregiverProfile(widget.profile);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อัปเดตข้อมูลผู้ดูแลลงฐานข้อมูลไม่สำเร็จ')),
      );
      return;
    }

    await CaregiverStore.syncFromBackend();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              const SizedBox(height: 8),
              const Center(
                child: Icon(
                  Icons.account_circle_outlined,
                  size: 100,
                  color: Color(0xFFFCFAFF),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ข้อมูลสุขภาพพื้นฐาน',
                style: TextStyle(fontSize: 18, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: buildBox(
                      child: buildEditableTextField(
                        controller: fullNameController,
                        hintText: 'ชื่อ-นามสกุล',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildBox(
                      child: buildEditableTextField(
                        controller: nickNameController,
                        hintText: 'ชื่อเล่น',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: buildBox(
                      child: buildEditableTextField(
                        controller: phoneController,
                        hintText: 'เบอร์โทรศัพท์',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildBox(
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
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: buildBox(
                      child: InkWell(
                        onTap: () {
                          pickNumberWheel(
                            title: 'เลือกน้ำหนัก',
                            min: 20,
                            max: 150,
                            currentValue: selectedWeight,
                            onSelected: (value) {
                              setState(() {
                                selectedWeight = value;
                              });
                            },
                          );
                        },
                        child: Text(
                          'น้ำหนัก : $selectedWeight',
                          style: const TextStyle(
                            color: Color(0xFF564444),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildBox(
                      child: InkWell(
                        onTap: () {
                          pickNumberWheel(
                            title: 'เลือกส่วนสูง',
                            min: 100,
                            max: 220,
                            currentValue: selectedHeight,
                            onSelected: (value) {
                              setState(() {
                                selectedHeight = value;
                              });
                            },
                          );
                        },
                        child: Text(
                          'ส่วนสูง : $selectedHeight',
                          style: const TextStyle(
                            color: Color(0xFF564444),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildBox(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration:
                            const InputDecoration(border: InputBorder.none),
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
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'วันและเวลาที่สะดวก',
                style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 10),
              ...days.map(
                (day) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: buildDayBox(day),
                ),
              ),
              buildBox(
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: allDayAvailable,
                      onChanged: (value) {
                        setState(() {
                          allDayAvailable = value ?? false;
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
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  formatTime(startTime),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF564444),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Text(
                            ' - ',
                            style: TextStyle(color: Color(0xFF564444)),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => pickTime(isStartTime: false),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  formatTime(endTime),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF564444),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Text(
                            ' น.',
                            style: TextStyle(color: Color(0xFF564444)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
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
                  decoration: BoxDecoration(color: const Color(0xFFEBEBEB)),
                  alignment: Alignment.center,
                  child: const Text(
                    'แตะเพื่อปักหมุดบนแผนที่',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'ระยะทางที่สะดวก',
                style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 10),
              buildBox(
                child: InkWell(
                  onTap: pickProvinceSearchable,
                  child: Text(
                    selectedProvince.isEmpty
                        ? 'เลือกจังหวัด'
                        : 'จังหวัด : $selectedProvince',
                    style: const TextStyle(
                      color: Color(0xFF564444),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'วุฒิประกาศนียบัตร',
                style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 10),
              ...degrees.map(
                (degree) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: buildDegreeBox(degree),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'วันที่จบการศึกษา',
                style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 10),
              buildBox(
                child: InkWell(
                  onTap: pickGraduationDate,
                  child: Text(
                    formatThaiDate(selectedGraduationDate),
                    style: const TextStyle(
                      color: Color(0xFF564444),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFEE711E),
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
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFFFCFAFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.home, size: 36, color: const Color(0xFFEE711E)),
            Icon(Icons.notifications, size: 34, color: const Color(0xFFEE711E)),
            Icon(Icons.account_circle,
                size: 36, color: const Color(0xFFEE711E)),
          ],
        ),
      ),
    );
  }
}
