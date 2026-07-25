import 'package:hive_flutter/hive_flutter.dart';

import '../../services/hive_service.dart';
import '../models/saving_target_model.dart';
import 'dummy_repository.dart';

class SavingTargetRepository {
  List<SavingTargetModel> getAll() {
    final box = Hive.box(HiveService.savingTargetBox);

    if (box.isEmpty) {
      return DummyRepository.savingTargets;
    }

    return box.values
        .map((e) => SavingTargetModel.decode(e as String))
        .toList();
  }

  void add(SavingTargetModel target) {
    final box = Hive.box(HiveService.savingTargetBox);

    box.put(target.id, target.encode());
  }

  void update(SavingTargetModel target) {
    final box = Hive.box(HiveService.savingTargetBox);

    box.put(target.id, target.encode());
  }

  void delete(String id) {
    final box = Hive.box(HiveService.savingTargetBox);

    box.delete(id);
  }
}
