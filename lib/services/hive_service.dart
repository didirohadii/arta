import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String profileBox = "profile";
  static const String walletBox = "wallet";
  static const String transactionBox = "transaction";
  static const String savingTargetBox = "saving_target";
  static const String assetHistoryBox = "asset_history_box";
  static const String budgetBox = "budget";
  static const String categoryBox = "category";
  static const String authBox = "auth";

  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(profileBox);
    await Hive.openBox(walletBox);
    await Hive.openBox(transactionBox);
    await Hive.openBox(savingTargetBox);
    await Hive.openBox(assetHistoryBox);
    await Hive.openBox(budgetBox);
    await Hive.openBox(categoryBox);
    await Hive.openBox(authBox);
  }
}
