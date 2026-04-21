import 'package:carex/User/HomePages/addProfileElderly_four.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class addProfileElderly_three extends StatefulWidget {
  final ElderlyData elderlyData;

  const addProfileElderly_three({super.key, required this.elderlyData});

  @override
  State<addProfileElderly_three> createState() =>
      _addProfileElderly_threeState();
}

class _addProfileElderly_threeState extends State<addProfileElderly_three> {
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const String kFont = 'Sarabun';

  String? selectedNeedLevel;
  String? needLevelError;

  final List<Map<String, String>> needOptions = const [
    {
      'title': 'ช่วยเหลือตนเองได้ดี',
      'subtitle': 'เดินเองได้ หรือ คล่องแคล่ว',
      'value': 'level1',
    },
    {
      'title': 'ช่วยเหลือตนเองได้ปานกลาง',
      'subtitle': 'ต้องพยุง หรือ ใช้วอร์คเกอร์',
      'value': 'level2',
    },
    {
      'title': 'เริ่มติดบ้าน หรือ กึ่งติดเตียง',
      'subtitle': 'ใช้วีลแชร์ หรือ ต้องมีคนพยุงตลอดเวลา',
      'value': 'level3',
    },
    {
      'title': 'ติดเตียง',
      'subtitle': 'นอนบนเตียงเป็นหลัก หรือ ช่วยเหลือตนเองไม่ได้เลย',
      'value': 'level4',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedNeedLevel = widget.elderlyData.needLevel.isEmpty
        ? null
        : widget.elderlyData.needLevel;
  }

  Widget buildFieldError(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Text(
        error,
        style: const TextStyle(
          color: Color(0xFFF04444),
          fontSize: 12,
          fontFamily: kFont,
        ),
      ),
    );
  }

  Widget buildNeedBox({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final bool isSelected = selectedNeedLevel == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedNeedLevel = value;
          needLevelError = null;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: kFieldFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: needLevelError != null ? const Color(0xFFF04444) : kPrimary,
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 1.0,
              child: Radio<String>(
                value: value,
                groupValue: selectedNeedLevel,
                onChanged: (newValue) {
                  setState(() {
                    selectedNeedLevel = newValue;
                    needLevelError = null;
                  });
                },
                activeColor: kPrimary,
                fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) return kPrimary;
                  return kPrimary;
                }),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: kText,
                        fontFamily: kFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kText,
                        fontFamily: kFont,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void goNext() {
    setState(() {
      needLevelError = null;
    });

    if (selectedNeedLevel == null) {
      setState(() {
        needLevelError = 'กรุณาเลือกความต้องการในการดูแล';
      });
      return;
    }

    widget.elderlyData.needLevel = selectedNeedLevel!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            addProfileElderly_four(elderlyData: widget.elderlyData),
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
                const SizedBox(height: 46),
                const Text(
                  'ความต้องการในการดูแล*',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ...needOptions.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: buildNeedBox(
                      title: item['title']!,
                      subtitle: item['subtitle']!,
                      value: item['value']!,
                    ),
                  ),
                ),
                buildFieldError(needLevelError),
                const SizedBox(height: 18),
                _buildNextButton(),
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
