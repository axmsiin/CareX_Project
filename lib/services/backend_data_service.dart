import 'dart:async';
import 'dart:convert';

import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/User/Profile/userData.dart';
import 'package:carex/core/config/app_config.dart';
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

      print('🔑 Current Token: $token');
    }
    return headers;
  }

  static Map<String, dynamic>? _extractMap(dynamic decoded, {String? matchUserId}) {
    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded['data']);
      }
      return Map<String, dynamic>.from(decoded);
    }
    // Handle case where API returns an array
    if (decoded is List && decoded.isNotEmpty) {
      // If matchUserId is provided, try to find matching item
      if (matchUserId != null && matchUserId.isNotEmpty) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final itemUserId = item['user_id']?.toString();
            if (itemUserId == matchUserId) {
              print('BackendDataService: Found matching caregiver for user_id=$matchUserId');
              return Map<String, dynamic>.from(item);
            }
          }
        }
        print('BackendDataService: No matching caregiver found for user_id=$matchUserId in ${decoded.length} items');
      }
      // Fallback to first item if no match or no userId filter
      final firstItem = decoded.first;
      if (firstItem is Map<String, dynamic>) {
        print('BackendDataService: Using first item from array (${decoded.length} items total)');
        return Map<String, dynamic>.from(firstItem);
      }
    }
    return null;
  }

  static List<dynamic>? _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      for (final key in const [
        'data',
        'items',
        'results',
        'elderlies',
        'list'
      ]) {
        final value = decoded[key];
        if (value is List) return value;
      }
    }
    return null;
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String _asString(dynamic value) => value?.toString() ?? '';

  static String normalizeDisplayPhone(String value) {
    final raw = value.trim();

    if (raw.startsWith('+66') && raw.length >= 4) {
      return '0${raw.substring(3)}';
    }

    if (raw.startsWith('66') && raw.length >= 3) {
      return '0${raw.substring(2)}';
    }

    return raw;
  }

  static String toIsoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static Future<Map<String, dynamic>?> _authorizedGetFirst(
    List<String> candidates, {
    String? matchUserId,
  }) async {
    final headers = await _headers(authorized: true);

    for (final path in candidates) {
      try {
        final response = await http
            .get(_uri(path), headers: headers)
            .timeout(const Duration(seconds: 10));

        print('BackendDataService: GET $path');
        print('BackendDataService: status=${response.statusCode}');
        print('BackendDataService: body=${response.body}');

        if (response.statusCode >= 200 &&
            response.statusCode < 300 &&
            response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body);
          final map = _extractMap(decoded, matchUserId: matchUserId);
          if (map != null) return map;
        }
      } catch (e) {
        print('BackendDataService: GET $path error=$e');
      }
    }
    return null;
  }

  static Future<List<dynamic>?> _authorizedGetListFirst(
    List<String> candidates,
  ) async {
    final headers = await _headers(authorized: true);

    for (final path in candidates) {
      try {
        final response = await http
            .get(_uri(path), headers: headers)
            .timeout(const Duration(seconds: 10));

        print('BackendDataService: GET LIST $path');
        print('BackendDataService: status=${response.statusCode}');
        print('BackendDataService: body=${response.body}');

        if (response.statusCode >= 200 &&
            response.statusCode < 300 &&
            response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body);
          final list = _extractList(decoded);
          if (list != null) return list;
        }
      } catch (e) {
        print('BackendDataService: GET LIST $path error=$e');
      }
    }
    return null;
  }

  static UserData userFromJson(Map<String, dynamic> json) {
    return UserData(
      fullName: _asString(json['user_name']).isNotEmpty
          ? _asString(json['user_name'])
          : _asString(json['fullname']),
      phone: normalizeDisplayPhone(
        _asString(json['phone']).isNotEmpty
            ? _asString(json['phone'])
            : _asString(json['tel']),
      ),
    );
  }

  static caregiverData caregiverFromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? cert,
  }) {
    print('BackendDataService: caregiverFromJson input=$json');
    
    final rawTimestamp = json['timestamp'];
    final List<Map<String, dynamic>> scheduleItems = [];

    if (rawTimestamp is List) {
      for (final item in rawTimestamp) {
        if (item is Map) {
          scheduleItems.add(Map<String, dynamic>.from(item));
        }
      }
    } else if (rawTimestamp is String && rawTimestamp.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawTimestamp);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              scheduleItems.add(Map<String, dynamic>.from(item));
            }
          }
        }
      } catch (e) {
        print('BackendDataService: timestamp decode error=$e for value: $rawTimestamp');
      }
    }
    
    print('BackendDataService: parsed ${scheduleItems.length} schedule items');

    final availableDays = scheduleItems
        .map((e) => (e['day'] ?? '').toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();

    bool allDayAvailable = false;
    String startTime = '';
    String endTime = '';

    if (scheduleItems.isNotEmpty) {
      final firstStart = (scheduleItems.first['start_time'] ?? '').toString();
      final firstEnd = (scheduleItems.first['end_time'] ?? '').toString();

      allDayAvailable = firstStart == '00:00' && firstEnd == '00:00';
      startTime = firstStart;
      endTime = firstEnd;
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
      gender: _asString(json['gender']),
      weight: _asInt(json['weight']) ?? 0,
      height: _asInt(json['height']) ?? 0,
      address: _asString(json['address']),
      province: _asString(json['province']),
      latitude: _asDouble(json['latitude']) ?? 0.0,
      longitude: _asDouble(json['longitude']) ?? 0.0,
      birthDate: DateTime.tryParse(_asString(json['birthday'])),
      score: _asInt(json['score']),
      caregiverId: _asInt(json['caregiver_id']),
      availableDays: availableDays,
      allDayAvailable: allDayAvailable,
      startTime: startTime,
      endTime: endTime,
      degree: _asString(cert?['certificate_type']),
      graduationDate: DateTime.tryParse(_asString(cert?['certificate_date'])),
    );
  }

  static ElderlyData elderlyFromJson(Map<String, dynamic> json) {
    return ElderlyData(
      fullName: _asString(json['fullname']),
      nickName: _asString(json['alias']),
      phone: normalizeDisplayPhone(_asString(json['tel'])),
      birthDate: _asString(json['birthday']),
      gender: _asString(json['gender']),
      weight: _asString(json['weight']),
      disease: _asString(json['underlying_disease']),
      address: _asString(json['address']),
      startDate: _asString(json['start_date']),
      endDate: _asString(json['end_date']),
      startTime: _asString(json['start_time']),
      endTime: _asString(json['end_time']),
      salaryText: _asString(json['budget']),
      serviceDatesText: _asString(json['service_date']),
      scheduleType: _asString(json['schedule_type']),
      customDays: ((json['custom_days'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      selectedNeeds: ((json['service_needs'] as List?) ??
              (json['selected_needs'] as List?) ??
              const [])
          .map((e) => e.toString())
          .toList(),
      needLevel: _asString(json['care_level']).isNotEmpty
          ? _asString(json['care_level'])
          : _asString(json['mandatory_level']),
      eatingCare: _asString(json['eating_care']),
      woundCare: _asString(json['wound_care']),
      respiratoryCare: _asString(json['respiratory_care']),
      monitoringCare: _asString(json['monitoring_care']),
      status: _asString(json['status']),
      caregiver: _asString(json['caregiver_name']),
      matchPercent: _asString(json['percent_match']),
      caregiverPhone: normalizeDisplayPhone(_asString(json['caregiver_phone'])),
      caregiverGender: _asString(json['caregiver_gender']),
      caregiverAge: _asString(json['caregiver_age']),
      caregiverProvince: _asString(json['caregiver_province']),
      caregiverExperience: _asString(json['caregiver_experience']),
      caregiverRating: _asString(json['caregiver_rating']),
      caregiverReviewCount: _asString(json['caregiver_review_count']),
      caregiverBio: _asString(json['caregiver_bio']),
      elderlyId: _asInt(json['elderly_id']),
      score: _asInt(json['score']),
    );
  }

  static Future<String?> _getCaregiverIdFromUserId(
    String userId, {
    required String token,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Try to fetch caregiver list/data and search for matching user_id
    final listPaths = [
      '/caregivers',
      '/caregiver/list',
      '/profile/caregiver/list',
      '/api/caregivers',
    ];

    for (final path in listPaths) {
      try {
        final res = await http
            .get(_uri(path), headers: headers)
            .timeout(const Duration(seconds: 8));

        print('BackendDataService: GET $path -> ${res.statusCode}');

        if (res.statusCode >= 200 && res.statusCode < 300 && res.body.isNotEmpty) {
          final decoded = jsonDecode(res.body);
          final list = _extractList(decoded);

          if (list != null) {
            // Search through caregivers to find matching user_id
            for (final item in list) {
              if (item is Map<String, dynamic>) {
                final itemUserId = item['user_id']?.toString();
                final caregiverId = item['caregiver_id']?.toString() ??
                    item['id']?.toString();

                if (itemUserId == userId && caregiverId != null && caregiverId.isNotEmpty) {
                  print('BackendDataService: Found caregiverId=$caregiverId for userId=$userId');
                  return caregiverId;
                }
              }
            }
          }
        }
      } catch (e) {
        print('BackendDataService: _getCaregiverIdFromUserId error on $path -> $e');
      }
    }

    // Fallback: try individual path-parameter endpoints
    final pathPaths = [
      '/caregiver/user/$userId',
      '/profile/caregiver/user/$userId',
      '/user/$userId/caregiver',
    ];

    for (final path in pathPaths) {
      try {
        final res = await http
            .get(_uri(path), headers: headers)
            .timeout(const Duration(seconds: 8));

        print('BackendDataService: GET $path -> ${res.statusCode}');

        if (res.statusCode >= 200 && res.statusCode < 300 && res.body.isNotEmpty) {
          final decoded = jsonDecode(res.body);
          final map = _extractMap(decoded);

          if (map != null) {
            final caregiverId = map['caregiver_id']?.toString() ??
                map['id']?.toString();

            if (caregiverId != null && caregiverId.isNotEmpty) {
              print('BackendDataService: Found caregiverId=$caregiverId from path=$path');
              return caregiverId;
            }
          }
        }
      } catch (e) {
        print('BackendDataService: _getCaregiverIdFromUserId error on $path -> $e');
      }
    }

    return null;
  }

  static Future<Map<String, String?>> detectRoleAfterLogin({
    required String userId,
    required String token,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Future<Map<String, String?>?> tryGet(
      String path, {
      required String role,
    }) async {
      try {
        final res = await http
            .get(_uri(path), headers: headers)
            .timeout(const Duration(seconds: 8));

        print('BackendDataService: GET $path -> ${res.statusCode} ${res.body}');

        if (res.statusCode >= 200 &&
            res.statusCode < 300 &&
            res.body.isNotEmpty) {
          final decoded = jsonDecode(res.body);
          final map = _extractMap(decoded);

          if (map != null) {
            if (role == 'caregiver') {
              final caregiverId = map['caregiver_id']?.toString() ??
                  map['id']?.toString() ??
                  map['caregiverId']?.toString();

              if (caregiverId != null && caregiverId.isNotEmpty) {
                return {
                  'role': 'caregiver',
                  'caregiver_id': caregiverId,
                  'client_id': null,
                  'score': map['score']?.toString(),
                };
              }

              if (map['fullname'] != null || map['alias'] != null) {
                return {
                  'role': 'caregiver',
                  'caregiver_id': null,
                  'client_id': null,
                  'score': map['score']?.toString(),
                };
              }
            }

            if (role == 'client') {
              final clientId = map['client_id']?.toString() ??
                  map['id']?.toString() ??
                  map['clientId']?.toString();

              if (clientId != null && clientId.isNotEmpty) {
                return {
                  'role': 'client',
                  'client_id': clientId,
                  'caregiver_id': null,
                  'score': null,
                };
              }

              if (map['fullname'] != null || map['tel'] != null) {
                return {
                  'role': 'client',
                  'client_id': null,
                  'caregiver_id': null,
                  'score': null,
                };
              }
            }
          }
        }
      } catch (e) {
        print('BackendDataService: detectRoleAfterLogin error on $path -> $e');
      }
      return null;
    }

    // Try to fetch caregiver profile using user_id -> caregiver_id mapping
    final caregiverIdFromMapping = await _getCaregiverIdFromUserId(
      userId,
      token: token,
    );

    if (caregiverIdFromMapping != null && caregiverIdFromMapping.isNotEmpty) {
      final caregiverCandidates = [
        '/profile/caregiver?caregiver_id=$caregiverIdFromMapping',
        '/profile/caregiver/$caregiverIdFromMapping',
        '/caregiver/$caregiverIdFromMapping',
      ];

      for (final path in caregiverCandidates) {
        final result = await tryGet(path, role: 'caregiver');
        if (result != null) return result;
      }
    }

    final clientCandidates = [
      '/profile/client?user_id=$userId',
      '/profile/client/user/$userId',
      '/client?user_id=$userId',
      '/client/user/$userId',
    ];

    for (final path in clientCandidates) {
      final result = await tryGet(path, role: 'client');
      if (result != null) return result;
    }

    return {
      'role': null,
      'caregiver_id': null,
      'client_id': null,
      'score': null,
    };
  }

  static Future<UserData?> fetchUserProfile() async {
    // ตาม API Doc: GET /profile/client (ดึงจาก token อัตโนมัติ)
    final map = await _authorizedGetFirst([
      '/profile/client',
    ]);
    
    if (map == null) return null;
    
    final userData = userFromJson(map);
    
    // บันทึก client_id ถ้ามี
    if (userData.clientId != null && userData.clientId!.isNotEmpty) {
      await AppSession.saveClientId(userData.clientId!);
      print('✅ Saved client_id from profile: ${userData.clientId}');
    }
    
    return userData;
  }

  static Future<Map<String, dynamic>?> fetchCaregiverCertificate() async {
    final userId = await AppSession.getUserId();
    final caregiverId = await AppSession.getCaregiverId();

    final map = await _authorizedGetFirst([
      if (caregiverId != null && caregiverId.isNotEmpty)
        '/certificate/caregiver/$caregiverId',
      if (userId != null) '/certificate/caregiver?user_id=$userId',
      if (userId != null) '/caregivercertificate?user_id=$userId',
      if (userId != null) '/profile/caregiver/certificate?user_id=$userId',
    ]);

    return map;
  }

  static Future<caregiverData?> fetchCaregiverProfile() async {
    final userId = await AppSession.getUserId();
    final caregiverId = await AppSession.getCaregiverId();

    print(
      'BackendDataService: fetchCaregiverProfile() userId=$userId caregiverId=$caregiverId',
    );

    // ตาม API Doc: GET /profile/caregiver/{caregiver_id}
    // ต้องมี caregiver_id เท่านั้น
    if (caregiverId == null || caregiverId.isEmpty) {
      print('BackendDataService: fetchCaregiverProfile -> caregiverId is null/empty');
      return null;
    }

    final map = await _authorizedGetFirst(
      ['/profile/caregiver/$caregiverId'],
      matchUserId: userId,
    );

    if (map == null) {
      print('BackendDataService: fetchCaregiverProfile -> map is null');
      return null;
    }

    // ตาม API v2.1: response มี structure {"profile": {...}, "certificates": [...]}
    Map<String, dynamic> profileData;
    Map<String, dynamic>? certData;
    
    if (map['profile'] != null) {
      // API v2.1 format
      profileData = Map<String, dynamic>.from(map['profile']);
      
      // ดึง certificate แรก (ถ้ามี)
      if (map['certificates'] is List && (map['certificates'] as List).isNotEmpty) {
        certData = Map<String, dynamic>.from((map['certificates'] as List).first);
      }
    } else {
      // Legacy format - ใช้ map ตรงๆ
      profileData = map;
      certData = null;
    }

    final profile = caregiverFromJson(profileData, cert: certData);

    print(
      'BackendDataService: caregiver parsed fullName=${profile.fullName} '
      'phone=${profile.phone} caregiverId=${profile.caregiverId} '
      'days=${profile.availableDays}',
    );

    return profile;
  }

  static Future<List<ElderlyData>> fetchElderlies() async {
    final userId = await AppSession.getUserId();
    final list = await _authorizedGetListFirst([
      if (userId != null) '/profile/elderly?client_id=$userId',
      if (userId != null) '/profile/elderly/client/$userId',
      '/profile/elderly',
      '/elderly',
    ]);
    if (list == null) return [];
    return list
        .whereType<Map>()
        .map((e) => elderlyFromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<ElderlyData?> fetchElderlyDetail(int elderlyId) async {
    final map = await _authorizedGetFirst([
      '/profile/elderly/$elderlyId',
    ]);
    
    if (map == null) return null;
    
    // ตาม API v2.1: response มี structure {"profile": {...}, "need": {...}}
    Map<String, dynamic> profileData;
    
    if (map['profile'] != null) {
      // API v2.1 format
      profileData = Map<String, dynamic>.from(map['profile']);
      
      // เพิ่ม need data ถ้ามี
      if (map['need'] != null) {
        final needData = Map<String, dynamic>.from(map['need']);
        profileData['care_level'] = needData['mandatory_level'];
        profileData['service_needs'] = needData['option_service'];
      }
    } else {
      // Legacy format
      profileData = map;
    }
    
    return elderlyFromJson(profileData);
  }

  static Future<ElderlyData?> createElderlyProfile(ElderlyData elderly) async {
    final userId = await AppSession.getUserId();
    if (userId == null) return null;

    final zipcodeMatch = RegExp(r'(\d{5})').firstMatch(elderly.address);
    final budgetDigits = elderly.salaryText.replaceAll(RegExp(r'[^0-9]'), '');

    final body = {
      'client_id': userId,
      'fullname': elderly.fullName,
      'alias': elderly.nickName,
      'tel': elderly.phone,
      'gender': elderly.gender,
      'weight': int.tryParse(elderly.weight) ?? 0,
      'address': elderly.address,
      'zipcode': zipcodeMatch?.group(1) ?? '',
      'birthday': elderly.birthDate,
      'budget': int.tryParse(budgetDigits.isEmpty ? '0' : budgetDigits) ?? 0,
      'underlying_disease': elderly.disease,
    };

    final headers = await _headers(authorized: true);
    try {
      final response = await http
          .post(
            _uri('/profile/elderly'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      print(
          'BackendDataService: POST /profile/elderly status=${response.statusCode}');
      print('BackendDataService: body=${response.body}');

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final map = _extractMap(decoded);
        if (map != null) return elderlyFromJson(map);
      }
    } catch (e) {
      print('BackendDataService: createElderlyProfile error=$e');
    }
    return null;
  }

  // ตาม API v2.1: PUT /profile/elderly/{elderly_id}
  static Future<bool> updateElderlyProfile(ElderlyData elderly) async {
    if (elderly.elderlyId == null) return false;

    final zipcodeMatch = RegExp(r'(\d{5})').firstMatch(elderly.address);
    final budgetDigits = elderly.salaryText.replaceAll(RegExp(r'[^0-9]'), '');

    // แปลงวันที่เป็นรูปแบบไทย พ.ศ.
    String? birthdayThai;
    if (elderly.birthDate.isNotEmpty) {
      final date = DateTime.tryParse(elderly.birthDate);
      if (date != null) {
        birthdayThai = toThaiDate(date);
        print('BackendDataService: Converting elderly birthday $date -> "$birthdayThai"');
      }
    }

    final body = {
      'fullname': elderly.fullName,
      'alias': elderly.nickName,
      'tel': elderly.phone,
      'gender': elderly.gender,
      'weight': int.tryParse(elderly.weight) ?? 0,
      'address': elderly.address,
      'zipcode': zipcodeMatch?.group(1) ?? '',
      if (birthdayThai != null) 'birthday': birthdayThai,
      'budget_min': int.tryParse(budgetDigits.isEmpty ? '0' : budgetDigits) ?? 0,
      'budget_max': int.tryParse(budgetDigits.isEmpty ? '0' : budgetDigits) ?? 0,
      'underlying_disease': elderly.disease,
    };

    print('BackendDataService: PUT elderly body=$body');

    final headers = await _headers(authorized: true);
    try {
      final response = await http
          .put(
            _uri('/profile/elderly/${elderly.elderlyId}'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      print('BackendDataService: PUT /profile/elderly/${elderly.elderlyId} status=${response.statusCode}');
      print('BackendDataService: body=${response.body}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('BackendDataService: updateElderlyProfile error=$e');
    }
    return false;
  }

  static Future<void> requestMatch(
    ElderlyData elderly, {
    int? elderlyId,
    int? questionScore,
  }) async {
    final headers = await _headers(authorized: true);
    final body = {
      'elderly_id': elderlyId ?? elderly.elderlyId ?? 0,
      'care_level': elderly.needLevel,
      'service_needs': elderly.selectedNeeds,
      if (questionScore != null) 'score': questionScore,
    };

    for (final path in const ['/match', '/matching/request']) {
      try {
        final response = await http
            .post(_uri(path), headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 10));
        print('BackendDataService: POST $path status=${response.statusCode}');
        print('BackendDataService: body=${response.body}');
        if (response.statusCode >= 200 && response.statusCode < 300) return;
      } catch (e) {
        print('BackendDataService: requestMatch error on $path -> $e');
      }
    }
  }

  static Future<void> submitQuestionScore({
    required String target,
    required int score,
    int? relatedId,
    List<String>? answers,
  }) async {
    final headers = await _headers(authorized: true);
    final userId = await AppSession.getUserId();

    final body = {
      'target': target,
      'score': score,
      if (userId != null) 'user_id': userId,
      if (relatedId != null) '${target}_id': relatedId,
      if (answers != null) 'answers': answers,
    };

    for (final path in const [
      '/question/result',
      '/question/score',
      '/score',
      '/profile/question-score',
    ]) {
      try {
        final response = await http
            .post(_uri(path), headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 10));
        print('BackendDataService: POST $path status=${response.statusCode}');
        print('BackendDataService: body=${response.body}');
        if (response.statusCode >= 200 && response.statusCode < 300) return;
      } catch (e) {
        print('BackendDataService: submitQuestionScore error on $path -> $e');
      }
    }
  }

  static String toThaiDate(DateTime date) {
    final thaiMonths = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    
    final day = date.day;
    final month = thaiMonths[date.month - 1];
    final year = date.year + 543; // แปลงเป็น พ.ศ.
    
    return '$day $month $year';
  }

  static String _normalizeDateString(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return '';

    final iso = DateTime.tryParse(raw);
    if (iso != null) {
      final y = iso.year.toString().padLeft(4, '0');
      final m = iso.month.toString().padLeft(2, '0');
      final d = iso.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }

    final thaiMonths = <String, int>{
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

    final parts = raw.split(RegExp(r'\s+'));
    if (parts.length >= 3) {
      final day = int.tryParse(parts[0]);
      final month = thaiMonths[parts[1]];
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        final y = year.toString().padLeft(4, '0');
        final m = month.toString().padLeft(2, '0');
        final d = day.toString().padLeft(2, '0');
        return '$y-$m-$d';
      }
    }

    return raw;
  }

  static Future<http.Response?> _tryWrite(
    List<String> paths,
    Map<String, dynamic> body, {
    List<String> methods = const ['PUT', 'PATCH', 'POST'],
    bool authorized = true,
  }) async {
    final headers = await _headers(authorized: authorized);

    for (final path in paths) {
      for (final method in methods) {
        try {
          late http.Response response;
          final uri = _uri(path);
          final encoded = jsonEncode(body);

          switch (method) {
            case 'PUT':
              response = await http
                  .put(uri, headers: headers, body: encoded)
                  .timeout(const Duration(seconds: 10));
              break;
            case 'PATCH':
              response = await http
                  .patch(uri, headers: headers, body: encoded)
                  .timeout(const Duration(seconds: 10));
              break;
            default:
              response = await http
                  .post(uri, headers: headers, body: encoded)
                  .timeout(const Duration(seconds: 10));
          }

          print(
              'BackendDataService: $method $path status=${response.statusCode}');
          print('BackendDataService: body=${response.body}');

          if (response.statusCode >= 200 && response.statusCode < 300) {
            return response;
          }
        } catch (e) {
          print('BackendDataService: $method $path error=$e');
        }
      }
    }

    return null;
  }

  // ตาม API v2.1: PUT /profile/client
  static Future<bool> updateUserProfile(UserData user) async {
    final body = {
      'fullname': user.fullName,
      'tel': user.phone,
    };

    final headers = await _headers(authorized: true);
    try {
      final response = await http
          .put(
            _uri('/profile/client'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      print('BackendDataService: PUT /profile/client status=${response.statusCode}');
      print('BackendDataService: body=${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await AppSession.updateBasicProfile(
          userName: user.fullName,
          phone: user.phone,
        );
        return true;
      }
    } catch (e) {
      print('BackendDataService: updateUserProfile error=$e');
    }

    return false;
  }

  // ตาม API v2.1: PUT /profile/caregiver/{caregiver_id}
  static Future<bool> updateCaregiverProfile(caregiverData profile) async {
    final caregiverId = await AppSession.getCaregiverId();
    
    if (caregiverId == null || caregiverId.isEmpty) {
      print('BackendDataService: updateCaregiverProfile -> caregiverId is null/empty');
      return false;
    }

    final birthdayThai = profile.birthDate == null ? '' : toThaiDate(profile.birthDate!);
    print('BackendDataService: Converting birthday ${profile.birthDate} -> "$birthdayThai"');

    final body = {
      'fullname': profile.fullName,
      'alias': profile.nickName,
      'tel': profile.phone,
      'gender': profile.gender,
      'weight': profile.weight,
      'height': profile.height,
      'address': profile.address,
      'latitude': profile.latitude,
      'longitude': profile.longitude,
      'province': profile.province,
      'birthday': birthdayThai,
    };

    print('BackendDataService: PUT body=$body');

    final headers = await _headers(authorized: true);
    try {
      final response = await http
          .put(
            _uri('/profile/caregiver/$caregiverId'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      print('BackendDataService: PUT /profile/caregiver/$caregiverId status=${response.statusCode}');
      print('BackendDataService: body=${response.body}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('BackendDataService: updateCaregiverProfile error=$e');
      return false;
    }
  }

  static Future<bool> updateCaregiverScore({
    required int score,
    required DateTime scoreDate,
  }) async {
    final caregiverId = await AppSession.getCaregiverId();
    
    if (caregiverId == null || caregiverId.isEmpty) {
      print('BackendDataService: updateCaregiverScore -> caregiverId is null/empty');
      return false;
    }

    // ใช้ PUT /profile/caregiver/{caregiver_id} เหมือนกัน แต่ส่งแค่ score
    final body = {
      'score': score,
    };

    final headers = await _headers(authorized: true);
    try {
      final response = await http
          .put(
            _uri('/profile/caregiver/$caregiverId'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      print('BackendDataService: PUT /profile/caregiver/$caregiverId (score) status=${response.statusCode}');
      print('BackendDataService: body=${response.body}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('BackendDataService: updateCaregiverScore error=$e');
      return false;
    }
  }
}
