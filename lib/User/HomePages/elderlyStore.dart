import 'package:carex/User/HomePages/elderlyData.dart';
import 'package:carex/services/backend_data_service.dart';

class ElderlyStore {
  static final List<ElderlyData> elderlyList = [];

  static Future<void> syncFromBackend() async {
    final list = await BackendDataService.fetchElderlies();
    elderlyList
      ..clear()
      ..addAll(list);
  }

  static Future<void> saveToCache() async {
    // intentionally no-op: database is the source of truth
  }

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
