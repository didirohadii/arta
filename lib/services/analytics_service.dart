import '../data/models/analytics_range.dart';
import '../data/models/asset_history_model.dart';
import '../data/models/category_expense_model.dart';
import '../data/models/saving_target_model.dart';
import '../data/models/transaction_model.dart';
import '../data/models/wallet_model.dart';
import 'financial_service.dart';

class AnalyticsService {
  /// ============================
  /// CASH FLOW
  /// ============================

  static double getIncome() {
    return FinancialService.getTotalIncome();
  }

  static double getExpense() {
    return FinancialService.getTotalExpense();
  }

  static double getBalance() {
    return getIncome() - getExpense();
  }

  /// ============================
  /// TOTAL ASSET
  /// ============================

  static double getTotalAsset() {
    return FinancialService.getTotalAsset();
  }

  /// ============================
  /// NET WORTH HISTORY (Grafik Berdasarkan Rentang Waktu)
  /// ============================

  static List<AssetHistoryModel> getNetWorthHistory(AnalyticsRange range) {
    final now = DateTime.now();
    Duration duration;

    switch (range) {
      case AnalyticsRange.week:
        duration = const Duration(days: 7);
        break;
      case AnalyticsRange.month:
        duration = const Duration(days: 30);
        break;
      case AnalyticsRange.threeMonths:
        duration = const Duration(days: 90);
        break;
      case AnalyticsRange.year:
        duration = const Duration(days: 365);
        break;
    }

    final start = now.subtract(duration);

    return FinancialService.assetHistory
        .where((e) => e.date.isAfter(start))
        .toList();
  }

  /// ============================
  /// WALLET DISTRIBUTION
  /// ============================

  static Map<WalletModel, double> getWalletDistribution() {
    final Map<WalletModel, double> result = {};
    final total = getTotalAsset();

    if (total == 0) return result;

    // Mengambil daftar wallet riil dari FinancialService
    final wallets = FinancialService.getWallets();

    for (final wallet in wallets) {
      final balance = FinancialService.getWalletBalance(wallet.id);

      // Menghitung persentase distribusi wallet terhadap total aset
      result[wallet] = balance / total;
    }

    return result;
  }

  /// ============================
  /// SAVING TARGET PROGRESS
  /// ============================

  static Map<SavingTargetModel, double> getSavingProgress() {
    final Map<SavingTargetModel, double> result = {};

    // Mengambil daftar target menabung riil dari FinancialService
    final targets = FinancialService.getSavingTargets();

    for (final target in targets) {
      final current = FinancialService.getSavingCurrent(target);

      final percent = FinancialService.getSavingPercent(
        current: current,
        target: target.targetAmount,
      );

      result[target] = percent;
    }

    return result;
  }

  /// ============================
  /// EXPENSE BY CATEGORY
  /// ============================

  static List<CategoryExpenseModel> getExpenseByCategory() {
    final Map<String, double> map = {};

    final transactions = FinancialService.getTransactions();

    for (final trx in transactions) {
      if (trx.type != TransactionType.expense) continue;

      map.update(
        trx.category,
        (value) => value + trx.amount,
        ifAbsent: () => trx.amount,
      );
    }

    final result = map.entries
        .map((e) => CategoryExpenseModel(category: e.key, amount: e.value))
        .toList();

    result.sort((a, b) => b.amount.compareTo(a.amount));

    return result;
  }
}
