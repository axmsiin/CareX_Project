import 'package:carex/User/HomePages/addProfileElderly_four.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:flutter/material.dart';

class addProfileElderly_three extends StatefulWidget {
  final ElderlyData elderlyData;

  const addProfileElderly_three({super.key, required this.elderlyData});

  @override
  State<addProfileElderly_three> createState() =>
      _addProfileElderly_threeState();
}

class _addProfileElderly_threeState extends State<addProfileElderly_three> {
  String? selectedNeedLevel;
  String? needLevelError;

  final List<Map<String, String>> needOptions = const [
    {
      'title': 'ช่วยเหลือตนเองได้',
      'subtitle': 'แซมช่วยได้ หรือ ก็อยู่คนเดียว',
      'value': 'independent',
    },
    {
      'title': 'ช่วยเหลือตนเองได้ปานกลาง',
      'subtitle': 'ต้องพยุง หรือจัดกิจกรรม',
      'value': 'moderate',
    },
    {
      'title': 'เริ่มเดินบ้าน หรือ หวัดติดเตียง',
      'subtitle': 'ใช้วิลแชร์ หรือ ต้องป้อนพูดตลอดเวลา',
      'value': 'high',
    },
    {
      'title': 'ติดเตียง',
      'subtitle': 'นอนบนเตียงเป็นหลัก หรือ ช่วยเหลือตนเองไม่ได้เลย',
      'value': 'bedridden',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedNeedLevel = widget.elderlyData.needLevel.isEmpty
        ? null
        : widget.elderlyData.needLevel;
  }

  Widget buildNeedBox({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = selectedNeedLevel == value;

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
          color: const Color(0xFFFCFAFF),
          borderRadius: BorderRadius.circular(14),
          border: needLevelError != null
              ? Border.all(color: const Color(0xFFF04444))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: value,
              groupValue: selectedNeedLevel,
              onChanged: (newValue) {
                setState(() {
                  selectedNeedLevel = newValue;
                  needLevelError = null;
                });
              },
              activeColor: const Color(0xFFEE711E),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF564444),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF564444),
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
                  'ข้อมูลผู้สูงอายุ',
                  style: TextStyle(color: Color(0xFF564444)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ความต้องการในการดูแล*',
                style: TextStyle(fontSize: 18, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 14),
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
        height: 85,
        decoration: const BoxDecoration(
          color: Color(0xFFFCFAFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home, size: 34, color: Color(0xFFEE711E)),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications,
                size: 38,
                color: Color(0xFFEE711E),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.account_circle,
                size: 42,
                color: Color(0xFFEE711E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
