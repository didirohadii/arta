import 'package:hive_flutter/hive_flutter.dart';

import '../../services/hive_service.dart';
import '../models/transaction_model.dart';
import 'dummy_repository.dart';

class TransactionRepository {
  List<TransactionModel> getAll() {
    final box = Hive.box(HiveService.transactionBox);

    if (box.isEmpty) {
      return DummyRepository.transactions;
    }

    return box.values.map((e) => TransactionModel.decode(e as String)).toList();
  }

  void add(TransactionModel transaction) {
    final box = Hive.box(HiveService.transactionBox);

    box.put(transaction.id, transaction.encode());
  }

  void update(TransactionModel transaction) {
    final box = Hive.box(HiveService.transactionBox);

    box.put(transaction.id, transaction.encode());
  }

  void delete(String id) {
    final box = Hive.box(HiveService.transactionBox);

    box.delete(id);
  }
}
