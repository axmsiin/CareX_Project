import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/notification/notification.dart';
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
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const Color kHintRed = Color(0xFFE95257);
  static const String kFont = 'Sarabun';

  late final TextEditingController fullNameController;
  late final TextEditingController nickNameController;
  late final TextEditingController phoneController;
  final TextEditingController addressController = TextEditingController();

  late final TextEditingController guarantorNameController;
  late final TextEditingController guarantorPhoneController;
  late final TextEditingController guarantorRelationController;

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

    // Correctly prioritize guarantor data from static state, then fallback to profile data
    final guarantor = notification.confirmedGuarantor;
    guarantorNameController = TextEditingController(
      text: (guarantor?.name.isNotEmpty == true)
          ? guarantor!.name
          : widget.profile.guarantorName,
    );
    guarantorPhoneController = TextEditingController(
      text: (guarantor?.phone.isNotEmpty == true)
          ? guarantor!.phone
          : widget.profile.guarantorPhone,
    );
    guarantorRelationController = TextEditingController(
      text: (guarantor?.relation.isNotEmpty == true)
          ? guarantor!.relation
          : widget.profile.guarantorRelation,
    );

    selectedBirthDate = widget.profile.birthDate;
    selectedWeight = widget.profile.weight == 0 ? 65 : widget.profile.weight;
    selectedHeight = widget.profile.height == 0 ? 175 : widget.profile.height;

    // Ensure selectedGender is valid for DropdownButtonFormField items
    if (widget.profile.gender.isNotEmpty) {
      if (genderItems.contains(widget.profile.gender.trim())) {
        selectedGender = widget.profile.gender.trim();
      } else {
        selectedGender = null;
      }
    } else {
      selectedGender = null;
    }

    selectedDays.clear();
    // Normalize days to ensure they match our list (some might not have 'วัน' prefix)
    final List<String> normalizedDays = widget.profile.availableDays.map((d) {
      if (!d.startsWith('วัน') && d.isNotEmpty) return 'วัน$d';
      return d;
    }).toList();
    
    selectedDays.addAll(BackendDataService.sortDays(normalizedDays));
    allDayAvailable = widget.profile.allDayAvailable;
    selectedProvince = widget.profile.province;

    if (widget.profile.startTime.isNotEmpty) {
      final normalized = widget.profile.startTime.replaceAll('.', ':');
      final parts = normalized.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 9;
        final minute = int.tryParse(parts[1]) ?? 0;
        startTime = TimeOfDay(
          hour: hour.clamp(0, 23),
          minute: minute.clamp(0, 59),
        );
      }
    }

    if (widget.profile.endTime.isNotEmpty) {
      final normalized = widget.profile.endTime.replaceAll('.', ':');
      final parts = normalized.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 18;
        final minute = int.tryParse(parts[1]) ?? 0;
        endTime = TimeOfDay(
          hour: hour.clamp(0, 23),
          minute: minute.clamp(0, 59),
        );
      }
    }

    selectedDegree = BackendDataService.normalizeDegreeForDisplay(widget.profile.degree);
    if (!degrees.contains(selectedDegree)) {
      selectedDegree = null;
    }
    
    selectedGraduationDate = widget.profile.graduationDate;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    nickNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    guarantorNameController.dispose();
    guarantorPhoneController.dispose();
    guarantorRelationController.dispose();
    super.dispose();
  }

  String formatThaiDate(DateTime? date) {
    if (date == null) return '-';
    return BackendDataService.toThaiDate(date);
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
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
      });
    }
  }

  Future<void> pickProvinceWheel() async {
    String tempProvince =
        selectedProvince.isEmpty ? provinces.first : selectedProvince;

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

  Future<void> pickBirthDate() async {
    DateTime tempDate = selectedBirthDate ?? DateTime(1995, 7, 19);

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
                    ),                  ),
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
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text('ตกลง',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: kFont,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> pickGraduationDate() async {
    DateTime tempDate = selectedGraduationDate ?? DateTime(2025, 12, 25);

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
                    'เลือกวันที่จบการศึกษา',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kText,
                      fontFamily: kFont,
                    ),                  ),
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
                        selectedGraduationDate = tempDate;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text('ตกลง',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: kFont,
                            fontWeight: FontWeight.bold)),
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
    required String title,
    required int min,
    required int max,
    required int currentValue,
    required ValueChanged<int> onSelected,
  }) async {
    int tempValue = currentValue.clamp(min, max);

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
                    initialItem: (currentValue - min).clamp(0, max - min),
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
                  style: TextStyle(color: kWhite, fontFamily: kFont),
                ),
              ),
            ],
          ),
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
      backgroundColor: kBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kText,
                        fontFamily: kFont,
                      ),                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      style: const TextStyle(
                        color: kText,
                        fontFamily: kFont,
                      ),
                      decoration: InputDecoration(
                        hintText: 'พิมพ์ชื่อจังหวัด',
                        hintStyle: const TextStyle(
                          color: kText,
                          fontFamily: kFont,
                        ),
                        prefixIcon: const Icon(Icons.search, color: kPrimary),
                        filled: true,
                        fillColor: kFieldFill,
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
                          ? const Center(
                              child: Text(
                                'ไม่พบจังหวัด',
                                style: TextStyle(
                                  color: kText,
                                  fontFamily: kFont,
                                ),
                              ),
                            )
                          : CupertinoPicker(
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
                                          color: kText,
                                          fontFamily: kFont,
                                        ),
                                      ),
                                    ),
                                  )
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'ตกลง',
                        style: TextStyle(color: kWhite, fontFamily: kFont),
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
      });
    }
  }

  Widget buildBox({
    required Widget child,
    EdgeInsets? padding,
    double? height,
    Alignment alignment = Alignment.center,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      alignment: alignment,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimary, width: 1.2),
      ),
      child: child,
    );
  }

  Widget buildEditableTextField({
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    bool readOnly = false,
    TextAlign textAlign = TextAlign.center,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      textAlign: textAlign,
      cursorColor: kPrimary,
      style: const TextStyle(
        color: kText,
        fontSize: 14,
        fontFamily: kFont,
        fontWeight: FontWeight.w500,
        height: 1.25,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        isCollapsed: true,
        filled: false,
        contentPadding: EdgeInsets.zero,
      ).copyWith(
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

  Widget buildDayBox(String day) {
    final isSelected = selectedDays.contains(day);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedDays.remove(day);
          } else {
            selectedDays.add(day);
            // Sort days immediately after adding
            final sorted = BackendDataService.sortDays(selectedDays);
            selectedDays.clear();
            selectedDays.addAll(sorted);
          }
        });
      },
      child: Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: kFieldFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kPrimary, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: kPrimary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              day,
              style: const TextStyle(
                color: kText,
                fontSize: 14,
                fontFamily: kFont,
                fontWeight: FontWeight.w500,
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
        });
      },
      child: Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: kFieldFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kPrimary, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: kPrimary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              degree,
              style: const TextStyle(
                color: kText,
                fontSize: 14,
                fontFamily: kFont,
                fontWeight: FontWeight.w500,
              ),
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
    widget.profile.degree = BackendDataService.normalizeDegreeForSave(selectedDegree);
    widget.profile.graduationDate = selectedGraduationDate;

    notification.confirmedGuarantor = GuarantorData(
      name: guarantorNameController.text.trim(),
      phone: guarantorPhoneController.text.trim(),
      relation: guarantorRelationController.text.trim(),
    );

    final ok = await BackendDataService.updateCaregiverProfile(widget.profile);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'อัปเดตข้อมูลผู้ดูแลลงฐานข้อมูลไม่สำเร็จ',
            style: TextStyle(fontFamily: kFont),
          ),
        ),
      );
      return;
    }

    await CaregiverStore.syncFromBackend();
    if (!mounted) return;
    Navigator.pop(context, true);
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
            'แก้ไขข้อมูลผู้ดูแล',
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
        size: 118,
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home, size: 40, color: kPrimary),
          Icon(Icons.notifications, size: 40, color: kPrimary),
          Icon(Icons.account_circle, size: 44, color: kWhite),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayTime = allDayAvailable
        ? 'เวลา : สะดวกตลอดเวลา'
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
                const SizedBox(height: 24),
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
                  children: [
                    Expanded(
                      child: buildBox(
                        height: 52,
                        child: buildEditableTextField(
                          controller: fullNameController,
                          hintText: 'ชื่อ-นามสกุล',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: buildBox(
                        height: 52,
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
                        height: 52,
                        child: buildEditableTextField(
                          controller: phoneController,
                          hintText: 'เบอร์โทรศัพท์',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: buildBox(
                        height: 52,
                        child: InkWell(
                          onTap: pickBirthDate,
                          child: Text(
                            selectedBirthDate == null
                                ? 'วัน/เดือน/ปีเกิด'
                                : formatThaiDate(selectedBirthDate),
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
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: buildBox(
                        height: 52,
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
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: buildBox(
                        height: 52,
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
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: buildBox(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonFormField<String>(
                          value: selectedGender,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: kPrimary,
                            size: 22,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                            fillColor: Colors.transparent,
                            filled: true,
                          ),
                          hint: const Text(
                            'เพศ',
                            style: TextStyle(
                              color: kText,
                              fontSize: 14,
                              fontFamily: kFont,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          dropdownColor: kFieldFill,
                          style: const TextStyle(
                            color: kText,
                            fontSize: 14,
                            fontFamily: kFont,
                            fontWeight: FontWeight.w500,
                          ),
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
                  child: buildEditableTextField(
                    controller: addressController,
                    hintText: 'กรอกที่อยู่ หรือ เลือกจากแผนที่',
                    maxLines: 3,
                    readOnly: false,
                    textAlign: TextAlign.left,
                  ),
                ),
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
                if (widget.profile.guarantorName.trim().isNotEmpty ||
                    widget.profile.guarantorPhone.trim().isNotEmpty ||
                    widget.profile.guarantorRelation.trim().isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text(
                    'ผู้รับรอง',
                    style: TextStyle(
                      fontSize: 16,
                      color: kText,
                      fontFamily: kFont,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '*หากติดต่อผู้ดูแลไม่ได้ ต้องสามารถติดต่อฉุกเฉินได้',
                      style: TextStyle(
                        fontSize: 12,
                        color: kHintRed,
                        fontFamily: kFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  buildBox(
                    height: 52,
                    child: buildEditableTextField(
                      controller: guarantorNameController,
                      hintText: 'ชื่อผู้รับรอง',
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildBox(
                    height: 52,
                    child: buildEditableTextField(
                      controller: guarantorPhoneController,
                      hintText: 'เบอร์โทรศัพท์ผู้รับรอง',
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildBox(
                    height: 52,
                    child: buildEditableTextField(
                      controller: guarantorRelationController,
                      hintText: 'ความสัมพันธ์',
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
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
                  height: 52,
                  alignment: Alignment.centerLeft,
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
                const SizedBox(height: 18),
                const Text(
                  'วันและเวลาที่สะดวก',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                ...days.map(
                  (day) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: buildDayBox(day),
                  ),
                ),
                const SizedBox(height: 10),
                buildBox(
                  height: 52,
                  child: Text(
                    displayTime,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: kText,
                      fontSize: 14,
                      fontFamily: kFont,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'วุฒิประกาศนียบัตร',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
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
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                buildBox(
                  height: 52,
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: pickGraduationDate,
                    child: Text(
                      formatThaiDate(selectedGraduationDate),
                      style: const TextStyle(
                        color: kText,
                        fontSize: 14,
                        fontFamily: kFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'บันทึก',
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 16,
                          fontFamily: kFont,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}


