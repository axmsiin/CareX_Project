import 'package:carex/User/HomePages/editProfileElderly.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/services/backend_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const Color kMatched = Color(0xFF35CC2D);
  static const Color kMatching = Color(0xFFE4B700);
  static const Color kFailed = Color(0xFFE95257);
  static const String kFont = 'Sarabun';

  late ElderlyData _elderlyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _elderlyData = widget.elderlyData;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (_elderlyData.elderlyId != null && _elderlyData.elderlyId!.isNotEmpty) {
      debugPrint('DEBUG: Fetching detail for ID: ${_elderlyData.elderlyId}');
      final fresh =
          await BackendDataService.fetchElderlyDetail(_elderlyData.elderlyId!);
      if (fresh != null) {
        debugPrint('DEBUG: Fresh data received');
        debugPrint('DEBUG: scheduleType: ${fresh.scheduleType}');
        debugPrint('DEBUG: serviceDatesText: ${fresh.serviceDatesText}');
        debugPrint('DEBUG: startDate: ${fresh.startDate}');
        debugPrint('DEBUG: endDate: ${fresh.endDate}');
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

  bool get isMatched {
    return displayStatus() == 'มีผู้ดูแลแล้ว';
  }

  bool get isMatchFailed {
    return displayStatus() == 'จับคู่ไม่สำเร็จ';
  }

  String displayStatus() {
    final status = _elderlyData.status.trim().toLowerCase();
    switch (status) {
      case 'matched':
        return 'มีผู้ดูแลแล้ว';
      case 'matching':
      case 'pending':
      case 'waiting_confirm':
      case 'รอการจับคู่':
        return 'อยู่ระหว่างการจับคู่';
      case 'failed':
      case 'match_failed':
      case 'caregiver_rejected':
      case 'user_rejected':
        return 'จับคู่ไม่สำเร็จ';
      default:
        return 'อยู่ระหว่างการจับคู่';
    }
  }

  Color statusColor() {
    final status = displayStatus();
    if (status == 'มีผู้ดูแลแล้ว') return kMatched;
    if (status == 'จับคู่ไม่สำเร็จ') return kFailed;
    return kMatching;
  }

  List<String> getAllCareNeeds() {
    return _elderlyData.selectedNeeds.toSet().toList();
  }

  Future<void> goToEditPage() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => editProfileElderly(
          elderlyData: _elderlyData,
          elderlyIndex: widget.elderlyIndex,
        ),
      ),
    );
    if (updated == true) {
      setState(() => isLoading = true);
      await _loadDetail();
    }
  }

  Widget buildBox(
    String text, {
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    double radius = 14,
    double fontSize = 14,
    double height = 1.25,
    TextAlign textAlign = TextAlign.left,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: kPrimary, width: 1.2),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          color: kText,
          fontSize: fontSize,
          fontFamily: kFont,
          height: height,
        ),
      ),
    );
  }

  Widget buildListBox(List<String> items) {
    if (items.isEmpty) return buildBox('-');

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: buildBox(item),
            ),
          )
          .toList(),
    );
  }

  Widget buildSectionTitleWithEdit({
    required String text,
    required VoidCallback onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: kText,
                fontFamily: kFont,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          InkWell(
            onTap: onEdit,
            child: const Text(
              'แก้ไข',
              style: TextStyle(
                fontSize: 16,
                color: kText,
                fontFamily: kFont,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
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

  Widget _buildProfileIcon() {
    return const Center(
      child: Icon(
        Icons.account_circle_outlined,
        size: 112,
        color: kPrimary,
      ),
    );
  }

  Widget _buildCaregiverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ข้อมูลผู้ดูแล',
          style: TextStyle(
            fontSize: 16,
            color: kText,
            fontFamily: kFont,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        if (isMatched)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: kFieldFill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kPrimary, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ชื่อ : ${showValue(_elderlyData.caregiver)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: kText,
                    fontFamily: kFont,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ประเภทผู้ดูแล : ${showValue(_elderlyData.caregiverExperience)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: kText,
                    fontFamily: kFont,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ประสบการณ์ : ${showValue(_elderlyData.caregiverReviewCount)} ปี',
                  style: const TextStyle(
                    fontSize: 14,
                    color: kText,
                    fontFamily: kFont,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'ผู้รับรอง : ',
                        style: TextStyle(
                          fontSize: 14,
                          color: kText,
                          fontFamily: kFont,
                          height: 1.25,
                        ),
                      ),
                      TextSpan(
                        text: '*หากติดต่อผู้ดูแลไม่ได้ให้ไปในการติดต่อฉุกเฉิน',
                        style: TextStyle(
                          fontSize: 14,
                          color: kFailed,
                          fontFamily: kFont,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  showValue(_elderlyData.caregiverBio),
                  style: const TextStyle(
                    fontSize: 14,
                    color: kText,
                    fontFamily: kFont,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  showValue(_elderlyData.caregiverPhone),
                  style: const TextStyle(
                    fontSize: 14,
                    color: kText,
                    fontFamily: kFont,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  showValue(_elderlyData.caregiverProvince),
                  style: const TextStyle(
                    fontSize: 14,
                    color: kText,
                    fontFamily: kFont,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: kFieldFill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kPrimary, width: 1.2),
            ),
            child: Text(
              '*${displayStatus()}',
              style: TextStyle(
                color: statusColor(),
                fontSize: 14,
                fontFamily: kFont,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 22),
      height: 1,
      color: Colors.black54,
    );
  }

  String formatBirthDate(String dateStr) {
    if (dateStr.isEmpty || dateStr == '-') return '-';
    final trimmed = dateStr.trim();
    try {
      // 1. ลอง parse แบบ ISO (2024-04-06)
      final dt = DateTime.tryParse(trimmed);
      if (dt != null) {
        return BackendDataService.toThaiDate(dt);
      }

      // 2. ถ้ามาเป็น 19 กรกฎาคม 2510 (มี พ.ศ.) ให้คืนค่าเดิมเลยเพราะสวยอยู่แล้ว
      if (trimmed.contains('มกราคม') ||
          trimmed.contains('กุมภาพันธ์') ||
          trimmed.contains('มีนาคม') ||
          trimmed.contains('เมษายน') ||
          trimmed.contains('พฤษภาคม') ||
          trimmed.contains('มิถุนายน') ||
          trimmed.contains('กรกฎาคม') ||
          trimmed.contains('สิงหาคม') ||
          trimmed.contains('กันยายน') ||
          trimmed.contains('ตุลาคม') ||
          trimmed.contains('พฤศจิกายน') ||
          trimmed.contains('ธันวาคม')) {
        return trimmed;
      }

      return trimmed;
    } catch (_) {
      return trimmed;
    }
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitleWithEdit(
          text: 'ข้อมูลสุขภาพพื้นฐาน',
          onEdit: goToEditPage,
        ),
        Row(
          children: [
            Expanded(
              child: buildBox(
                showValue(_elderlyData.fullName),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildBox(
                showValue(_elderlyData.nickName),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: buildBox(
                showValue(_elderlyData.phone),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildBox(
                formatBirthDate(_elderlyData.birthDate),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: buildBox(
                showValue(_elderlyData.gender),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildBox(
                'น้ำหนัก: ${showValue(_elderlyData.weight)} กก.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        buildBox(showValue(_elderlyData.underlyingDiseases.isEmpty
            ? 'โรคประจำตัว'
            : _elderlyData.underlyingDiseases.join(', '))),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        buildBox(showValue(_elderlyData.address)),
      ],
    );
  }

  List<DateTime> _parseServiceDates(String text) {
    if (text.isEmpty) return [];
    return text
        .split(',')
        .map((s) {
          final trimmed = s.trim();
          // ลอง parse แบบ ISO (2026-04-11)
          final dt = DateTime.tryParse(trimmed);
          if (dt != null) return dt;

          // ถ้าไม่ใช่ ISO อาจจะเป็นรูปแบบไทย (กรณีข้อมูลเก่า)
          // ฟังก์ชัน formatDateRanges จะจัดการข้อมูลเก่าได้ยากถ้าไม่ใช่ DateTime
          // จึงเน้นที่ ISO เป็นหลัก
          return null;
        })
        .whereType<DateTime>()
        .toList();
  }

  Widget _buildServiceDetailSection() {
    String dateValue = '';

    // พยายามแปลงข้อมูล serviceDatesText จาก ISO เป็นรูปแบบกลุ่มวันที่ภาษาไทย
    final parsedDates = _parseServiceDates(_elderlyData.serviceDatesText);

    if (parsedDates.isNotEmpty) {
      // ใช้ฟังก์ชันที่แก้ไว้ใน BackendDataService เพื่อจัดกลุ่ม (เช่น 11-12, 18-19, 25-26 เมษายน 2569)
      dateValue = BackendDataService.formatDateRanges(parsedDates);
    } else {
      // Fallback กรณีไม่มีข้อมูลใน serviceDatesText หรือ parse ไม่ได้
      dateValue = '${showValue(_elderlyData.startDate)} - ${showValue(_elderlyData.endDate)}';
    }

    final dateText = 'วันที่ : $dateValue';
    debugPrint('DEBUG: Final dateText for UI (Formatted): $dateText');

    final timeText =
        'เวลา : ${showValue(_elderlyData.startTime)} - ${showValue(_elderlyData.endTime)} น.';
    final salaryText = _elderlyData.salaryText.trim().isEmpty
        ? '-'
        : 'วันละ : ${showValue(_elderlyData.salaryText)} บาท';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        const Text(
          'วันและเวลาที่จะรับบริการ',
          style: TextStyle(
            fontSize: 16,
            color: kText,
            fontFamily: kFont,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        buildBox(dateText, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        buildBox(timeText, textAlign: TextAlign.center),
        const SizedBox(height: 18),
        const Text(
          'ราคาค่าจ้าง',
          style: TextStyle(
            fontSize: 16,
            color: kText,
            fontFamily: kFont,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        buildBox(salaryText, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildCareNeedsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        const Text(
          'ความต้องการในการดูแล',
          style: TextStyle(
            fontSize: 16,
            color: kText,
            fontFamily: kFont,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        buildListBox(getAllCareNeeds()),
      ],
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
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: kPrimary),
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 12),
                      _buildProfileIcon(),
                      const SizedBox(height: 18),
                      _buildCaregiverSection(),
                      _buildDivider(),
                      _buildBasicInfoSection(),
                      _buildAddressSection(),
                      _buildServiceDetailSection(),
                      _buildCareNeedsSection(),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}
