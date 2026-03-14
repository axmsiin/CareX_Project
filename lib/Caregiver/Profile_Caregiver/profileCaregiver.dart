import 'package:carex/Caregiver/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/editProfileCaregiver.dart';
import 'package:carex/Caregiver/HomePages/home.dart';
import 'package:carex/authentication/login.dart';

class profileCaregiver extends StatefulWidget {
  final caregiverData profile;

  const profileCaregiver({super.key, required this.profile});

  @override
  State<profileCaregiver> createState() => _ProfileCaregiverState();
}

class _ProfileCaregiverState extends State<profileCaregiver> {
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

  String formatThaiDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day} ${thaiMonths[date.month]} ${date.year}';
  }

  Widget buildBox(String text, {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD5E7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF564444),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget buildSelectedDayBox(String day) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD5E7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_box, color: Color(0xFF003F91)),
          const SizedBox(width: 8),
          Text(
            day,
            style: const TextStyle(
              color: Color(0xFF564444),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> goToEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => editprofileCaregiver(profile: widget.profile),
      ),
    );

    if (result == true) {
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')));
    }
  }

  void goToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home(profile: widget.profile)),
    );
  }

  void goToNotificationPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => notification(
          profile: widget.profile,
          startWithMatch: false,
        ),
      ),
    );
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeText = widget.profile.allDayAvailable
        ? 'เวลา : สะดวกตลอดเวลา'
        : 'เวลา : ${widget.profile.startTime} - ${widget.profile.endTime} น.';

    final guarantor = notification.confirmedGuarantor;
    final bool hasGuarantor = guarantor != null &&
        guarantor.name.trim().isNotEmpty &&
        guarantor.phone.trim().isNotEmpty &&
        guarantor.relation.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCE3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: goToEditPage,
                      child: const Text(
                        'แก้ไข',
                        style: TextStyle(
                          color: Color(0xFF564444),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: logout,
                      child: const Text(
                        'ออกจากระบบ',
                        style: TextStyle(
                          color: Color(0xFF564444),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Icon(
                  Icons.account_circle_outlined,
                  size: 100,
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
                children: [
                  Expanded(child: buildBox(widget.profile.fullName)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildBox(
                      widget.profile.nickName.isEmpty
                          ? 'ชื่อ : -'
                          : widget.profile.nickName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: buildBox(
                      widget.profile.phone.isEmpty ? '-' : widget.profile.phone,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildBox(
                      formatThaiDate(widget.profile.birthDate),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: buildBox(
                      widget.profile.gender.isEmpty
                          ? 'เพศ'
                          : widget.profile.gender,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildBox('น้ำหนัก : ${widget.profile.weight}'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildBox('ส่วนสูง : ${widget.profile.height}'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'ที่อยู่',
                style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 10),
              buildBox(
                widget.profile.address.isEmpty ? '-' : widget.profile.address,
              ),
              if (hasGuarantor) ...[
                const SizedBox(height: 18),
                const Text(
                  'ข้อมูลผู้รับรอง',
                  style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
                ),
                const SizedBox(height: 10),
                buildBox('ชื่อผู้รับรอง : ${guarantor.name}'),
                const SizedBox(height: 10),
                buildBox('เบอร์ผู้รับรอง : ${guarantor.phone}'),
                const SizedBox(height: 10),
                buildBox('ความสัมพันธ์ : ${guarantor.relation}'),
              ],
              const SizedBox(height: 18),
              const Text(
                'ระยะทางสะดวก',
                style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 10),
              buildBox(
                widget.profile.province.isEmpty
                    ? 'จังหวัด : -'
                    : 'จังหวัด : ${widget.profile.province}',
              ),
              const SizedBox(height: 18),
              const Text(
                'วันและเวลาสะดวก',
                style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 10),
              if (widget.profile.availableDays.isEmpty)
                buildBox('-')
              else
                ...widget.profile.availableDays.map(
                  (day) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: buildSelectedDayBox(day),
                  ),
                ),
              buildBox(timeText),
              const SizedBox(height: 18),
              const Text(
                'วุฒิประกาศนียบัตร',
                style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 10),
              buildBox(
                widget.profile.degree.isEmpty ? '-' : widget.profile.degree,
              ),
              const SizedBox(height: 18),
              const Text(
                'วันที่จบการศึกษา',
                style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
              ),
              const SizedBox(height: 10),
              buildBox(formatThaiDate(widget.profile.graduationDate)),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: goToHomePage,
              icon: const Icon(
                Icons.home,
                size: 36,
                color: Color(0xFF8FBFFF),
              ),
            ),
            IconButton(
              onPressed: goToNotificationPage,
              icon: const Icon(
                Icons.notifications,
                size: 36,
                color: Color(0xFF8FBFFF),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.account_circle,
                size: 40,
                color: Color(0xFF003F91),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
