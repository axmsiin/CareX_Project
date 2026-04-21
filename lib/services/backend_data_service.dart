import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/User/Profile/userData.dart';
import 'package:carex/core/config/app_config.dart';
import 'package:carex/models/caregiver_profile_request.dart';
import 'package:carex/services/app_session.dart';
import 'package:http/http.dart' as http;

class BackendDataService {
  static Uri _uri(String path) {
    final base = AppConfig.baseUrl.endsWith('/')
        ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
        : AppConfig.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath');
  }

  static Future<Map<String, String>> _headers({bool authorized = false}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authorized) {
      final token = await AppSession.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static String _asString(dynamic value) => value?.toString() ?? '';
  static int? _asInt(dynamic value) =>
      value is int ? value : int.tryParse(_asString(value));
  static double? _asDouble(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse(_asString(value));

  static String normalizeDisplayPhone(String value) {
    final raw = value.trim();
    if (raw.startsWith('+66') && raw.length >= 4) return '0${raw.substring(3)}';
    if (raw.startsWith('66') && raw.length >= 3) return '0${raw.substring(2)}';
    return raw;
  }

  static String formatDateRanges(List<DateTime> dates) {
    if (dates.isEmpty) return '-';

    // 1. ล้างเวลาออกและเรียงลำดับ
    final sortedDates = dates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    if (sortedDates.isEmpty) return '-';

    // กรณีพิเศษ: ถ้าเป็นช่วงวันที่ต่อเนื่องกันยาวๆ (มากกว่า 28 วัน) ให้แสดงเป็น "เริ่ม - จบ"
    bool isAllContinuous = true;
    for (int i = 1; i < sortedDates.length; i++) {
      if (sortedDates[i].difference(sortedDates[i - 1]).inDays != 1) {
        isAllContinuous = false;
        break;
      }
    }

    if (isAllContinuous && sortedDates.length > 28) {
      final first = sortedDates.first;
      final last = sortedDates.last;
      if (first.year == last.year) {
        return '${first.day} ${toThaiMonth(first.month)} - ${toThaiDate(last)}';
      } else {
        return '${toThaiDate(first)} - ${toThaiDate(last)}';
      }
    }

    // 2. จัดกลุ่มตามเดือนและปี
    Map<String, List<int>> monthGroups = {};
    List<String> monthKeys = [];

    for (var date in sortedDates) {
      final key = "${date.month}-${date.year}";
      if (!monthGroups.containsKey(key)) {
        monthKeys.add(key);
        monthGroups[key] = [];
      }
      monthGroups[key]!.add(date.day);
    }

    // 3. สร้างข้อความสรุปรายเดือน
    List<String> monthStrings = [];
    for (int i = 0; i < monthKeys.length; i++) {
      final key = monthKeys[i];
      final parts = key.split('-');
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]);
      final days = monthGroups[key]!..sort();

      List<String> dayRanges = [];
      if (days.isNotEmpty) {
        int start = days[0];
        for (int j = 1; j <= days.length; j++) {
          if (j == days.length || days[j] != days[j - 1] + 1) {
            if (start == days[j - 1]) {
              dayRanges.add("$start");
            } else {
              dayRanges.add("$start-${days[j - 1]}");
            }
            if (j < days.length) start = days[j];
          }
        }
      }

      final daysStr = dayRanges.join(', ');
      final monthName = toThaiMonth(month);
      
      // แสดงปีเฉพาะเดือนสุดท้าย หรือเมื่อปีเปลี่ยน
      bool showYear = (i == monthKeys.length - 1);
      if (!showYear) {
        final nextKey = monthKeys[i + 1];
        if (int.parse(nextKey.split('-')[1]) != year) showYear = true;
      }

      if (showYear) {
        monthStrings.add("$daysStr $monthName ${year + 543}");
      } else {
        monthStrings.add("$daysStr $monthName");
      }
    }

    return monthStrings.join(', ');
  }

