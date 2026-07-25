import 'package:hive/hive.dart';

import '../../services/hive_service.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  Box get _box => Hive.box(HiveService.budgetBox);

  List<BudgetModel> getAll() {
    return _box.values
        .map((e) => BudgetModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> add(BudgetModel budget) async {
    await _box.put(budget.id, budget.toMap());
  }

  Future<void> update(BudgetModel budget) async {
    await _box.put(budget.id, budget.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
