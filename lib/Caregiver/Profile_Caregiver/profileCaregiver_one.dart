import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/profileCaregiver_two.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiver_store.dart';
import 'package:carex/map.dart';
import 'package:carex/services/backend_data_service.dart';
import 'package:carex/widgets/privacy_consent_dialog.dart';

class profilecaregiver_one extends StatefulWidget {
  final caregiverData profile;

  const profilecaregiver_one({
    super.key,
    required this.profile,
  });

  @override
  State<profilecaregiver_one> createState() => _profilecaregiver_oneState();
}

class _profilecaregiver_oneState extends State<profilecaregiver_one> {
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
  final TextEditingController nickNameController = TextEditingController();
  late final TextEditingController phoneController;
  final TextEditingController addressController = TextEditingController();

  DateTime? selectedBirthDate;
  int selectedWeight = 65;
  int selectedHeight = 170;
  String? selectedGender;
  String selectedProvince = '';

  double? selectedLatitude;
  double? selectedLongitude;

  bool isSaving = false;
  bool _isShowingConsentDialog = false;

  String? fullNameError;
  String? nickNameError;
  String? phoneError;
  String? birthDateError;
  String? weightError;
  String? heightError;
  String? genderError;
  String? provinceError;
  String? addressError;

  final List<String> genderItems = const ['ชาย', 'หญิง', 'ไม่ระบุ'];

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

    fullNameController = TextEditingController(text: widget.profile.fullName);
    phoneController = TextEditingController(text: widget.profile.phone);

    nickNameController.text = widget.profile.nickName;
    addressController.text = widget.profile.address;

    selectedBirthDate = widget.profile.birthDate;
    selectedWeight = widget.profile.weight;
    selectedHeight = widget.profile.height;
    selectedGender =
        widget.profile.gender.isEmpty ? null : widget.profile.gender;
    selectedProvince = widget.profile.province;

    selectedLatitude = widget.profile.latitude;
    selectedLongitude = widget.profile.longitude;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowConsentDialog();
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    nickNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowConsentDialog() async {
    if (_isShowingConsentDialog) return;

    final prefs = await SharedPreferences.getInstance();
    final hasAccepted = prefs.getBool('caregiver_privacy_accepted') ?? false;

    if (hasAccepted || !mounted) return;

    setState(() {
      _isShowingConsentDialog = true;
    });

    final accepted = await showPrivacyConsentDialog(context);

    if (!mounted) return;

    if (accepted == true) {
      await prefs.setBool('caregiver_privacy_accepted', true);
    } else {
      // หากไม่ยินยอม ให้กลับไปหน้าก่อนหน้าทันที (ไม่อนุญาตให้กรอกข้อมูล)
      Navigator.pop(context);
    }

    if (mounted) {
      setState(() {
        _isShowingConsentDialog = false;
      });
    }
  }

  String formatThaiDate(DateTime? date) {
    if (date == null) return 'วัน/เดือน/ปีเกิด';
    return BackendDataService.toThaiDate(date);
  }

