import '../models/profile_model.dart';
import '../models/saving_target_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../models/asset_history_model.dart';

class DummyRepository {
  /// WALLET
  static List<WalletModel> wallets = [];

  /// SAVING TARGET
  static List<SavingTargetModel> savingTargets = [];

  /// TRANSACTION
  static List<TransactionModel> transactions = [];

  /// TRX HISTORY
  static final List<AssetHistoryModel> assetHistory = [];

  /// PROFILE
  static ProfileModel profile = ProfileModel(
    name: "",
    financialGoal: "",
    createdAt: DateTime.now(),
    avatar: "avatar_1.png",
  );
}
