import 'package:carex/User/HomePages/editProfileElderly.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/services/backend_data_service.dart';
import 'package:flutter/material.dart';

class profileElderly extends StatefulWidget {
  final ElderlyData elderlyData;
  final int elderlyIndex;

  const profileElderly({super.key, required this.elderlyData, required this.elderlyIndex});

  @override
  State<profileElderly> createState() => _profileElderlyState();
}

class _profileElderlyState extends State<profileElderly> {
  late ElderlyData _elderlyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _elderlyData = widget.elderlyData;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (_elderlyData.elderlyId != null) {
      final fresh = await BackendDataService.fetchElderlyDetail(_elderlyData.elderlyId!);
      if (fresh != null) {
        _elderlyData = fresh;
      }
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  String showValue(dynamic value) {
    if (value == null) return '-';
    if (value is String && value.trim().isEmpty) return '-';
    return value.toString();
  }

  bool get isMatched => _elderlyData.status == 'matched';

  String displayStatus() {
    switch (_elderlyData.status) {
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
        return showValue(_elderlyData.status);
    }
  }

  Color statusColor() {
    switch (_elderlyData.status) {
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

  Widget buildBox(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(color: const Color(0xFFFCFAFF), borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: const TextStyle(color: Color(0xFF564444), fontSize: 14)),
      );

  Widget buildSectionTitleWithEdit({required String text, required VoidCallback onEdit}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [Expanded(child: Text(text, style: const TextStyle(fontSize: 16, color: Color(0xFF564444)))), InkWell(onTap: onEdit, child: const Text('แก้ไข', style: TextStyle(fontSize: 16, color: Color(0xFF564444), decoration: TextDecoration.underline)))]),
      );

  List<String> splitPipeText(String value, {String noneValue = 'ไม่มี'}) {
    if (value.trim().isEmpty || value.trim() == noneValue) return [];
    return value.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty && e != noneValue).toList();
  }

  Widget buildListBox(List<String> items) => items.isEmpty ? buildBox('-') : Column(children: items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: buildBox(item))).toList());

  List<String> getAllCareNeeds() {
    final allNeeds = <String>[];
    allNeeds.addAll(_elderlyData.selectedNeeds);
    allNeeds.addAll(splitPipeText(_elderlyData.eatingCare));
    allNeeds.addAll(splitPipeText(_elderlyData.woundCare));
    allNeeds.addAll(splitPipeText(_elderlyData.respiratoryCare));
    allNeeds.addAll(splitPipeText(_elderlyData.monitoringCare));
    return allNeeds;
  }

  Future<void> goToEditPage() async {
    final updated = await Navigator.push(context, MaterialPageRoute(builder: (context) => editProfileElderly(elderlyData: _elderlyData, elderlyIndex: widget.elderlyIndex)));
    if (updated == true) {
      setState(() => isLoading = true);
      await _loadDetail();
    }
  }

  Widget buildCaregiverCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(color: const Color(0xFFFCFAFF), borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ชื่อ : ${showValue(_elderlyData.caregiver)}', style: const TextStyle(fontSize: 15, color: Color(0xFF564444))),
          const SizedBox(height: 8),
          Text('เบอร์โทร : ${showValue(_elderlyData.caregiverPhone)}', style: const TextStyle(fontSize: 15, color: Color(0xFF564444))),
          const SizedBox(height: 8),
          Text('เพศ : ${showValue(_elderlyData.caregiverGender)}', style: const TextStyle(fontSize: 15, color: Color(0xFF564444))),
          const SizedBox(height: 8),
          Text('จังหวัด : ${showValue(_elderlyData.caregiverProvince)}', style: const TextStyle(fontSize: 15, color: Color(0xFF564444))),
          const SizedBox(height: 8),
          Text('คะแนนรีวิว : ${showValue(_elderlyData.caregiverRating)}', style: const TextStyle(fontSize: 15, color: Color(0xFF564444))),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0E8),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerRight, child: Text('*${displayStatus()}', style: TextStyle(color: statusColor(), fontSize: 14, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  buildSectionTitleWithEdit(text: 'ข้อมูลผู้สูงอายุ', onEdit: goToEditPage),
                  buildBox(showValue(_elderlyData.fullName)),
                  const SizedBox(height: 10),
                  buildBox(showValue(_elderlyData.nickName)),
                  const SizedBox(height: 10),
                  buildBox(showValue(_elderlyData.phone)),
                  const SizedBox(height: 10),
                  buildBox(showValue(_elderlyData.birthDate)),
                  const SizedBox(height: 10),
                  buildBox(showValue(_elderlyData.gender)),
                  const SizedBox(height: 10),
                  buildBox(showValue(_elderlyData.weight)),
                  const SizedBox(height: 10),
                  buildBox(showValue(_elderlyData.address)),
                  const SizedBox(height: 20),
                  const Text('โรคประจำตัว', style: TextStyle(fontSize: 16, color: Color(0xFF564444))),
                  const SizedBox(height: 10),
                  buildListBox(splitPipeText(_elderlyData.disease, noneValue: 'ไม่มีโรค').isEmpty ? const ['ไม่มีโรค'] : splitPipeText(_elderlyData.disease, noneValue: 'ไม่มีโรค')),
                  const SizedBox(height: 20),
                  const Text('รายละเอียดการดูแล', style: TextStyle(fontSize: 16, color: Color(0xFF564444))),
                  const SizedBox(height: 10),
                  buildBox(_elderlyData.serviceDatesText.isNotEmpty ? 'วันที่ : ${_elderlyData.serviceDatesText}' : 'วันที่ : ${showValue(_elderlyData.startDate)} - ${showValue(_elderlyData.endDate)}'),
                  const SizedBox(height: 10),
                  buildBox('เวลา : ${showValue(_elderlyData.startTime)} - ${showValue(_elderlyData.endTime)}'),
                  const SizedBox(height: 10),
                  buildBox('งบประมาณ : ${showValue(_elderlyData.salaryText)}'),
                  const SizedBox(height: 20),
                  const Text('ความต้องการการดูแล', style: TextStyle(fontSize: 16, color: Color(0xFF564444))),
                  const SizedBox(height: 10),
                  buildListBox(getAllCareNeeds()),
                  const SizedBox(height: 20),
                  if (isMatched) ...[
                    const Text('ข้อมูลผู้ดูแล', style: TextStyle(fontSize: 16, color: Color(0xFF564444))),
                    const SizedBox(height: 10),
                    buildCaregiverCard(),
                  ],
                ]),
              ),
      ),
    );
  }
}
