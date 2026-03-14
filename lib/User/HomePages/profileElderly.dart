import 'package:flutter/material.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/User/HomePages/editProfileElderly.dart';

class profileElderly extends StatefulWidget {
  final ElderlyData elderlyData;
  final int elderlyIndex;

  const profileElderly({
    super.key,
    required this.elderlyData,
    required this.elderlyIndex,
  });

  @override
  State<profileElderly> createState() => _profileElderlyState();
}

class _profileElderlyState extends State<profileElderly> {
  String showValue(dynamic value) {
    if (value == null) return '-';
    if (value is String && value.trim().isEmpty) return '-';
    return value.toString();
  }

  bool get isMatched => widget.elderlyData.status == 'matched';

  String displayStatus() {
    switch (widget.elderlyData.status) {
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
        return showValue(widget.elderlyData.status);
    }
  }

  Color statusColor() {
    switch (widget.elderlyData.status) {
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
        return const Color(0xFFF04444);
    }
  }

  Widget buildBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD5E7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF564444), fontSize: 14),
      ),
    );
  }

  Widget buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Color(0xFF564444)),
      ),
    );
  }

  Widget buildSectionTitleWithEdit({
    required String text,
    required VoidCallback onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Color(0xFF564444)),
            ),
          ),
          InkWell(
            onTap: onEdit,
            child: const Text(
              'แก้ไข',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF564444),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> splitPipeText(String value, {String noneValue = 'ไม่มี'}) {
    if (value.trim().isEmpty || value.trim() == noneValue) {
      return [];
    }

    return value
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e != noneValue)
        .toList();
  }

  Widget buildListBox(List<String> items) {
    if (items.isEmpty) {
      return buildBox('-');
    }

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: buildBox(item),
            ),
          )
          .toList(),
    );
  }

  List<String> getAllCareNeeds() {
    final List<String> allNeeds = [];

    allNeeds.addAll(widget.elderlyData.selectedNeeds);
    allNeeds.addAll(splitPipeText(widget.elderlyData.eatingCare));
    allNeeds.addAll(splitPipeText(widget.elderlyData.woundCare));
    allNeeds.addAll(splitPipeText(widget.elderlyData.respiratoryCare));
    allNeeds.addAll(splitPipeText(widget.elderlyData.monitoringCare));

    return allNeeds;
  }

  Widget buildNeedList() {
    final allNeeds = getAllCareNeeds();
    return buildListBox(allNeeds);
  }

  Widget buildDiseaseList() {
    final diseases = splitPipeText(
      widget.elderlyData.disease,
      noneValue: 'ไม่มีโรค',
    );

    if (diseases.isEmpty) {
      return buildBox('ไม่มีโรค');
    }

    return Column(
      children: diseases
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: buildBox(item),
            ),
          )
          .toList(),
    );
  }

  String buildServiceDateText() {
    if (widget.elderlyData.serviceDatesText.trim().isNotEmpty) {
      return 'วันที่ : ${widget.elderlyData.serviceDatesText}';
    }

    return 'วันที่ : ${showValue(widget.elderlyData.startDate)} - ${showValue(widget.elderlyData.endDate)}';
  }

  Future<void> goToEditPage() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => editProfileElderly(
          elderlyData: widget.elderlyData,
          elderlyIndex: widget.elderlyIndex,
        ),
      ),
    );

    if (updated == true) {
      setState(() {});
    }
  }

  Widget buildCaregiverCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFD5E7FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ชื่อ : ${showValue(widget.elderlyData.caregiver)}',
            style: const TextStyle(fontSize: 15, color: Color(0xFF564444)),
          ),
          const SizedBox(height: 6),
          const Text(
            'ประเภทผู้ดูแล : PN ผู้ช่วยพยาบาล',
            style: TextStyle(fontSize: 15, color: Color(0xFF564444)),
          ),
          const SizedBox(height: 6),
          Text(
            'ประสบการณ์ : ${showValue(widget.elderlyData.caregiverExperience)}',
            style: const TextStyle(fontSize: 15, color: Color(0xFF564444)),
          ),
          const SizedBox(height: 6),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 15, color: Color(0xFF564444)),
              children: [
                TextSpan(text: 'ผู้รับรอง : '),
                TextSpan(
                  text: '*หากติดต่อผู้ดูแลไม่ได้ ใช้ในการติดต่อฉุกเฉิน',
                  style: TextStyle(color: const Color(0xFFF04444)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'นายจันทร์ หนวดเขี้ยว',
            style: TextStyle(fontSize: 15, color: Color(0xFF564444)),
          ),
          const SizedBox(height: 6),
          Text(
            showValue(widget.elderlyData.caregiverPhone),
            style: const TextStyle(fontSize: 15, color: Color(0xFF564444)),
          ),
          const SizedBox(height: 6),
          Text(
            showValue(widget.elderlyData.caregiverProvince),
            style: const TextStyle(fontSize: 15, color: Color(0xFF564444)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCE3),
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
              const SizedBox(height: 8),
              const Center(
                child: Icon(
                  Icons.account_circle_outlined,
                  size: 110,
                  color: Color(0xFFD5E7FF),
                ),
              ),
              const SizedBox(height: 12),
              if (!isMatched) ...[
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '*${displayStatus()}',
                    style: TextStyle(color: statusColor(), fontSize: 14),
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(color: Color(0xFF564444)),
                const SizedBox(height: 18),
              ] else ...[
                const SizedBox(height: 18),
              ],
              if (isMatched) ...[
                const Text(
                  'ข้อมูลผู้ดูแล',
                  style: TextStyle(fontSize: 16, color: Color(0xFF564444)),
                ),
                const SizedBox(height: 16),
                buildCaregiverCard(),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFF564444)),
                const SizedBox(height: 18),
              ],
              buildSectionTitleWithEdit(
                text: 'ข้อมูลสุขภาพพื้นฐาน',
                onEdit: goToEditPage,
              ),
              Row(
                children: [
                  Expanded(
                    child: buildBox(showValue(widget.elderlyData.fullName)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildBox(showValue(widget.elderlyData.nickName)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: buildBox(showValue(widget.elderlyData.phone)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildBox(showValue(widget.elderlyData.birthDate)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: buildBox(showValue(widget.elderlyData.gender)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildBox(
                      'น้ำหนัก : ${showValue(widget.elderlyData.weight)} กก.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              buildSectionTitle('โรคประจำตัว'),
              buildDiseaseList(),
              const SizedBox(height: 18),
              buildSectionTitle('ที่อยู่'),
              buildBox(showValue(widget.elderlyData.address)),
              const SizedBox(height: 18),
              buildSectionTitle('วันและเวลาที่จะรับบริการ'),
              buildBox(buildServiceDateText()),
              const SizedBox(height: 10),
              buildBox(
                'เวลา : ${showValue(widget.elderlyData.startTime)} - ${showValue(widget.elderlyData.endTime)} น.',
              ),
              const SizedBox(height: 18),
              buildSectionTitle('ราคาค่าจ้าง'),
              buildBox(showValue(widget.elderlyData.salaryText)),
              const SizedBox(height: 18),
              buildSectionTitle('ความต้องการในการดูแล'),
              buildNeedList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 85,
        decoration: const BoxDecoration(
          color: Color(0xFFD5E7FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.home, size: 34, color: Color(0xFF003F91)),
            Icon(Icons.notifications, size: 34, color: Color(0xFF003F91)),
            Icon(Icons.account_circle, size: 36, color: Color(0xFF003F91)),
          ],
        ),
      ),
    );
  }
}
