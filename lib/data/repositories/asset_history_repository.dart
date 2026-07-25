import 'package:hive/hive.dart';

import 'package:arta/services/hive_service.dart';
import '../models/asset_history_model.dart';

class AssetHistoryRepository {
  Box get _box => Hive.box(HiveService.assetHistoryBox);

  List<AssetHistoryModel> getAll() {
    final raw = _box.get("history");

    if (raw == null) return [];

    return List.from(raw)
        .map((e) => AssetHistoryModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> save(List<AssetHistoryModel> history) async {
    await _box.put("history", history.map((e) => e.toMap()).toList());
  }

  Future<void> clear() async {
    await _box.delete("history");
  }
}
