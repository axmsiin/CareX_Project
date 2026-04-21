import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/services/backend_data_service.dart';

class ElderlyStore {
  static final List<ElderlyData> elderlyList = [];
  
  // จดจำ ID ผู้สูงอายุที่กดยืนยันเลือกผู้ดูแลไปแล้วในเซสชันนี้
  // เพื่อป้องกันการนำกลับมาแสดงในส่วน Matching ซ้ำ
  static final List<String> confirmedIds = [];

  static Future<void> syncFromBackend() async {
    final data = await BackendDataService.fetchElderlies();
    elderlyList
      ..clear()
      ..addAll(data);
  }

  static void markAsConfirmed(String id) {
    if (id.isNotEmpty && !confirmedIds.contains(id)) {
      confirmedIds.add(id);
      print('DEBUG: [ElderlyStore] ID $id marked as CONFIRMED. Total: ${confirmedIds.length}');
    }
  }

  static bool isConfirmed(String id) {
    final confirmed = confirmedIds.contains(id);
    if (confirmed) {
      print('DEBUG: [ElderlyStore] ID $id is already confirmed locally.');
    }
    return confirmed;
  }

  static Future<void> saveToCache() async {}

  static Future<void> upsert(ElderlyData elderly) async {
    final index = elderlyList.indexWhere((e) =>
        (elderly.elderlyId != null && e.elderlyId == elderly.elderlyId) ||
        (e.fullName == elderly.fullName && e.phone == elderly.phone && e.birthDate == elderly.birthDate));
    if (index >= 0) {
      elderlyList[index] = elderly;
    } else {
      elderlyList.add(elderly);
    }
  }

  static Future<void> replaceAt(int index, ElderlyData elderly) async {
    if (index < 0 || index >= elderlyList.length) return;
    elderlyList[index] = elderly;
  }

  static Future<void> clear() async {
    elderlyList.clear();
  }
}
