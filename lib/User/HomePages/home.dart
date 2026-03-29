import 'package:carex/User/HomePages/addProfileElderly_one.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/User/HomePages/elderlyStore.dart';
import 'package:carex/User/HomePages/profileElderly.dart';
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

  String getStatusText(ElderlyData elderly) {
    switch (elderly.status.trim()) {
      case 'matched':
        return 'มีผู้ดูแลแล้ว';
      case 'matching':
      case 'waiting_confirm':
        return 'อยู่ระหว่างการจับคู่';
      case 'match_failed':
      case 'caregiver_rejected':
      case 'user_rejected':
        return 'จับคู่ไม่สำเร็จ';
      default:
        return elderly.status.trim().isEmpty
            ? 'อยู่ระหว่างการจับคู่'
            : elderly.status.trim();
    }
  }

  Color getStatusColor(ElderlyData elderly) {
    switch (elderly.status.trim()) {
      case 'matched':
        return const Color(0xFF39C327);
      case 'matching':
      case 'waiting_confirm':
        return const Color(0xFFE3B400);
      case 'match_failed':
      case 'caregiver_rejected':
      case 'user_rejected':
        return const Color(0xFFFF5A5A);
      default:
        return const Color(0xFFE3B400);
    }
  }

  List<ElderlyData> getFilteredList(List<ElderlyData> list) {
    switch (selectedFilter) {
      case 'มีผู้ดูแลแล้ว':
        return list.where((e) => e.status == 'matched').toList();

      case 'อยู่ระหว่างการจับคู่':
        return list
            .where(
              (e) =>
                  e.status == 'matching' ||
                  e.status == 'waiting_confirm' ||
                  e.status == 'รอการจับคู่',
            )
            .toList();

      case 'จับคู่ไม่สำเร็จ':
        return list
            .where(
              (e) =>
                  e.status == 'match_failed' ||
                  e.status == 'caregiver_rejected' ||
                  e.status == 'user_rejected',
            )
            .toList();

      case 'ข้อมูลทั้งหมด':
      default:
        return list;
    }
  }

  Widget buildFilterDropdown() {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFilter,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0D47A1)),
          dropdownColor: const Color(0xFFFCFAFF),
          style: const TextStyle(fontSize: 15, color: Color(0xFF564444)),
          items: filterItems.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              selectedFilter = value;
            });
          },
        ),
      ),
    );
  }

  Widget buildElderlyCard(ElderlyData elderly, int index) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                profileElderly(elderlyData: elderly, elderlyIndex: index),
          ),
        );
        setState(() {});
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAFF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '*${getStatusText(elderly)}',
                      style: TextStyle(
                        color: getStatusColor(elderly),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    elderly.nickName.isEmpty ? '-' : elderly.nickName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF564444),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ดูแลโดย : ${elderly.caregiver.isEmpty ? '-' : elderly.caregiver}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF564444),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Color(0xFF564444),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ElderlyData> elderlyList = ElderlyStore.elderlyList;
    final filteredList = getFilteredList(elderlyList);

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
              buildFilterDropdown(),
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
                      return buildElderlyCard(elderly, realIndex);
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