  Future<void> pickBirthDate() async {
    DateTime tempDate = selectedBirthDate ?? DateTime(2000, 7, 19);

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
                      fontSize: 14,
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
      },
    );
  }

  Future<void> pickNumberWheel({
    required int initialValue,
    required int min,
    required int max,
    required String title,
    required ValueChanged<int> onSelected,
  }) async {
    int tempValue = initialValue;

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
              Text(
                title,
                style: const TextStyle(
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
                    initialItem: initialValue - min,
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
                  onSelected(tempValue);
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

  Future<void> pickGenderWheel() async {
    String tempGender = selectedGender ?? genderItems.first;

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
                'เลือกเพศ',
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
                    initialItem: selectedGender == null
                        ? 0
                        : genderItems.indexOf(selectedGender!),
                  ),
                  onSelectedItemChanged: (index) {
                    tempGender = genderItems[index];
                  },
                  children: genderItems
                      .map((item) => Center(
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: kText,
                                fontFamily: kFont,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedGender = tempGender;
                    genderError = null;
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

  Future<void> pickProvinceWheel() async {
    String tempProvince = selectedProvince.isEmpty ? provinces.first : selectedProvince;

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
                'เลือกจังหวัด',
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
                    initialItem: provinces.indexOf(tempProvince),
                  ),
                  onSelectedItemChanged: (index) {
                    tempProvince = provinces[index];
                  },
                  children: provinces
                      .map((item) => Center(
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: kText,
                                fontFamily: kFont,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedProvince = tempProvince;
                    provinceError = null;
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

  Future<void> openMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const map()),
    );

    if (result != null) {
      setState(() {
        addressController.text = result['address'] ?? '';
        selectedProvince = result['province'] ?? '';
        selectedLatitude = result['latitude'];
        selectedLongitude = result['longitude'];
        addressError = null;
        provinceError = null;
      });
    }
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

    if (selectedGender == null || selectedGender!.isEmpty) {
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

    setState(() {
      isSaving = true;
    });

    widget.profile.fullName = fullNameController.text.trim();
    widget.profile.nickName = nickNameController.text.trim();
    widget.profile.phone = phoneController.text.trim();
    widget.profile.birthDate = selectedBirthDate;
    widget.profile.weight = selectedWeight;
    widget.profile.height = selectedHeight;
    widget.profile.gender = selectedGender ?? '';
    widget.profile.address = addressController.text.trim();
    widget.profile.province = selectedProvince;
    widget.profile.latitude = selectedLatitude ?? widget.profile.latitude;
    widget.profile.longitude = selectedLongitude ?? widget.profile.longitude;

    await CaregiverStore.save(widget.profile);

    setState(() {
      isSaving = false;
    });

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => profileCaregiver_two(profile: widget.profile),
      ),
    );
  }

  Widget buildBox({
    required Widget child,
    bool hasError = false,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: double.infinity,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

  Widget buildError(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 4),
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

  Widget buildEditableField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    TextAlign textAlign = TextAlign.center,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: textAlign,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      cursorColor: kPrimary,
      style: const TextStyle(
        color: kText,
        fontSize: 14,
        fontFamily: kFont,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        isCollapsed: true,
        filled: false,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: kText,
          fontSize: 14,
          fontFamily: kFont,
          fontWeight: FontWeight.w500,
        ),
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
          Icon(Icons.home, size: 40, color: kPrimary),
          Icon(Icons.notifications, size: 40, color: kPrimary),
          Icon(Icons.account_circle, size: 44, color: kWhite),
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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 18),
                _buildProfileIcon(),
                const SizedBox(height: 22),
                const Text(
                  'ข้อมูลสุขภาพพื้นฐาน',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
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
                            hasError: fullNameError != null,
                            child: buildEditableField(
                              controller: fullNameController,
                              hintText: 'ชื่อ-นามสกุล',
                            ),
                          ),
                          buildError(fullNameError),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          buildBox(
                            hasError: nickNameError != null,
                            child: buildEditableField(
                              controller: nickNameController,
                              hintText: 'ชื่อเล่น',
                            ),
                          ),
                          buildError(nickNameError),
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
                            child: buildEditableField(
                              controller: phoneController,
                              hintText: 'เบอร์โทรศัพท์',
                            ),
                          ),
                          buildError(phoneError),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          buildBox(
                            hasError: birthDateError != null,
                            child: InkWell(
                              onTap: pickBirthDate,
                              child: Text(
                                formatThaiDate(selectedBirthDate),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: kText,
                                  fontSize: 14,
                                  fontFamily: kFont,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          buildError(birthDateError),
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
                            hasError: weightError != null,
                            child: InkWell(
                              onTap: () => pickNumberWheel(
                                initialValue: selectedWeight,
                                min: 30,
                                max: 150,
                                title: 'เลือกน้ำหนัก',
                                onSelected: (value) {
                                  setState(() {
                                    selectedWeight = value;
                                    weightError = null;
                                  });
                                },
                              ),
                              child: Text(
                                'น้ำหนัก: $selectedWeight กก.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: kText,
                                  fontSize: 14,
                                  fontFamily: kFont,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          buildError(weightError),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          buildBox(
                            hasError: heightError != null,
                            child: InkWell(
                              onTap: () => pickNumberWheel(
                                initialValue: selectedHeight,
                                min: 120,
                                max: 220,
                                title: 'เลือกส่วนสูง',
                                onSelected: (value) {
                                  setState(() {
                                    selectedHeight = value;
                                    heightError = null;
                                  });
                                },
                              ),
                              child: Text(
                                'ส่วนสูง: $selectedHeight ซม.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: kText,
                                  fontSize: 14,
                                  fontFamily: kFont,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          buildError(heightError),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          buildBox(
                            hasError: genderError != null,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: InkWell(
                              onTap: pickGenderWheel,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      selectedGender ?? 'เพศ',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: kText,
                                        fontSize: 14,
                                        fontFamily: kFont,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: kPrimary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          buildError(genderError),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
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
                buildBox(
                  hasError: addressError != null,
                  child: buildEditableField(
                    controller: addressController,
                    hintText: 'กรอกที่อยู่ หรือ เลือกจากแผนที่',
                    readOnly: false,
                    textAlign: TextAlign.left,
                    maxLines: 3,
                  ),
                ),
                buildError(addressError),
                const SizedBox(height: 8),
                InkWell(
                  onTap: openMap,
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
                const Text(
                  'ระยะทางที่สะดวก',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                buildBox(
                  hasError: provinceError != null,
                  child: InkWell(
                    onTap: pickProvinceWheel,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedProvince.isEmpty
                              ? 'จังหวัด'
                              : 'จังหวัด : $selectedProvince',
                          style: const TextStyle(
                            color: kText,
                            fontSize: 14,
                            fontFamily: kFont,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: kPrimary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                buildError(provinceError),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 86,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : submitProfile,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: kPrimary,
                        disabledBackgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        isSaving ? 'รอ...' : 'ถัดไป',
                        style: const TextStyle(
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
