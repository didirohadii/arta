import 'package:hive_flutter/hive_flutter.dart';

import '../../services/hive_service.dart';
import '../models/wallet_model.dart';
import 'dummy_repository.dart';

class WalletRepository {
  List<WalletModel> getAll() {
    final box = Hive.box(HiveService.walletBox);

    if (box.isEmpty) {
      return DummyRepository.wallets;
    }

    return box.values.map((e) => WalletModel.decode(e as String)).toList();
  }

  void add(WalletModel wallet) {
    final box = Hive.box(HiveService.walletBox);

    box.put(wallet.id, wallet.encode());
  }

  void update(WalletModel wallet) {
    final box = Hive.box(HiveService.walletBox);

    box.put(wallet.id, wallet.encode());
  }

  void delete(String id) {
    final box = Hive.box(HiveService.walletBox);

    box.delete(id);
  }
}