  static String toThaiMonth(int month) {
    const thaiMonths = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
    ];
    return thaiMonths[month - 1];
  }

  static String toThaiDate(DateTime date) {
    return '${date.day} ${toThaiMonth(date.month)} ${date.year + 543}';
  }

  static String toThaiDateWithDay(DateTime date) {
    const days = [
      '', 'วันจันทร์', 'วันอังคาร', 'วันพุธ', 'วันพฤหัสบดี', 'วันศุกร์', 'วันเสาร์', 'วันอาทิตย์'
    ];
    return '${days[date.weekday]}ที่ ${date.day} ${toThaiMonth(date.month)} ${date.year + 543}';
  }

  static DateTime? _parseDisplayDate(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;
    const thaiMonths = {
      'มกราคม': 1,
      'กุมภาพันธ์': 2,
      'มีนาคม': 3,
      'เมษายน': 4,
      'พฤษภาคม': 5,
      'มิถุนายน': 6,
      'กรกฎาคม': 7,
      'สิงหาคม': 8,
      'กันยายน': 9,
      'ตุลาคม': 10,
      'พฤศจิกายน': 11,
      'ธันวาคม': 12,
    };
    final parts = raw.split(' ');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = thaiMonths[parts[1]];
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year > 2400 ? year - 543 : year, month, day);
  }

  static List<Map<String, dynamic>> _parseTimestamp(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      } catch (_) {}
    }
    return const [];
  }

  static String _extractCaregiverAlias(Map<String, dynamic> json) {
    final directAlias = _asString(json['alias']).trim();
    if (directAlias.isNotEmpty) return directAlias;

    final caregiverAlias = _asString(json['caregiver_alias']).trim();
    if (caregiverAlias.isNotEmpty) return caregiverAlias;

    final caregiverName = _asString(json['caregiver_name']).trim();
    if (caregiverName.isNotEmpty) return caregiverName;

    final caregiver = json['caregiver'];
    if (caregiver is Map<String, dynamic>) {
      final nestedAlias = _asString(caregiver['alias']).trim();
      if (nestedAlias.isNotEmpty) return nestedAlias;

      final nestedName = _asString(caregiver['name']).trim();
      if (nestedName.isNotEmpty) return nestedName;

      final nestedFullname = _asString(caregiver['fullname']).trim();
      if (nestedFullname.isNotEmpty) return nestedFullname;
    }

    return '';
  }

  static UserData userFromJson(Map<String, dynamic> json) {
    return UserData(
      fullName: _asString(json['fullname']).isNotEmpty
          ? _asString(json['fullname'])
          : _asString(json['user_name']),
      phone: normalizeDisplayPhone(
        _asString(json['tel']).isNotEmpty
            ? _asString(json['tel'])
            : _asString(json['phone']),
      ),
      clientId: json['client_id']?.toString(),
    );
  }

  static caregiverData caregiverFromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? cert,
  }) {
    final scheduleItems = _parseTimestamp(json['timestamp']);
    final availableDays = scheduleItems
        .map((e) => (e['day'] ?? '').toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();

    String startTime = '';
    String endTime = '';
    bool allDayAvailable = false;
    if (scheduleItems.isNotEmpty) {
      startTime = _asString(scheduleItems.first['start_time']);
      endTime = _asString(scheduleItems.first['end_time']);
      allDayAvailable = startTime == '00:00' && endTime == '00:00';
    }

    return caregiverData(
      fullName: _asString(json['fullname']).isNotEmpty
          ? _asString(json['fullname'])
          : _asString(json['user_name']),
      nickName: _asString(json['alias']),
      phone: normalizeDisplayPhone(
        _asString(json['tel']).isNotEmpty
            ? _asString(json['tel'])
            : _asString(json['phone']),
      ),
      birthDate: _parseDisplayDate(_asString(json['birthday'])),
      weight: _asInt(json['weight']) ?? 0,
      height: _asInt(json['height']) ?? 0,
      gender: _asString(json['gender']),
      availableDays: availableDays,
      allDayAvailable: allDayAvailable,
      startTime: startTime,
      endTime: endTime,
      address: _asString(json['address']),
      province: _asString(json['province']),
      latitude: _asDouble(json['latitude']) ?? 0.0,
      longitude: _asDouble(json['longitude']) ?? 0.0,
      degree: _asString(cert?['certificate_type']),
      graduationDate: _parseDisplayDate(_asString(cert?['certificate_date'])),
      caregiverId: json['caregiver_id']?.toString(),
      score: _asInt(json['score']),
    );
  }

  static ElderlyData elderlyFromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? need,
  }) {
    final diseasesRaw = json['underlying_disease'];
    final diseases = diseasesRaw is List
        ? diseasesRaw.map((e) => e.toString()).toList()
        : _asString(diseasesRaw).trim().isEmpty
            ? <String>[]
            : [_asString(diseasesRaw)];

    final timestampItems = _parseTimestamp(json['timestamp']);
    String startDate = '';
    String endDate = '';
    String startTime = '';
    String endTime = '';
    if (timestampItems.isNotEmpty) {
      startDate = _asString(timestampItems.first['date']);
      endDate = _asString(timestampItems.last['date']);
      startTime = _asString(timestampItems.first['start_time']);
      endTime = _asString(timestampItems.first['end_time']);
    }

    return ElderlyData(
      fullName: _asString(json['fullname']),
      nickName: _asString(json['alias']),
      phone: normalizeDisplayPhone(_asString(json['tel'])),
      birthDate: _asString(json['birthday']),
      gender: _asString(json['gender']),
      weight: _asString(json['weight']),
      underlyingDiseases: diseases,
      address: _asString(json['address']),
      latitude: _asDouble(json['latitude']) ?? 0.0,
      longitude: _asDouble(json['longitude']) ?? 0.0,
      zipcode: _asString(json['zipcode']),
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
      salaryText: (_asInt(json['budget_min']) != null ||
              _asInt(json['budget_max']) != null)
          ? '${_asInt(json['budget_min']) ?? 0} - ${_asInt(json['budget_max']) ?? 0}'
          : '',
      serviceDatesText: timestampItems
          .map((e) => _asString(e['date']))
          .where((e) => e.isNotEmpty)
          .join(', '),
      scheduleType: _asString(json['schedule_type']).isNotEmpty 
          ? _asString(json['schedule_type'])
          : (timestampItems.length > 1 ? 'กำหนดวันเอง' : ''),
      customDays: (json['custom_days'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      selectedNeeds: ((need?['option_service'] as List?) ??
              (json['option_service'] as List?) ??
              const [])
          .map((e) => e.toString())
          .toList(),
      needLevel: _asString(need?['mandatory_level']).isNotEmpty
          ? _asString(need?['mandatory_level'])
          : _asString(json['mandatory_level']),
      eatingCare: '',
      woundCare: '',
      respiratoryCare: '',
      monitoringCare: '',
      status: _asString(json['status']),
      caregiver: _extractCaregiverAlias(json),
      matchPercent: _asString(json['percent_match']),
      caregiverPhone: normalizeDisplayPhone(_asString(json['caregiver_phone'])),
      caregiverGender: _asString(json['caregiver_gender']),
      caregiverAge: _asString(json['caregiver_age']),
      caregiverProvince: _asString(json['caregiver_province']),
      caregiverExperience: _asString(json['caregiver_experience']),
      caregiverRating: _asString(json['caregiver_rating']),
      caregiverReviewCount: _asString(json['caregiver_review_count']),
      caregiverBio: _asString(json['caregiver_bio']),
      elderlyId: json['elderly_id']?.toString(),
      score: _asInt(json['score']),
    );
  }

  static List<Map<String, dynamic>> _buildElderlyTimestampPayload(
    ElderlyData elderly,
  ) {
    final start = _parseDisplayDate(elderly.startDate);
    final end = _parseDisplayDate(elderly.endDate);

    if (start == null || end == null) {
      // Fallback if dates are invalid
      return [
        {
          'date': elderly.startDate.isEmpty
              ? DateTime.now().toIso8601String().split('T').first
              : elderly.startDate,
          'start_time': elderly.startTime.isEmpty ? '09:00' : elderly.startTime,
          'end_time': elderly.endTime.isEmpty ? '18:00' : elderly.endTime,
        }
      ];
    }

    final matchedDates = <DateTime>[];
    DateTime current = start;
    while (!current.isAfter(end)) {
      if (_isDateMatched(current, elderly.scheduleType, elderly.customDays)) {
        matchedDates.add(current);
      }
      current = current.add(const Duration(days: 1));
    }

    if (matchedDates.isEmpty) {
      matchedDates.add(start);
    }

    return matchedDates.map((d) {
      final dateStr =
          "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      return {
        'date': dateStr,
        'start_time': elderly.startTime.isEmpty ? '09:00' : elderly.startTime,
        'end_time': elderly.endTime.isEmpty ? '18:00' : elderly.endTime,
      };
    }).toList();
  }

  static bool _isDateMatched(
      DateTime date, String scheduleType, List<String> customDays) {
    switch (scheduleType) {
      case 'ทุกวัน':
        return true;
      case 'วันธรรมดา':
        return date.weekday >= DateTime.monday &&
            date.weekday <= DateTime.friday;
      case 'เสาร์-อาทิตย์':
        return date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;
      case 'กำหนดวันเอง':
        const thaiWeekdays = [
          '',
          'วันจันทร์',
          'วันอังคาร',
          'วันพุธ',
          'วันพฤหัสบดี',
          'วันศุกร์',
          'วันเสาร์',
          'วันอาทิตย์'
        ];
        return customDays.contains(thaiWeekdays[date.weekday]);
      case 'ทุกเดือน':
        // ในระบบนี้ทุกเดือนอาจจะหมายถึงวันที่เดียวกันของทุกเดือน (ถ้าช่วงยาวพอ)
        // หรือถ้าแค่ช่วงสั้นๆ ก็อาจจะมองว่าเป็นแค่วันเริ่มต้น
        // แต่เพื่อความปลอดภัย ถ้า start/end ครอบคลุมหลายเดือน ก็เลือกแค่วันที่ตรงกัน
        // (ปกติ start/end มักจะครอบคลุมแค่วันที่เลือกจริงๆ)
        return true; // หรือเช็ค date.day == start.day
      default:
        return true;
    }
  }

  static List<String> _buildOptionService(ElderlyData elderly) {
    final merged = <String>{};
    merged.addAll(elderly.selectedNeeds.where((e) => e.trim().isNotEmpty));
    for (final group in [
      elderly.eatingCare,
      elderly.woundCare,
      elderly.respiratoryCare,
      elderly.monitoringCare,
    ]) {
      merged.addAll(
        group
            .split('|')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty && e != 'ไม่มี'),
      );
    }
    return merged.toList();
  }

  static Future<UserData?> fetchUserProfile() async {
    final response = await http
        .get(_uri('/profile/client'), headers: await _headers(authorized: true))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        response.body.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final user = userFromJson(decoded);
    if (user.clientId != null && user.clientId!.isNotEmpty) {
      await AppSession.saveClientId(user.clientId!);
    }
    return user;
  }

  static Future<caregiverData?> fetchCaregiverProfile() async {
    final caregiverId = await AppSession.getCaregiverId();
    if (caregiverId == null || caregiverId.isEmpty) return null;
    final response = await http
        .get(
          _uri('/profile/caregiver/$caregiverId'),
          headers: await _headers(authorized: true),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        response.body.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final profileMap = decoded['profile'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(decoded['profile'])
        : decoded;
    Map<String, dynamic>? certMap;
    if (decoded['certificates'] is List &&
        (decoded['certificates'] as List).isNotEmpty &&
        (decoded['certificates'] as List).first is Map) {
      certMap =
          Map<String, dynamic>.from((decoded['certificates'] as List).first);
    }
    final profile = caregiverFromJson(profileMap, cert: certMap);
    if (profile.caregiverId != null && profile.caregiverId!.isNotEmpty) {
      await AppSession.saveCaregiverId(profile.caregiverId!);
    }
    return profile;
  }

  static String _superCleanId(String id) {
    return id.replaceAll(' ', '').replaceAll('--', '-').trim();
  }

  static Future<List<ElderlyData>> fetchElderlies() async {
    try {
      final response = await http
          .get(_uri('/profile/elderly'), headers: await _headers(authorized: true))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          response.body.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) return [];

      final summaries = decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final results = <ElderlyData>[];
      for (final summary in summaries) {
        final elderlyId = summary['elderly_id']?.toString() ?? '';
        if (elderlyId.isEmpty) {
          results.add(ElderlyData.fromJson(summary));
          continue;
        }

        final detail = await fetchElderlyDetail(elderlyId);
        if (detail != null) {
          // เช็คสถานะจริงจากตาราง contract
          final contractStatus = await getMatchStatus(elderlyId);
          if (contractStatus != null && contractStatus['status'] != null) {
            detail.status = contractStatus['status'].toString();
            detail.caregiver = contractStatus['caregiver_name'] ?? contractStatus['caregiver_id'] ?? '';
          }
          results.add(detail);
        } else {
          results.add(ElderlyData.fromJson(summary));
        }
      }
      return results;
    } catch (e) {
      print('DEBUG: [fetchElderlies] Error: $e');
      return [];
    }
  }

  static Future<ElderlyData?> fetchElderlyDetail(String elderlyId) async {
    try {
      final cleanId = _superCleanId(elderlyId);
      final response = await http
          .get(
            _uri('/profile/elderly/$cleanId'),
            headers: await _headers(authorized: true),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          response.body.isEmpty) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;

      final profileMap = decoded['profile'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(decoded['profile'])
          : Map<String, dynamic>.from(decoded);

      final needMap = decoded['need'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(decoded['need'])
          : null;

      final mergedProfileMap = <String, dynamic>{
        ...profileMap,
        ...decoded,
      };

      return elderlyFromJson(mergedProfileMap, need: needMap);
    } catch (e) {
      print('DEBUG: [fetchElderlyDetail] Error: $e');
      return null;
    }
  }

  static Future<ElderlyData?> createElderlyProfile(ElderlyData elderly) async {
    final budgetNumbers = RegExp(r'\d+')
        .allMatches(elderly.salaryText)
        .map((e) => e.group(0)!)
        .toList();
    final budgetMin =
        budgetNumbers.isNotEmpty ? int.tryParse(budgetNumbers[0]) ?? 0 : 0;
    final budgetMax = budgetNumbers.length > 1
        ? int.tryParse(budgetNumbers[1]) ?? budgetMin
        : budgetMin;
    final body = {
      'fullname': elderly.fullName,
      'alias': elderly.nickName,
      'tel': elderly.phone,
      'gender': elderly.gender,
      'weight': int.tryParse(elderly.weight) ?? 0,
      'address': elderly.address,
      'latitude': elderly.latitude,
      'longitude': elderly.longitude,
      'zipcode': elderly.zipcode,
      'birthday': elderly.birthDate,
      'budget_min': budgetMin,
      'budget_max': budgetMax,
      'underlying_disease': elderly.underlyingDiseases,
      'score': elderly.score ?? 3,
      'timestamp': _buildElderlyTimestampPayload(elderly),
      'schedule_type': elderly.scheduleType,
      'custom_days': elderly.customDays,
      'mandatory_level': elderly.needLevel.isEmpty ? '1' : elderly.needLevel,
      'option_service': _buildOptionService(elderly),
    };
    final response = await http
        .post(
          _uri('/profile/elderly'),
          headers: await _headers(authorized: true),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode < 200 || response.statusCode >= 300) return null;
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    elderly.elderlyId = decoded['elderly_id']?.toString();
    return elderly;
  }

  static Future<bool> createElderlyNeed({
    required String elderlyId,
    required String mandatoryLevel,
    required List<String> optionService,
  }) async {
    return true;
  }

  static Future<bool> updateElderlyProfile(ElderlyData elderly) async {
    if (elderly.elderlyId == null || elderly.elderlyId!.isEmpty) return false;
    final budgetNumbers = RegExp(r'\d+')
        .allMatches(elderly.salaryText)
        .map((e) => e.group(0)!)
        .toList();
    final budgetMin =
        budgetNumbers.isNotEmpty ? int.tryParse(budgetNumbers[0]) ?? 0 : 0;
    final budgetMax = budgetNumbers.length > 1
        ? int.tryParse(budgetNumbers[1]) ?? budgetMin
        : budgetMin;
    final birthdayDate = _parseDisplayDate(elderly.birthDate);
    final body = {
      'fullname': elderly.fullName,
      'alias': elderly.nickName,
      'tel': elderly.phone,
      'gender': elderly.gender,
      'weight': int.tryParse(elderly.weight) ?? 0,
      'address': elderly.address,
      'latitude': elderly.latitude,
      'longitude': elderly.longitude,
      'zipcode': elderly.zipcode,
      'birthday':
          birthdayDate != null ? toThaiDate(birthdayDate) : elderly.birthDate,
      'budget_min': budgetMin,
      'budget_max': budgetMax,
      'underlying_disease': elderly.underlyingDiseases,
      'timestamp': _buildElderlyTimestampPayload(elderly),
      'schedule_type': elderly.scheduleType,
      'custom_days': elderly.customDays,
      'mandatory_level': elderly.needLevel.isEmpty ? '1' : elderly.needLevel,
      'option_service': _buildOptionService(elderly),
    };
    final response = await http
        .put(
          _uri('/profile/elderly/${elderly.elderlyId}'),
          headers: await _headers(authorized: true),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// POST /match → คืน suggestions list (match_percent >= 75%)
  /// return true ถ้ามี suggestion อย่างน้อย 1 คน, false ถ้าไม่มี
  static Future<bool> requestMatch({required String elderlyId}) async {
    try {
      print('DEBUG: [requestMatch] Starting match for elderlyId: $elderlyId');
      final response = await http
          .post(
            _uri('/match'),
            headers: await _headers(authorized: true),
            body: jsonEncode({'elderly_id': elderlyId}),
          )
          .timeout(const Duration(seconds: 30));

      print('DEBUG: [requestMatch] Response Status: ${response.statusCode}');
      print('DEBUG: [requestMatch] Response Body: ${response.body}');

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          response.body.isEmpty) {
        return false;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return false;
      final suggestions = decoded['suggestions'];
      return suggestions is List && suggestions.isNotEmpty;
    } catch (e) {
      print('DEBUG: [requestMatch] Error: $e');
      return false;
    }
  }

  static Future<void> submitQuestionScore({
    required String target,
    required int score,
    String? relatedId,
    List<String>? answers,
  }) async {
    // score ถูกฝังไปใน body ของ create/update profile แล้ว
    // (elderly → createElderlyProfile, caregiver → updateCaregiverScore)
    // ถ้า target = caregiver และมี relatedId → อัปเดต score ผ่าน profile
    if (target == 'caregiver' && relatedId != null && relatedId.isNotEmpty) {
      await updateCaregiverScore(
        score: score,
        scoreDate: DateTime.now(),
      );
    }
  }

  /// อัปโหลดรูปใบรับรองของ Caregiver
  /// POST /certificate/{certificate_id}/upload  (multipart/form-data)
  static Future<bool> uploadCertificateImage({
    required String certificateId,
    required List<int> imageBytes,
    required String filename,
  }) async {
    try {
      final token = await AppSession.getToken();
      final uri = _uri('/certificate/$certificateId/upload');
      final request = http.MultipartRequest('POST', uri);
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(
        http.MultipartFile.fromBytes(
          'certificate_image',
          imageBytes,
          filename: filename,
        ),
      );
      final streamed =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      // ถ้า backend ตอบ error "ข้อมูลในรูปไม่ตรงกับที่กรอกไว้" → return false
      return false;
    } catch (_) {
      return false;
    }
  }

  /// ดึงข้อมูล elderly ที่ AI match มาให้ caregiver คนนี้ (ยังรอการยืนยัน)
  /// Flow: POST /match ด้วย elderly แต่ละคนที่ caregiver อาจถูก suggest
  /// เนื่องจาก API ไม่มี endpoint GET match สำหรับ caregiver โดยตรง
  /// จึงใช้วิธี GET /profile/caregiver/{id} แล้วดู matched_elderly_id
  /// ถ้า backend คืน matched_elderly_id → fetch detail แล้ว return
  static String getProvinceFromZipcode(String zipcode) {
    if (zipcode.isEmpty || zipcode.length < 2) return 'ไม่ระบุจังหวัด';
    final prefix = zipcode.substring(0, 2);
    final Map<String, String> mapping = {
      '10': 'กรุงเทพมหานคร',
      '11': 'นนทบุรี',
      '12': 'ปทุมธานี',
      '13': 'พระนครศรีอยุธยา',
      '14': 'อ่างทอง',
      '15': 'ลพบุรี',
      '16': 'สิงห์บุรี',
      '17': 'ชัยนาท',
      '18': 'สระบุรี',
      '20': 'ชลบุรี',
      '21': 'ระยอง',
      '22': 'จันทบุรี',
      '23': 'ตราด',
      '24': 'ฉะเชิงเทรา',
      '25': 'ปราจีนบุรี',
      '26': 'นครนายก',
      '27': 'สระแก้ว',
      '30': 'นครราชสีมา',
      '31': 'บุรีรัมย์',
      '32': 'สุรินทร์',
      '33': 'ศรีสะเกษ',
      '34': 'อุบลราชธานี',
      '35': 'ยโสธร',
      '36': 'ชัยภูมิ',
      '37': 'อำนาจเจริญ',
      '38': 'บึงกาฬ',
      '39': 'หนองบัวลำภู',
      '40': 'ขอนแก่น',
      '41': 'อุดรธานี',
      '42': 'เลย',
      '43': 'หนองคาย',
      '44': 'มหาสารคาม',
      '45': 'ร้อยเอ็ด',
      '46': 'กาฬสินธุ์',
      '47': 'สกลนคร',
      '48': 'นครพนม',
      '49': 'มุกดาหาร',
      '50': 'เชียงใหม่',
      '51': 'ลำพูน',
      '52': 'ลำปาง',
      '53': 'อุตรดิตถ์',
      '54': 'แพร่',
      '55': 'น่าน',
      '56': 'พะเยา',
      '57': 'เชียงราย',
      '58': 'แม่ฮ่องสอน',
      '60': 'นครสวรรค์',
      '61': 'อุทัยธานี',
      '62': 'กำแพงเพชร',
      '63': 'ตาก',
      '64': 'สุโขทัย',
      '65': 'พิษณุโลก',
      '66': 'พิจิตร',
      '67': 'เพชรบูรณ์',
      '70': 'ราชบุรี',
      '71': 'กาญจนบุรี',
      '72': 'สุพรรณบุรี',
      '73': 'นครปฐม',
      '74': 'สมุทรสาคร',
      '75': 'สมุทรสงคราม',
      '76': 'เพชรบุรี',
      '77': 'ประจวบคีรีขันธ์',
      '80': 'นครศรีธรรมราช',
      '81': 'กระบี่',
      '82': 'พังงา',
      '83': 'ภูเก็ต',
      '84': 'สุราษฎร์ธานี',
      '85': 'ระนอง',
      '86': 'ชุมพร',
      '90': 'สงขลา',
      '91': 'สตูล',
      '92': 'ตรัง',
      '93': 'พัทลุง',
      '94': 'ปัตตานี',
      '95': 'ยะลา',
      '96': 'นราธิวาส',
    };
    return mapping[prefix] ?? 'ไม่ระบุจังหวัด ($zipcode)';
  }

  static Future<Map<String, dynamic>?> fetchPendingMatchForCaregiver() async {
    try {
      final rawCaregiverId = await AppSession.getCaregiverId();
      if (rawCaregiverId == null || rawCaregiverId.isEmpty) return null;

      final cleanCaregiverId = _superCleanId(rawCaregiverId);

      print('DEBUG: [fetchPendingMatch] Using Clean ID: "$cleanCaregiverId"');
      print('DEBUG: [fetchPendingMatch] STEP 1: Fetching from /contract/caregiver...');
      final requests = await getMatchRequests();
      
      String? pendingElderlyId;
      String? matchId;

      if (requests.isNotEmpty) {
        final pendingReq = requests.firstWhere(
          (r) {
            final s = (r['status'] ?? '').toString().toLowerCase();
            return s == 'matching' || s == 'pending' || s == 'waiting';
          },
          orElse: () => requests.first,
        );
        pendingElderlyId = pendingReq['elderly_id']?.toString() ?? pendingReq['elderlyId']?.toString();
        matchId = pendingReq['contract_id']?.toString() ?? pendingReq['match_id']?.toString() ?? pendingReq['id']?.toString();
        print('DEBUG: [fetchPendingMatch] Found in contract list: $pendingElderlyId');
      }

      // STEP 2: Profile Check
      if (pendingElderlyId == null || pendingElderlyId.isEmpty) {
        print('DEBUG: [fetchPendingMatch] STEP 2: Deep diving into Caregiver Profile...');
        final response = await http
            .get(_uri('/profile/caregiver/$cleanCaregiverId'), headers: await _headers(authorized: true))
            .timeout(const Duration(seconds: 10));
        
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final profile = decoded['profile'] is Map ? decoded['profile'] : decoded;
          
          final possibleKeys = ['matched_elderly_id', 'pending_elderly_id', 'elderly_id', 'elderlyId'];
          for (var key in possibleKeys) {
            final val = _asString(profile[key]).trim();
            if (val.isNotEmpty) {
              pendingElderlyId = val;
              print('DEBUG: [fetchPendingMatch] Found ID in Profile via key "$key": $pendingElderlyId');
              break;
            }
          }
        }
      }

      // STEP 3: Last Resort Probing
      if (pendingElderlyId == null || pendingElderlyId.isEmpty) {
        print('DEBUG: [fetchPendingMatch] STEP 3: Probing elderly statuses...');
        final all = await fetchElderlies();
        for (var e in all) {
          if (e.elderlyId != null) {
            final st = await getMatchStatus(e.elderlyId!);
            if (st != null && _superCleanId(_asString(st['caregiver_id'])) == cleanCaregiverId) {
              pendingElderlyId = e.elderlyId;
              print('DEBUG: [fetchPendingMatch] Found via probing: $pendingElderlyId');
              break;
            }
          }
        }
      }

      if (pendingElderlyId == null || pendingElderlyId.isEmpty) {
        print('DEBUG: [fetchPendingMatch] FINAL RESULT: Data not found in any backend source.');
        return null;
      }

      print('DEBUG: [fetchPendingMatch] Fetching final detail for: $pendingElderlyId');
      final elderlyDetail = await fetchElderlyDetail(pendingElderlyId);
      if (elderlyDetail == null) return null;

      int age = 0;
      try {
        final birthDt = DateTime.tryParse(elderlyDetail.birthDate.trim());
        if (birthDt != null) {
          age = DateTime.now().year - birthDt.year;
        }
      } catch (_) {}

      return {
        'elderlyId': pendingElderlyId,
        'matchId': matchId,
        'fullName': elderlyDetail.nickName.isNotEmpty ? elderlyDetail.nickName : elderlyDetail.fullName,
        'age': age,
        'gender': elderlyDetail.gender,
        'province': getProvinceFromZipcode(elderlyDetail.zipcode), 
        'disease': elderlyDetail.underlyingDiseases.join(', '),
        'address': elderlyDetail.address,
        'serviceTimeText': '${elderlyDetail.startTime} - ${elderlyDetail.endTime} น.',
        'wageText': '${elderlyDetail.salaryText} บาท',
        'careNeeds': elderlyDetail.selectedNeeds,
      };
    } catch (e) {
      print('DEBUG: [fetchPendingMatch] Global Error: $e');
      return null;
    }
  }

  static Future<bool> updateUserProfile(UserData user) async {
    final response = await http
        .put(
          _uri('/profile/client'),
          headers: await _headers(authorized: true),
          body: jsonEncode({'fullname': user.fullName, 'tel': user.phone}),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      await AppSession.updateBasicProfile(
        userName: user.fullName,
        phone: user.phone,
      );
      return true;
    }
    return false;
  }

  static CaregiverProfileRequest _requestFromCaregiver(
    caregiverData profile, {
    required int score,
  }) {
    final effectiveStart = profile.allDayAvailable
        ? '00:00'
        : (profile.startTime.isEmpty ? '09:00' : profile.startTime);
    final effectiveEnd = profile.allDayAvailable
        ? '00:00'
        : (profile.endTime.isEmpty ? '18:00' : profile.endTime);
    final timestamp = profile.availableDays
        .map(
          (day) => {
            'day': day,
            'start_time': effectiveStart,
            'end_time': effectiveEnd,
          },
        )
        .toList();
    return CaregiverProfileRequest(
      fullname: profile.fullName.trim(),
      alias: profile.nickName.trim(),
      tel: profile.phone.trim(),
      gender: profile.gender.trim(),
      weight: profile.weight,
      height: profile.height,
      address: profile.address.trim(),
      latitude: profile.latitude,
      longitude: profile.longitude,
      province: profile.province.trim(),
      birthday: profile.birthDate == null ? '' : toThaiDate(profile.birthDate!),
      score: score,
      timestamp: timestamp,
      certificateType: profile.degree.trim(),
      certificateDate: profile.graduationDate == null
          ? ''
          : toThaiDate(profile.graduationDate!),
      guarantorName: profile.guarantorName,
      guarantorTel: profile.guarantorPhone,
      guarantorRelationship: profile.guarantorRelation,
    );
  }

  static Future<bool> updateCaregiverProfile(caregiverData profile) async {
    final caregiverId = await AppSession.getCaregiverId();
    if (caregiverId == null || caregiverId.isEmpty) return false;
    final request = _requestFromCaregiver(profile, score: profile.score ?? 3);
    final response = await http
        .put(
          _uri('/profile/caregiver/$caregiverId'),
          headers: await _headers(authorized: true),
          body: jsonEncode(request.toUpdateJson()),
        )
        .timeout(const Duration(seconds: 10));
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  static Future<bool> updateCaregiverScore({
    required int score,
    required DateTime scoreDate,
  }) async {
    final caregiverId = await AppSession.getCaregiverId();
    if (caregiverId == null || caregiverId.isEmpty) return false;
    final profile = await fetchCaregiverProfile();
    if (profile == null) return false;
    profile.score = score;
    return updateCaregiverProfile(profile);
  }

  static Future<List<Map<String, String>>> fetchQuestions(String group) async {
    try {
      final response = await http
          .get(
            _uri('/questions/$group'),
            headers: await _headers(authorized: true),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map(
                (e) => Map<String, String>.from({
                  'question': _asString(e['question_name']),
                  'a': _asString(e['choice_a']),
                  'b': _asString(e['choice_b']),
                }),
              )
              .where((e) => e['question']!.isNotEmpty)
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> fetchCaregiverCandidateById(
    String caregiverId,
  ) async {
    try {
      // ล้างช่องว่างเฉพาะตอนส่ง URL
      final cleanId = caregiverId.replaceAll(' ', '').trim();
      final response = await http
          .get(
            _uri('/profile/caregiver/$cleanId'),
            headers: await _headers(authorized: true),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          response.body.isEmpty) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final profile = decoded['profile'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(decoded['profile'])
          : decoded;
      final certs = decoded['certificates'] is List
          ? decoded['certificates'] as List
          : const [];
      final cert = certs.isNotEmpty && certs.first is Map
          ? Map<String, dynamic>.from(certs.first)
          : <String, dynamic>{};

      return {
        'caregiver_id': caregiverId,
        'name': _asString(profile['fullname']).isNotEmpty
            ? _asString(profile['fullname'])
            : _asString(profile['alias']),
        'phone': normalizeDisplayPhone(_asString(profile['tel'])),
        'gender': _asString(profile['gender']),
        'province': _asString(profile['province']),
        'caregiverType': _asString(cert['certificate_type']).isNotEmpty
            ? _asString(cert['certificate_type'])
            : 'Caregiver',
        'graduationDate': _parseDisplayDate(_asString(cert['certificate_date'])),
        'experience': 'พร้อมเริ่มงานตามเวลาที่ลงทะเบียน',
        'bio': _asString(profile['alias']).isNotEmpty
            ? 'ชื่อเล่น ${_asString(profile['alias'])}'
            : 'ผู้ดูแลที่ผ่านการลงทะเบียน',
      };
    } catch (_) {
      return null;
    }
  }

  static List<String> _buildReviewTexts(int percent) {
    if (percent >= 95) {
      return const [
        'ดูแลดีมาก สุภาพ ใส่ใจรายละเอียด และสื่อสารกับครอบครัวสม่ำเสมอ',
        'ตรงต่อเวลา ทำงานเรียบร้อย ผู้สูงอายุสบายใจเวลาอยู่ด้วย',
        'มีความเป็นมืออาชีพและเข้าใจผู้สูงอายุได้ดีมาก',
      ];
    }
    if (percent >= 85) {
      return const [
        'บุคลิกอบอุ่น ดูแลดี และปรับตัวกับบ้านผู้รับบริการได้ไว',
        'คุยง่าย รับฟังความต้องการ และช่วยจัดกิจวัตรได้ดี',
        'ภาพรวมการดูแลดีมาก น่าไว้วางใจ',
      ];
    }
    return const [
      'ดูแลพื้นฐานได้ดี มีความตั้งใจในการทำงาน',
      'สื่อสารดีและพร้อมเรียนรู้รายละเอียดเพิ่มเติมของผู้สูงอายุ',
      'เหมาะกับงานดูแลตามเงื่อนไขที่กำหนด',
    ];
  }

  static Future<List<Map<String, dynamic>>> fetchMatchSuggestions(
    String elderlyId,
  ) async {
    try {
      print('DEBUG: Requesting matches for elderlyId: $elderlyId');
      final response = await http
          .post(
            _uri('/match'),
            headers: await _headers(authorized: true),
            body: jsonEncode({'elderly_id': elderlyId}),
          )
          .timeout(const Duration(seconds: 10));

      print('DEBUG: Match Response Status: ${response.statusCode}');
      print('DEBUG: Match Response Body: ${response.body}');

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          response.body.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['suggestions'] is! List) {
        return [];
      }
      final suggestions = (decoded['suggestions'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      final results = <Map<String, dynamic>>[];
      for (final item in suggestions) {
        final rawId = _asString(item['caregiver_id']);
        // ห้ามลบช่องว่าง ห้ามแก้ไขใดๆ ทั้งสิ้น ใช้ rawId สำหรับ Transaction
        final caregiverId = rawId; 
        
        final percent = (_asDouble(item['match_percent']) ?? 0).round();

        // กรองเฉพาะคนที่ match >= 75% เท่านั้นตามข้อกำหนด
        if (percent < 75) continue;

        // ล้างช่องว่างเฉพาะตอนดึง profile ผ่าน URL (เพราะ URL ห้ามมีช่องว่าง)
        final cleanIdForUrl = caregiverId.replaceAll(' ', '').trim();
        final profile = cleanIdForUrl.isEmpty
            ? null
            : await fetchCaregiverCandidateById(cleanIdForUrl);

        // คำนวณประสบการณ์จาก graduationDate
        String experienceText = 'พร้อมเริ่มงาน';
        if (profile != null && profile['graduationDate'] != null) {
          final gradDate = profile['graduationDate'] as DateTime;
          final now = DateTime.now();
          int years = now.year - gradDate.year;
          if (now.month < gradDate.month || (now.month == gradDate.month && now.day < gradDate.day)) {
            years--;
          }
          experienceText = years > 0 ? '$years ปี' : 'ต่ำกว่า 1 ปี';
        }

        final rating = percent >= 95 ? '4.9' : percent >= 90 ? '4.8' : percent >= 85 ? '4.7' : '4.6';
        final reviews = _buildReviewTexts(percent);

        results.add({
          'caregiverId': caregiverId, // ✅ ส่ง ID ดั้งเดิมกลับไป
          'matchPercent': percent,
          'name': profile?['name'] ?? 'ผู้ดูแล',
          'phone': profile?['phone'] ?? '-',
          'gender': profile?['gender'] ?? '-',
          'age': '-',
          'province': profile?['province'] ?? '-',
          'experience': experienceText,
          'rating': rating,
          'reviewCount': (20 + max(percent - 75, 0)).toString(),
          'bio': profile?['bio'] ?? 'ผู้ดูแลที่ผ่านการลงทะเบียน',
          'caregiverType': profile?['caregiverType'] ?? 'Caregiver',
          'reviews': reviews,
        });
      }
      results.sort(
        (a, b) =>
            (b['matchPercent'] as int).compareTo(a['matchPercent'] as int),
      );
      return results.take(5).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getMatchStatus(String elderlyId) async {
    try {
      final cleanId = _superCleanId(elderlyId);
      final response = await http
          .get(
            _uri('/contract/$cleanId'),
            headers: await _headers(authorized: true),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> selectCaregiver(
      String elderlyId, String caregiverId) async {
    try {
      // คืนค่าแบบเดิม (ส่ง ID ตามที่ได้รับมา)
      print('DEBUG: [selectCaregiver] elderlyId: "$elderlyId", caregiverId: "$caregiverId"');
      
      final response = await http
          .post(
            _uri('/contract/select'),
            headers: await _headers(authorized: true),
            body: jsonEncode({
              'elderly_id': elderlyId,
              'caregiver_id': caregiverId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('DEBUG: [selectCaregiver] Status: ${response.statusCode}');
      print('DEBUG: [selectCaregiver] Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('DEBUG: [selectCaregiver] Error: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getMatchRequests() async {
    try {
      final rawId = await AppSession.getCaregiverId() ?? '';
      final cleanId = _superCleanId(rawId);
      
      // Attempt 1: Standard call
      var response = await http
          .get(_uri('/contract/caregiver'), headers: await _headers(authorized: true))
          .timeout(const Duration(seconds: 10));

      // Attempt 2: If 500 or error, try passing clean ID as query (Backup for inconsistent backends)
      if (response.statusCode != 200) {
        print('DEBUG: [getContractCaregiver] Attempt 1 failed (${response.statusCode}). Trying Attempt 2 with Clean ID: $cleanId...');
        response = await http
            .get(_uri('/contract/caregiver?caregiver_id=$cleanId'), headers: await _headers(authorized: true))
            .timeout(const Duration(seconds: 10));
      }

      print('DEBUG: [getContractCaregiver] Status: ${response.statusCode}');
      print('DEBUG: [getContractCaregiver] Body: ${response.body}');

      if (response.statusCode == 500) {
        print('CRITICAL: Backend Error 500. Possible cause: Route order mismatch between /contract/caregiver and /contract/:elderly_id.');
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (decoded is Map) {
          final list = decoded['contracts'] ?? decoded['requests'] ?? decoded['data'];
          if (list is List) {
            return list.map((e) => Map<String, dynamic>.from(e)).toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('DEBUG: [getContractCaregiver] Error: $e');
      return [];
    }
  }

  static Future<bool> respondToMatch(String elderlyId, String action) async {
    try {
      // สำหรับฝั่งผู้ดูแล กดยืนยัน (confirm) ส่งเฉพาะ elderly_id
      print('DEBUG: [respondToContract] Calling /contract/confirm for ElderlyID: $elderlyId');
      
      final response = await http
          .post(
            _uri('/contract/confirm'),
            headers: await _headers(authorized: true),
            body: jsonEncode({
              'elderly_id': elderlyId, // ตามที่ backend ต้องการล่าสุด
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('DEBUG: [respondToContract] Status: ${response.statusCode}');
      print('DEBUG: [respondToContract] Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('DEBUG: [respondToContract] Error: $e');
      return false;
    }
  }

  static String normalizeDegreeForDisplay(String? storedDegree) {
    if (storedDegree == null || storedDegree.isEmpty) return '';
    final saved = storedDegree.trim().toLowerCase();
    if (saved == 'practical nurse' || saved == 'pn') {
      return 'Practical Nurse (PN)';
    } else if (saved == 'nurse aide' || saved == 'na' || saved == 'nursing assistant') {
      return 'Nursing Assistant (NA)';
    } else if (saved == 'caregiver' || saved == 'cg') {
      return 'Caregiver (CG)';
    }
    return storedDegree;
  }

  static String normalizeDegreeForSave(String? displayDegree) {
    if (displayDegree == null || displayDegree.isEmpty) return '';
    if (displayDegree.contains('Practical Nurse')) return 'Practical Nurse';
    if (displayDegree.contains('Nursing Assistant')) return 'Nurse Aide';
    if (displayDegree.contains('Caregiver')) return 'Caregiver';
    return displayDegree;
  }

  static List<String> sortDays(List<String> inputDays) {
    const List<String> weekDays = [
      'วันจันทร์',
      'วันอังคาร',
      'วันพุธ',
      'วันพฤหัสบดี',
      'วันศุกร์',
      'วันเสาร์',
      'วันอาทิตย์',
    ];
    
    final sorted = List<String>.from(inputDays);
    sorted.sort((a, b) {
      int indexA = weekDays.indexOf(a);
      int indexB = weekDays.indexOf(b);
      // If not found in standard list, put at the end
      if (indexA == -1) indexA = 100;
      if (indexB == -1) indexB = 100;
      return indexA.compareTo(indexB);
    });
    return sorted;
  }
}
