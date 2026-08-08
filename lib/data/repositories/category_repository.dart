import 'package:hive/hive.dart';

import '../../services/hive_service.dart';
import '../models/category_model.dart';

class CategoryRepository {
  Box get _box => Hive.box(HiveService.categoryBox);

  List<CategoryModel> getAll() {
    return _box.values
        .map((e) => CategoryModel.fromMap(Map<dynamic, dynamic>.from(e)))
        .toList();
  }

  Future<void> add(CategoryModel category) async {
    await _box.put(category.id, category.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
