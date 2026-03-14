import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/profileCaregiver_two.dart';
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'พิมพ์ชื่อจังหวัด',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFD5E7FF),
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
                                  .map(
                                    (province) => Center(child: Text(province)),
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
                                provinceError = null;
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
        provinceError = null;
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

  void goNext() {
    setState(() {
      fullNameError = null;
      nickNameError = null;
      phoneError = null;
      birthDateError = null;
      weightError = null;
      heightError = null;
      genderError = null;
      provinceError = null;
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

    if (selectedHeight <= 0) {
      heightError = 'กรุณาเลือกส่วนสูง';
      isValid = false;
    }

    if (selectedProvince.isEmpty) {
      provinceError = 'กรุณาเลือกจังหวัด';
      isValid = false;
    }

    setState(() {});

    if (!isValid) return;

    widget.profile.fullName = fullNameController.text.trim();
    widget.profile.nickName = nickNameController.text.trim();
    widget.profile.phone = phoneController.text.trim();
    widget.profile.birthDate = selectedBirthDate;
    widget.profile.weight = selectedWeight;
    widget.profile.height = selectedHeight;
    widget.profile.gender = selectedGender ?? '';
    widget.profile.address = addressController.text.trim();
    widget.profile.province = selectedProvince;

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
      backgroundColor: const Color(0xFFFFFCE3),
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
                  size: 90,
                  color: Color(0xFFD5E7FF),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'ข้อมูลสุขภาพพื้นฐาน',
                style: TextStyle(fontSize: 18, color: Color(0xFF564444)),
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
                            onChanged: (value) {
                              if (fullNameError != null) {
                                setState(() {
                                  fullNameError = null;
                                });
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: 'ชื่อ-นามสกุล',
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
                            onChanged: (value) {
                              if (nickNameError != null) {
                                setState(() {
                                  nickNameError = null;
                                });
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: 'ชื่อเล่น',
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
                            keyboardType: TextInputType.phone,
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: 'เบอร์โทรศัพท์',
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
                            onTap: pickBirthDate,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                formatDate(selectedBirthDate),
                                style: const TextStyle(
                                  color: Color(0xFF564444),
                                ),
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
                            onTap: () {
                              pickNumberWheel(
                                title: 'เลือกน้ำหนัก',
                                min: 20,
                                max: 150,
                                currentValue: selectedWeight,
                                onSelected: (value) {
                                  setState(() {
                                    selectedWeight = value;
                                    weightError = null;
                                  });
                                },
                              );
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'น้ำหนัก : $selectedWeight',
                                style: const TextStyle(
                                  color: Color(0xFF564444),
                                ),
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
                            onTap: () {
                              pickNumberWheel(
                                title: 'เลือกส่วนสูง',
                                min: 100,
                                max: 220,
                                currentValue: selectedHeight,
                                onSelected: (value) {
                                  setState(() {
                                    selectedHeight = value;
                                    heightError = null;
                                  });
                                },
                              );
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'ส่วนสูง : $selectedHeight',
                                style: const TextStyle(
                                  color: Color(0xFF564444),
                                ),
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
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
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
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'ที่อยู่',
                style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 10),
              buildInputBox(
                height: 80,
                child: TextField(
                  controller: addressController,
                  readOnly: true,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'เลือกจากแผนที่',
                    border: InputBorder.none,
                    isCollapsed: true,
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
                  child: const Text(
                    'แตะเพื่อปักหมุดบนแผนที่',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ระยะทางที่สะดวก',
                style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInputBox(
                    hasError: provinceError != null,
                    child: InkWell(
                      onTap: pickProvinceSearchable,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          selectedProvince.isEmpty
                              ? 'เลือกจังหวัด'
                              : 'จังหวัด : $selectedProvince',
                          style: const TextStyle(color: Color(0xFF564444)),
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
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFFD5E7FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.home, size: 36, color: const Color(0xFF003F91)),
            Icon(Icons.notifications, size: 34, color: const Color(0xFF003F91)),
            Icon(Icons.account_circle,
                size: 36, color: const Color(0xFF003F91)),
          ],
        ),
      ),
    );
  }
}
