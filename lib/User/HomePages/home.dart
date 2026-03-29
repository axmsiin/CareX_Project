import 'package:carex/User/HomePages/addProfileElderly_one.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/User/HomePages/elderlyStore.dart';
import 'package:carex/User/HomePages/profileElderly.dart';
import 'package:carex/User/HomePages/widgets/elderly_card.dart';
import 'package:carex/User/HomePages/widgets/filter_dropdown.dart';
import 'package:carex/controllers/user_home_controller.dart';
import 'package:carex/User/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:carex/User/Profile/profileUser.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  String selectedFilter = 'ข้อมูลทั้งหมด';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await ElderlyStore.syncFromBackend();
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  final List<String> filterItems = const [
    'ข้อมูลทั้งหมด',
    'มีผู้ดูแลแล้ว',
    'อยู่ระหว่างการจับคู่',
    'จับคู่ไม่สำเร็จ',
  ];

  Future<void> goToAddElderlyPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const addProfileElderly_one()),
    );
    await _loadData();
  }

  Future<void> goToNotificationPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const notification()),
    );
    await _loadData();
  }

  Future<void> goToProfilePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const profileUser()),
    );
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final List<ElderlyData> elderlyList = ElderlyStore.elderlyList;
    // การเรียกใช้ Logic จาก Controller ตามหลัก MVC
    final filteredList =
        UserHomeController.getFilteredList(elderlyList, selectedFilter);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF0E8),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),
              const Text(
                "ข้อมูลผู้สูงอายุ",
                style: TextStyle(fontSize: 20, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 18),
              FilterDropdown(
                selectedFilter: selectedFilter,
                filterItems: filterItems,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedFilter = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (filteredList.isEmpty) ...[
                const SizedBox(height: 80),
                const Center(
                  child: Icon(
                    Icons.account_circle_outlined,
                    size: 220,
                    color: Color(0xFFFCFAFF),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "ไม่มีข้อมูล",
                    style: TextStyle(fontSize: 20, color: Color(0xFF564444)),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final elderly = filteredList[index];
                      final realIndex = elderlyList.indexOf(elderly);
                      return ElderlyCard(
                        elderly: elderly,
                        index: realIndex,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => profileElderly(
                                  elderlyData: elderly,
                                  elderlyIndex: realIndex),
                            ),
                          );
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
              if (filteredList.isEmpty) const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: goToAddElderlyPage,
                  icon: const Icon(Icons.add, color: Color(0xFF0D47A1)),
                  label: const Text(
                    "เพิ่มข้อมูลผู้สูงอายุ",
                    style: TextStyle(color: Color(0xFF564444), fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE711E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
              icon: const Icon(Icons.home, size: 38, color: Color(0xFFEE711E)),
            ),
            IconButton(
              onPressed: goToNotificationPage,
              icon: const Icon(
                Icons.notifications,
                size: 38,
                color: Color(0xFF0D47A1),
              ),
            ),
            IconButton(
              onPressed: goToProfilePage,
              icon: const Icon(
                Icons.account_circle,
                size: 42,
                color: Color(0xFF0D47A1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
