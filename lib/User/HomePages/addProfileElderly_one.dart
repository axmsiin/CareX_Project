import 'package:carex/User/HomePages/addProfilrElderly_two.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carex/map.dart';

class addProfileElderly_one extends StatefulWidget {
  const addProfileElderly_one({super.key});

  @override
  State<addProfileElderly_one> createState() => _addProfileElderly_oneState();
}

class _addProfileElderly_oneState extends State<addProfileElderly_one> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  DateTime? selectedBirthDate;
  String? selectedGender;
  int selectedWeight = 69;

  List<String?> selectedDiseaseList = [null];

  double? selectedLatitude;
  double? selectedLongitude;

  String? fullNameError;
  String? nickNameError;
  String? phoneError;
  String? birthDateError;
  String? genderError;
  String? weightError;
  String? diseaseError;

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

  String formatDate(DateTime? date) {
    if (date == null) return 'วันเกิด';
    return '${date.day} ${thaiMonths[date.month]} ${date.year}';
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

  Widget buildInputBox({
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
        borderRadius: BorderRadius.circular(12),
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

  List<String?> _normalizeDiseaseSelections(List<String?> values) {
    final result = <String?>[];

    for (final value in values) {
      if (value == null) {
        result.add(null);
        break;
      }

      result.add(value);

      if (value == 'ไม่มีโรค') {
        return ['ไม่มีโรค'];
      }
    }

    final actualDiseases = result
        .where((e) => e != null && e != 'ไม่มีโรค')
        .cast<String>()
        .toList();

    if (actualDiseases.isEmpty) {
      return [null];
    }

    return [...actualDiseases, null];
  }

  List<String> _getAvailableDiseaseOptions({
    required List<String?> currentSelections,
    required int currentIndex,
  }) {
    final currentValue = currentSelections[currentIndex];

    final selectedByOthers = <String>{};
    for (int i = 0; i < currentSelections.length; i++) {
      if (i == currentIndex) continue;
      final value = currentSelections[i];
      if (value != null && value != 'ไม่มีโรค') {
        selectedByOthers.add(value);
      }
    }

    return diseaseItems.where((option) {
      if (option == 'ไม่มีโรค') return true;
      if (option == currentValue) return true;
      return !selectedByOthers.contains(option);
    }).toList();
  }

  void _updateDiseaseSelection({
    required int index,
    required String? newValue,
  }) {
    final updated = List<String?>.from(selectedDiseaseList);
    updated[index] = newValue;
    selectedDiseaseList = _normalizeDiseaseSelections(updated);
  }

  String _convertDiseaseToStorage() {
    final actualValues = selectedDiseaseList
        .where((e) => e != null && e != 'ไม่มีโรค')
        .cast<String>()
        .toList();

    if (actualValues.isEmpty) return 'ไม่มีโรค';
    return actualValues.join('|');
  }

  Widget buildDiseaseDropdownGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(selectedDiseaseList.length, (index) {
          final availableOptions = _getAvailableDiseaseOptions(
            currentSelections: selectedDiseaseList,
            currentIndex: index,
          );

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == selectedDiseaseList.length - 1 ? 0 : 10,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFD5E7FF),
                borderRadius: BorderRadius.circular(12),
                border: diseaseError != null
                    ? Border.all(color: const Color(0xFFF04444))
                    : null,
              ),
              child: DropdownButtonFormField<String>(
                value: selectedDiseaseList[index],
                decoration: const InputDecoration(border: InputBorder.none),
                hint: const Text('โรคประจำตัว'),
                items: availableOptions.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _updateDiseaseSelection(index: index, newValue: value);
                    diseaseError = null;
                  });
                },
              ),
            ),
          );
        }),
        buildFieldError(diseaseError),
      ],
    );
  }

  void goNext() {
    setState(() {
      fullNameError = null;
      nickNameError = null;
      phoneError = null;
      birthDateError = null;
      genderError = null;
      weightError = null;
      diseaseError = null;
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

    setState(() {});

    if (!isValid) return;

    final elderlyData = ElderlyData(
      fullName: fullNameController.text.trim(),
      nickName: nickNameController.text.trim(),
      phone: phoneController.text.trim(),
      birthDate: formatDate(selectedBirthDate),
      gender: selectedGender ?? '',
      weight: selectedWeight.toString(),
      disease: _convertDiseaseToStorage(),
      address: addressController.text.trim(),
      startDate: '',
      endDate: '',
      startTime: '',
      endTime: '',
      salaryText: '',
      serviceDatesText: '',
      scheduleType: '',
      customDays: [],
      selectedNeeds: [],
      needLevel: '',
      eatingCare: 'ไม่มี',
      woundCare: 'ไม่มี',
      respiratoryCare: 'ไม่มี',
      monitoringCare: 'ไม่มี',
      status: 'matching',
      caregiver: '',
      matchPercent: '',
      caregiverPhone: '',
      caregiverGender: '',
      caregiverAge: '',
      caregiverProvince: '',
      caregiverExperience: '',
      caregiverRating: '',
      caregiverReviewCount: '',
      caregiverBio: '',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => addProfileElderly_two(elderlyData: elderlyData),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCE3),
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
              const SizedBox(height: 8),
              const Center(
                child: Icon(
                  Icons.account_circle_outlined,
                  size: 110,
                  color: Color(0xFFD5E7FF),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ข้อมูลสุขภาพพื้นฐาน',
                style: TextStyle(fontSize: 18, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildInputBox(
                          hasError: fullNameError != null,
                          child: TextField(
                            controller: fullNameController,
                            onChanged: (value) {
                              if (fullNameError != null) {
                                setState(() {
                                  fullNameError = null;
                                });
                              }
                            },
                            decoration: const InputDecoration.collapsed(
                              hintText: 'ชื่อ-นามสกุล',
                            ),
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
                        buildInputBox(
                          hasError: nickNameError != null,
                          child: TextField(
                            controller: nickNameController,
                            onChanged: (value) {
                              if (nickNameError != null) {
                                setState(() {
                                  nickNameError = null;
                                });
                              }
                            },
                            decoration: const InputDecoration.collapsed(
                              hintText: 'ชื่อเล่น',
                            ),
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
                        buildInputBox(
                          hasError: phoneError != null,
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            onChanged: (value) {
                              if (phoneError != null) {
                                setState(() {
                                  phoneError = null;
                                });
                              }
                            },
                            decoration: const InputDecoration.collapsed(
                              hintText: 'เบอร์โทรศัพท์',
                            ),
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
                        buildInputBox(
                          hasError: birthDateError != null,
                          child: InkWell(
                            onTap: pickBirthDate,
                            child: Text(
                              formatDate(selectedBirthDate),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD5E7FF),
                            borderRadius: BorderRadius.circular(12),
                            border: genderError != null
                                ? Border.all(color: const Color(0xFFF04444))
                                : null,
                          ),
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
                        buildInputBox(
                          hasError: weightError != null,
                          child: InkWell(
                            onTap: pickWeightWheel,
                            child: Text(
                              'น้ำหนัก : $selectedWeight กิโลกรัม',
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
              buildDiseaseDropdownGroup(),
              const SizedBox(height: 18),
              const Text(
                'ที่อยู่',
                style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 10),
              buildInputBox(
                child: TextField(
                  controller: addressController,
                  readOnly: true,
                  maxLines: 3,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'เลือกจากแผนที่',
                  ),
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
                  child: const Text('แผนที่', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: goNext,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF8FBFFF),
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
          color: Color(0xFFD5E7FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home, size: 34, color: Color(0xFF8FBFFF)),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications,
                size: 38,
                color: Color(0xFF003F91),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.account_circle,
                size: 42,
                color: Color(0xFF003F91),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
