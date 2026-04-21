import 'package:carex/User/HomePages/addProfilrElderly_two.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/services/backend_data_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String selectedZipcode = '';

  String? fullNameError;
  String? nickNameError;
  String? phoneError;
  String? birthDateError;
  String? genderError;
  String? weightError;
  String? diseaseError;
  String? addressError;

  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const String kFont = 'Sarabun';

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
    if (date == null) return 'วัน/เดือน/ปีเกิด';
    return BackendDataService.toThaiDate(date);
  }

  String _extractZipcode(String address) {
    final match = RegExp(r'(\d{5})').firstMatch(address);
    return match?.group(1) ?? '';
  }

  Future<void> pickBirthDate() async {
    DateTime tempDate = selectedBirthDate ?? DateTime(1967, 7, 19);
    
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
                            scrollController: FixedExtentScrollController(initialItem: tempDate.day - 1),
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempDate = DateTime(tempDate.year, tempDate.month, index + 1);
                              });
                            },
                            children: List.generate(31, (index) => Center(child: Text('${index + 1}', style: const TextStyle(fontFamily: kFont)))),
                          ),
                        ),
                        // เดือน
                        Expanded(
                          flex: 2,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(initialItem: tempDate.month - 1),
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempDate = DateTime(tempDate.year, index + 1, tempDate.day);
                              });
                            },
                            children: List.generate(12, (index) => Center(child: Text(thaiMonths[index + 1], style: const TextStyle(fontFamily: kFont)))),
                          ),
                        ),
                        // ปี (พ.ศ.)
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(initialItem: (tempDate.year + 543) - 2483),
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempDate = DateTime(2483 + index - 543, tempDate.month, tempDate.day);
                              });
                            },
                            children: List.generate(100, (index) => Center(child: Text('${2483 + index}', style: const TextStyle(fontFamily: kFont)))),
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
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text('ตกลง', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: kFont, fontWeight: FontWeight.bold)),
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

  Widget buildSingleBox({
    required Widget child,
    bool hasError = false,
    double height = 40,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
    AlignmentGeometry alignment = Alignment.center,
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
          fontSize: 14,
          fontFamily: kFont,
        ),
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

  List<String> _convertDiseaseToList() {
    final actualValues = selectedDiseaseList
        .where((e) => e != null && e != 'ไม่มีโรค')
        .cast<String>()
        .toList();

    if (actualValues.isEmpty) {
      return ['ไม่มีโรค'];
    }

    return actualValues;
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
            child: buildSingleBox(
              hasError: diseaseError != null,
              height: 40,
              alignment: Alignment.centerLeft,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDiseaseList[index],
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: kPrimary,
                  ),
                  hint: const Text(
                    'โรคประจำตัว',
                    style: TextStyle(
                      color: kText,
                      fontSize: 14,
                      fontFamily: kFont,
                    ),
                  ),
                  items: availableOptions.map((item) {
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
                    setState(() {
                      _updateDiseaseSelection(index: index, newValue: value);
                      diseaseError = null;
                    });
                  },
                ),
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
      addressError = null;
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

    if (addressController.text.trim().isEmpty) {
      addressError = 'กรุณากรอกหรือเลือกที่อยู่';
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
      underlyingDiseases: _convertDiseaseToList(),
      address: addressController.text.trim(),
      latitude: selectedLatitude ?? 0.0,
      longitude: selectedLongitude ?? 0.0,
      zipcode: selectedZipcode.isEmpty
          ? _extractZipcode(addressController.text.trim())
          : selectedZipcode,
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
      score: null,
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
        size: 108,
        color: kPrimary,
      ),
    );
  }

  Widget _buildEditableTextField({
    required TextEditingController controller,
    required String hint,
    required String? errorText,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          width: double.infinity,
          decoration: BoxDecoration(
            color: kFieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: errorText != null ? const Color(0xFFF04444) : kPrimary,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            textAlign: TextAlign.center,
            cursorColor: kPrimary,
            style: const TextStyle(
              color: kText,
              fontSize: 14,
              fontFamily: kFont,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              fillColor: Colors.transparent,
              filled: false,
              isDense: true,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: const TextStyle(
                color: kText,
                fontSize: 14,
                fontFamily: kFont,
              ),
            ),
          ),
        ),
        buildFieldError(errorText),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: pickBirthDate,
          child: buildSingleBox(
            hasError: birthDateError != null,
            height: 40,
            child: Text(
              formatDate(selectedBirthDate),
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
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSingleBox(
          hasError: genderError != null,
          height: 40,
          alignment: Alignment.centerLeft,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedGender,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: kPrimary),
              hint: const Text(
                'เพศ',
                style: TextStyle(
                  color: kText,
                  fontSize: 14,
                  fontFamily: kFont,
                ),
              ),
              items: genderItems.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: kText,
                      fontSize: 14,
                      fontFamily: kFont,
                    ),
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
        ),
        buildFieldError(genderError),
      ],
    );
  }

  Widget _buildWeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: pickWeightWheel,
          child: buildSingleBox(
            hasError: weightError != null,
            height: 40,
            child: Text(
              'น้ำหนัก : $selectedWeight กก.',
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
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ที่อยู่',
          style: TextStyle(
            fontSize: 16,
            color: kText,
            fontFamily: kFont,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: kFieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: addressError != null ? const Color(0xFFF04444) : kPrimary,
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: addressController,
            maxLines: 3,
            onChanged: (value) {
              if (addressError != null) {
                setState(() {
                  addressError = null;
                });
              }
              selectedLatitude = null;
              selectedLongitude = null;
            },
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
              fillColor: Colors.transparent,
              filled: false,
              isDense: true,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'กรอกที่อยู่หรือเลือกจากแผนที่',
              hintStyle: TextStyle(
                color: kText,
                fontSize: 14,
                fontFamily: kFont,
              ),
            ),
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
                const SizedBox(height: 10),
                _buildProfileIcon(),
                const SizedBox(height: 14),
                const Text(
                  'ข้อมูลสุขภาพพื้นฐาน',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildEditableTextField(
                        controller: fullNameController,
                        hint: 'ชื่อ - นามสกุล',
                        errorText: fullNameError,
                        onChanged: (value) {
                          if (fullNameError != null) {
                            setState(() {
                              fullNameError = null;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: _buildEditableTextField(
                        controller: nickNameController,
                        hint: 'ชื่อเล่น',
                        errorText: nickNameError,
                        onChanged: (value) {
                          if (nickNameError != null) {
                            setState(() {
                              nickNameError = null;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildEditableTextField(
                        controller: phoneController,
                        hint: 'เบอร์โทรศัพท์',
                        errorText: phoneError,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          if (phoneError != null) {
                            setState(() {
                              phoneError = null;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: _buildDateField(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildGenderField(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 7,
                      child: _buildWeightField(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                buildDiseaseDropdownGroup(),
                const SizedBox(height: 16),
                _buildAddressSection(),
                const SizedBox(height: 20),
                _buildNextButton(),
                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}
