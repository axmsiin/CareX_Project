import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/profileCaregiver_two.dart';
import 'package:carex/controllers/profile_controller.dart';
import 'package:carex/models/caregiver_profile_request.dart';
import 'package:carex/services/app_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carex/map.dart';

class profilecaregiver_one extends StatefulWidget {
  final caregiverData profile;

  const profilecaregiver_one({super.key, required this.profile});

  @override
  State<profilecaregiver_one> createState() => _profilecaregiver_oneState();
}

class _profilecaregiver_oneState extends State<profilecaregiver_one> {
  late final TextEditingController fullNameController;
  final TextEditingController nickNameController = TextEditingController();
  late final TextEditingController phoneController;
  final TextEditingController addressController = TextEditingController();

  DateTime? selectedBirthDate;
  int selectedWeight = 65;
  int selectedHeight = 175;
  String? selectedGender;
  String selectedProvince = '';

  double? selectedLatitude;
  double? selectedLongitude;

  String? fullNameError;
  String? nickNameError;
  String? phoneError;
  String? birthDateError;
  String? weightError;
  String? heightError;
  String? genderError;
  String? provinceError;
  String? addressError;

  bool isSaving = false;

  final List<String> genderItems = ['ชาย', 'หญิง', 'ไม่ระบุ'];

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
    'พะเยา',
    'พังงา',
    'พัทลุง',
    'พิจิตร',
    'พิษณุโลก',
    'เพชรบุรี',
    'เพชรบูรณ์',
    'แพร่',
    'ภูเก็ต',
    'มหาสารคาม',
    'มุกดาหาร',
    'แม่ฮ่องสอน',
    'ยะลา',
    'ยโสธร',
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

  static const String appFont = 'LINESeedSansTH';

  TextStyle get outsideTextStyle => const TextStyle(
        fontFamily: appFont,
        fontSize: 16,
        color: Color(0xFF564444),
      );

  TextStyle get insideTextStyle => const TextStyle(
        fontFamily: appFont,
        fontSize: 14,
        color: Color(0xFF564444),
      );

  TextStyle get hintInsideTextStyle => const TextStyle(
        fontFamily: appFont,
        fontSize: 14,
        color: Color(0xFF8A8A8A),
      );

  TextStyle get buttonTextStyle => const TextStyle(
        fontFamily: appFont,
        fontSize: 14,
      );

  @override
  void initState() {
    super.initState();

    fullNameController = TextEditingController(text: widget.profile.fullName);
    nickNameController.text = widget.profile.nickName;
    phoneController = TextEditingController(text: widget.profile.phone);

    selectedBirthDate = widget.profile.birthDate;
    selectedWeight = widget.profile.weight == 0 ? 65 : widget.profile.weight;
    selectedHeight = widget.profile.height == 0 ? 175 : widget.profile.height;
    selectedGender =
        widget.profile.gender.isEmpty ? null : widget.profile.gender;

    addressController.text = widget.profile.address;
    selectedProvince = widget.profile.province;
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'วันเกิด';
    return '${date.day} ${thaiMonths[date.month]} ${date.year}';
  }

