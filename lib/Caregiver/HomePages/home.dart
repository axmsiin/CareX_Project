import 'package:carex/Caregiver/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/Caregiver/Profile_Caregiver/profileCaregiver.dart';
import 'package:carex/services/backend_data_service.dart';

class Home extends StatefulWidget {
  final caregiverData profile;

  const Home({super.key, required this.profile});

  static ElderlyMatchData? confirmedElderly;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kCard = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const String kFont = 'Sarabun';

  ElderlyMatchData? _matchedElderly;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _matchedElderly = Home.confirmedElderly;
    _loadMatchedElderlyFromDatabase();
  }

  Future<void> _loadMatchedElderlyFromDatabase() async {
    final current = Home.confirmedElderly;

    if (current == null) {
      if (!mounted) return;
      setState(() {
        _matchedElderly = null;
        _isLoading = false;
      });
      return;
    }

    final elderlyId = current.elderlyId?.trim() ?? '';

    if (elderlyId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _matchedElderly = current;
        _isLoading = false;
      });
      return;
    }

    try {
      final elderlyDetail =
          await BackendDataService.fetchElderlyDetail(elderlyId);

      if (!mounted) return;

      if (elderlyDetail != null) {
        final alias = elderlyDetail.nickName.trim().isNotEmpty
            ? elderlyDetail.nickName.trim()
            : elderlyDetail.fullName.trim();

        final updated = ElderlyMatchData(
          elderlyId: elderlyId,
          fullName: alias,
          age: current.age,
          gender: elderlyDetail.gender.isEmpty
              ? current.gender
              : elderlyDetail.gender,
          province: elderlyDetail.zipcode.isNotEmpty
              ? elderlyDetail.zipcode
              : current.province,
          detail: current.detail,
          disease: elderlyDetail.underlyingDiseases.isEmpty
              ? current.disease
              : elderlyDetail.underlyingDiseases.join(', '),
          schedule: current.schedule,
          phone:
              elderlyDetail.phone.isEmpty ? current.phone : elderlyDetail.phone,
          birthDateText: elderlyDetail.birthDate.isEmpty
              ? current.birthDateText
              : elderlyDetail.birthDate,
          weightText: elderlyDetail.weight.isEmpty
              ? current.weightText
              : '${elderlyDetail.weight} กก.',
          chronicDiseaseText: elderlyDetail.underlyingDiseases.isEmpty
              ? current.chronicDiseaseText
              : elderlyDetail.underlyingDiseases.join(', '),
          address: elderlyDetail.address.isEmpty
              ? current.address
              : elderlyDetail.address,
          serviceDateText: elderlyDetail.serviceDatesText.isEmpty
              ? current.serviceDateText
              : elderlyDetail.serviceDatesText,
          serviceTimeText: (elderlyDetail.startTime.isNotEmpty &&
                  elderlyDetail.endTime.isNotEmpty)
              ? 'เวลา : ${elderlyDetail.startTime} - ${elderlyDetail.endTime} น.'
              : current.serviceTimeText,
          wageText: elderlyDetail.salaryText.isEmpty
              ? current.wageText
              : elderlyDetail.salaryText,
          careNeeds: elderlyDetail.selectedNeeds.isEmpty
              ? current.careNeeds
              : elderlyDetail.selectedNeeds,
        );

        Home.confirmedElderly = updated;
        setState(() {
          _matchedElderly = updated;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _matchedElderly = current;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _matchedElderly = current;
        _isLoading = false;
      });
    }
  }

  void _goToNotification(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => notification(
          profile: widget.profile,
          startWithMatch: false,
          mockMatch: null,
        ),
      ),
    );
  }

  void _goToProfile(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => profileCaregiver(profile: widget.profile),
      ),
    );
  }

  Widget _buildMatchedCard(ElderlyMatchData data) {
    final String displayName =
        data.fullName.trim().isEmpty ? 'ไม่มีข้อมูล' : data.fullName.trim();

    return Container(
      width: double.infinity,
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kPrimary, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: const TextStyle(
                fontSize: 16,
                color: kText,
                fontFamily: kFont,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.arrow_forward_ios,
            size: 34,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Column(
      children: [
        SizedBox(height: 70),
        Center(
          child: Icon(
            Icons.account_circle_outlined,
            size: 250,
            color: kPrimary,
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            'ไม่มีข้อมูล',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: kFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      height: 95,
      decoration: const BoxDecoration(
        color: kBottomBar,
        borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.home,
              size: 42,
              color: kWhite,
            ),
          ),
          IconButton(
            onPressed: () => _goToNotification(context),
            icon: const Icon(
              Icons.notifications,
              size: 42,
              color: kPrimary,
            ),
          ),
          IconButton(
            onPressed: () => _goToProfile(context),
            icon: const Icon(
              Icons.account_circle,
              size: 46,
              color: kPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ElderlyMatchData? data = _matchedElderly;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: kTopBar,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(width: 4),
                    const Text(
                      'ข้อมูลผู้สูงอายุที่ดูแล',
                      style: TextStyle(
                        fontSize: 16,
                        color: kText,
                        fontFamily: kFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                if (_isLoading) ...[
                  const SizedBox(height: 120),
                  const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  ),
                ] else if (data == null) ...[
                  _buildEmptyState(),
                ] else ...[
                  _buildMatchedCard(data),
                ],
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }
}