  String formatApiDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> pickBirthDate() async {
    DateTime tempDate = selectedBirthDate ?? DateTime(2004, 3, 2);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          height: 320,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'เลือกวันเกิด',
                style: TextStyle(
                  fontFamily: appFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF564444),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontFamily: appFont,
                        fontSize: 16,
                        color: Color(0xFF564444),
                      ),
                    ),
                  ),
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
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedBirthDate = tempDate;
                    birthDateError = null;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003F91),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'ตกลง',
                  style: buttonTextStyle.copyWith(color: Colors.white),
                ),
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
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          height: 320,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: appFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF564444),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(
                        fontFamily: appFont,
                        fontSize: 16,
                        color: Color(0xFF564444),
                      ),
                    ),
                  ),
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
                      (index) => Center(
                        child: Text(
                          '${min + index}',
                          style: const TextStyle(
                            fontFamily: appFont,
                            fontSize: 16,
                            color: Color(0xFF564444),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  onSelected(tempValue);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003F91),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'ตกลง',
                  style: buttonTextStyle.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickProvinceSearchable() async {
    String tempProvince =
        selectedProvince.isNotEmpty ? selectedProvince : provinces.first;
    final TextEditingController searchController = TextEditingController();
    List<String> filtered = List.from(provinces);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                      style: TextStyle(
                        fontFamily: appFont,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF564444),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      style: insideTextStyle,
                      decoration: InputDecoration(
                        hintText: 'พิมพ์ชื่อจังหวัด',
                        hintStyle: hintInsideTextStyle,
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Color(0xFF003F91)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Color(0xFF003F91)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFF003F91),
                            width: 1.5,
                          ),
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
                          ? Text(
                              'ไม่พบจังหวัด',
                              style: outsideTextStyle,
                            )
                          : CupertinoTheme(
                              data: const CupertinoThemeData(
                                textTheme: CupertinoTextThemeData(
                                  pickerTextStyle: TextStyle(
                                    fontFamily: appFont,
                                    fontSize: 16,
                                    color: Color(0xFF564444),
                                  ),
                                ),
                              ),
                              child: CupertinoPicker(
                                itemExtent: 40,
                                scrollController: FixedExtentScrollController(
                                  initialItem: currentIndex,
                                ),
                                onSelectedItemChanged: (index) {
                                  tempProvince = filtered[index];
                                },
                                children: filtered
                                    .map(
                                      (province) => Center(
                                        child: Text(
                                          province,
                                          style: const TextStyle(
                                            fontFamily: appFont,
                                            fontSize: 16,
                                            color: Color(0xFF564444),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                    ),
                    ElevatedButton(
                      onPressed: filtered.isEmpty
                          ? null
                          : () {
                              setState(() {
                                selectedProvince = tempProvince;
                                provinceError = null;
                              });
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003F91),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'ตกลง',
                        style: buttonTextStyle.copyWith(color: Colors.white),
                      ),
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
        provinceError = null;
        addressError = null;
      });
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    nickNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Widget buildInputBox({
    required Widget child,
    double? width,
    bool hasError = false,
    double height = 64,
  }) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasError ? const Color(0xFFF04444) : const Color(0xFF003F91),
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
          fontFamily: appFont,
          color: Color(0xFFF04444),
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> submitProfile() async {
    setState(() {
      fullNameError = null;
      nickNameError = null;
      phoneError = null;
      birthDateError = null;
      weightError = null;
      heightError = null;
      genderError = null;
      provinceError = null;
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

    if (selectedGender == null || selectedGender!.trim().isEmpty) {
      genderError = 'กรุณาเลือกเพศ';
      isValid = false;
    }

    if (selectedWeight <= 0) {
      weightError = 'กรุณาเลือกน้ำหนัก';
      isValid = false;
    }

    if (selectedHeight <= 0) {
      heightError = 'กรุณาเลือกส่วนสูง';
      isValid = false;
    }

    if (addressController.text.trim().isEmpty) {
      addressError = 'กรุณาเลือกที่อยู่จากแผนที่';
      isValid = false;
    }

    if (selectedProvince.isEmpty) {
      provinceError = 'กรุณาเลือกจังหวัด';
      isValid = false;
    }

    setState(() {});

    if (!isValid) return;

    final userId = await AppSession.getUserId();
    final token = await AppSession.getToken();

    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบ user_id กรุณาเข้าสู่ระบบใหม่')),
      );
      return;
    }

    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบ token กรุณาเข้าสู่ระบบใหม่')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final request = CaregiverProfileRequest(
      userId: userId,
      fullname: fullNameController.text.trim(),
      alias: nickNameController.text.trim(),
      tel: phoneController.text.trim(),
      gender: selectedGender!.trim(),
      weight: selectedWeight,
      height: selectedHeight,
      address: addressController.text.trim(),
      province: selectedProvince.trim(),
      birthday: formatApiDate(selectedBirthDate!),
    );

    final result = await ProfileController.createCaregiverProfile(
      request: request,
      token: token,
    );

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      return;
    }

    widget.profile.fullName = fullNameController.text.trim();
    widget.profile.nickName = nickNameController.text.trim();
    widget.profile.phone = phoneController.text.trim();
    widget.profile.birthDate = selectedBirthDate;
    widget.profile.weight = selectedWeight;
    widget.profile.height = selectedHeight;
    widget.profile.gender = selectedGender ?? '';
    widget.profile.address = addressController.text.trim();
    widget.profile.province = selectedProvince;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => profileCaregiver_two(profile: widget.profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTextStyle(
        style: outsideTextStyle,
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: isSaving
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF564444),
                      ),
                      label: Text(
                        'ย้อนกลับ',
                        style: outsideTextStyle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Icon(
                        Icons.account_circle_outlined,
                        size: 90,
                        color: Color(0xFF003F91),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'ข้อมูลสุขภาพพื้นฐาน',
                      style: outsideTextStyle,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildInputBox(
                                hasError: fullNameError != null,
                                child: TextField(
                                  controller: fullNameController,
                                  style: insideTextStyle,
                                  onChanged: (value) {
                                    if (fullNameError != null) {
                                      setState(() {
                                        fullNameError = null;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'ชื่อ-นามสกุล',
                                    hintStyle: hintInsideTextStyle,
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                  ),
                                ),
                              ),
                              buildFieldError(fullNameError),
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
                                hasError: nickNameError != null,
                                child: TextField(
                                  controller: nickNameController,
                                  style: insideTextStyle,
                                  onChanged: (value) {
                                    if (nickNameError != null) {
                                      setState(() {
                                        nickNameError = null;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'ชื่อเล่น',
                                    hintStyle: hintInsideTextStyle,
                                    border: InputBorder.none,
                                    isCollapsed: true,
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
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildInputBox(
                                hasError: phoneError != null,
                                child: TextField(
                                  controller: phoneController,
                                  style: insideTextStyle,
                                  keyboardType: TextInputType.phone,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: 'เบอร์โทรศัพท์',
                                    hintStyle: hintInsideTextStyle,
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                  ),
                                ),
                              ),
                              buildFieldError(phoneError),
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
                                hasError: birthDateError != null,
                                child: InkWell(
                                  onTap: isSaving ? null : pickBirthDate,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      formatDate(selectedBirthDate),
                                      style: insideTextStyle,
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
                              buildInputBox(
                                hasError: weightError != null,
                                child: InkWell(
                                  onTap: isSaving
                                      ? null
                                      : () => pickNumberWheel(
                                            title: 'เลือกน้ำหนัก (กก.)',
                                            min: 30,
                                            max: 150,
                                            currentValue: selectedWeight,
                                            onSelected: (value) {
                                              setState(() {
                                                selectedWeight = value;
                                                weightError = null;
                                              });
                                            },
                                          ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'น้ำหนัก : $selectedWeight กก.',
                                      style: insideTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                              buildFieldError(weightError),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildInputBox(
                                hasError: heightError != null,
                                child: InkWell(
                                  onTap: isSaving
                                      ? null
                                      : () => pickNumberWheel(
                                            title: 'เลือกส่วนสูง (ซม.)',
                                            min: 100,
                                            max: 220,
                                            currentValue: selectedHeight,
                                            onSelected: (value) {
                                              setState(() {
                                                selectedHeight = value;
                                                heightError = null;
                                              });
                                            },
                                          ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'ส่วนสูง : $selectedHeight ซม.',
                                      style: insideTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                              buildFieldError(heightError),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildInputBox(
                                hasError: genderError != null,
                                child: DropdownButtonFormField<String>(
                                  value: selectedGender,
                                  isExpanded: true,
                                  style: insideTextStyle,
                                  iconEnabledColor: const Color(0xFF564444),
                                  dropdownColor: Colors.white,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                  ),
                                  hint: Text(
                                    'เพศ',
                                    style: hintInsideTextStyle,
                                  ),
                                  items: genderItems.map((item) {
                                    return DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: insideTextStyle,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: isSaving
                                      ? null
                                      : (value) {
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
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ที่อยู่',
                      style: outsideTextStyle,
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildInputBox(
                          height: 80,
                          hasError: addressError != null,
                          child: TextField(
                            controller: addressController,
                            style: insideTextStyle,
                            readOnly: true,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'เลือกจากแผนที่',
                              hintStyle: hintInsideTextStyle,
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                        buildFieldError(addressError),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: isSaving ? null : pickLocationFromMap,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 110,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: addressError != null
                                ? const Color(0xFFF04444)
                                : const Color(0xFF003F91),
                            width: 1.2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'แตะเพื่อปักหมุดบนแผนที่',
                          style: outsideTextStyle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ระยะทางที่สะดวก',
                      style: outsideTextStyle,
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildInputBox(
                          hasError: provinceError != null,
                          child: InkWell(
                            onTap: isSaving ? null : pickProvinceSearchable,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                selectedProvince.isEmpty
                                    ? 'เลือกจังหวัด'
                                    : 'จังหวัด : $selectedProvince',
                                style: insideTextStyle,
                              ),
                            ),
                          ),
                        ),
                        buildFieldError(provinceError),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : submitProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003F91),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          isSaving ? 'กำลังบันทึก...' : 'ถัดไป',
                          style: buttonTextStyle.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              if (isSaving)
                Container(
                  color: Colors.black.withValues(alpha: 0.1),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
