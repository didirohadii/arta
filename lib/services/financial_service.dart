import 'package:flutter/material.dart';

import '../data/models/asset_history_model.dart';
import '../data/models/budget_model.dart';
import '../data/models/category_model.dart';
import '../data/models/chart_data_model.dart';
import '../data/models/net_worth_data_model.dart';
import '../data/models/profile_model.dart';
import '../data/models/saving_target_model.dart';
import '../data/models/transaction_model.dart';
import '../data/models/wallet_model.dart';

// Import Repository
import '../data/repositories/asset_history_repository.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/saving_target_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/repositories/wallet_repository.dart';

import 'asset_history_service.dart';

class FinancialService {
  static final ValueNotifier<int> refreshNotifier = ValueNotifier(0);

  // Inisialisasi Instance Repository
  static final WalletRepository _walletRepository = WalletRepository();
  static final TransactionRepository _transactionRepository =
      TransactionRepository();
  static final SavingTargetRepository _savingTargetRepository =
      SavingTargetRepository();
  static final ProfileRepository _profileRepository = ProfileRepository();
  static final BudgetRepository _budgetRepository = BudgetRepository();
  static final AssetHistoryRepository _assetHistoryRepository =
      AssetHistoryRepository();
  static final CategoryRepository _categoryRepository = CategoryRepository();

  // Data history disimpan di memory runtime agar aman diakses oleh UI kapan saja
  static List<AssetHistoryModel> assetHistory = [];

  /// ============================
  /// INITIALIZATION
  /// ============================

  static Future<void> init() async {
    assetHistory = _assetHistoryRepository.getAll();

    if (assetHistory.isEmpty) {
      assetHistory.add(
        AssetHistoryModel(date: DateTime.now(), amount: getTotalAsset()),
      );
      await _assetHistoryRepository.save(assetHistory);
    }
  }

  /// ============================
  /// CATEGORIES (CUSTOM)
  /// ============================

  static List<CategoryModel> getCustomCategories(String type) {
    return _categoryRepository
        .getAll()
        .where((category) => category.type == type)
        .toList();
  }

  static Future<void> addCustomCategory(CategoryModel category) async {
    await _categoryRepository.add(category);
    await notifyDataChanged();
  }

  /// Fungsi khusus simpan tanpa pemicu notify global agar tidak crash saat dialog tutup
  static Future<void> addCustomCategorySilent(CategoryModel category) async {
    await _categoryRepository.add(category);
  }

  static Future<void> deleteCustomCategory(String id) async {
    await _categoryRepository.delete(id);
    await notifyDataChanged();
  }

  /// ============================
  /// TOTAL ASSET
  /// ============================

  static double getTotalAsset() {
    double total = 0;

    for (final wallet in getWallets()) {
      if (wallet.isGold) continue;
      total += getWalletBalance(wallet.id);
    }

    return total;
  }

  /// ============================
  /// SALDO WALLET
  /// ============================

  static double getWalletBalance(String walletId) {
    final WalletModel wallet = _walletRepository.getAll().firstWhere(
      (e) => e.id == walletId,
    );

    if (wallet.isGold) {
      return wallet.gram ?? 0;
    }

    double balance = wallet.initialBalance;

    for (final transaction in _transactionRepository.getAll()) {
      switch (transaction.type) {
        case TransactionType.income:
          if (transaction.destinationWalletId == walletId) {
            balance += transaction.amount;
          }
          break;

        case TransactionType.expense:
          if (transaction.sourceWalletId == walletId) {
            balance -= transaction.amount;
          }
          break;

        case TransactionType.transfer:
          if (transaction.sourceWalletId == walletId) {
            balance -= transaction.amount;
          }

          if (transaction.destinationWalletId == walletId) {
            balance += transaction.amount;
          }
          break;
      }
    }

    return balance;
  }

  /// ============================
  /// TOTAL INCOME & EXPENSE
  /// ============================

  static double getTotalIncome() {
    return _transactionRepository
        .getAll()
        .where((e) => e.type == TransactionType.income)
        .fold(0, (sum, item) => sum + item.amount);
  }

  static double getTotalExpense() {
    return _transactionRepository
        .getAll()
        .where((e) => e.type == TransactionType.expense)
        .fold(0, (sum, item) => sum + item.amount);
  }

  /// ============================
  /// MANAJEMEN TRANSAKSI
  /// ============================

  static Future<void> addTransaction(TransactionModel transaction) async {
    _transactionRepository.add(transaction);
    await notifyDataChanged();
  }

  static Future<void> deleteTransaction(String id) async {
    _transactionRepository.delete(id);
    await notifyDataChanged();
  }

  static Future<void> updateTransaction(TransactionModel transaction) async {
    _transactionRepository.update(transaction);
    await notifyDataChanged();
  }

  static List<TransactionModel> getTransactions() {
    final list = [..._transactionRepository.getAll()];
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  static String getWalletName(String? walletId) {
    if (walletId == null) return "-";
    return _walletRepository.getAll().firstWhere((e) => e.id == walletId).name;
  }

  static String getTransactionWallet(TransactionModel trx) {
    switch (trx.type) {
      case TransactionType.income:
        return "→ ${getWalletName(trx.destinationWalletId)}";

      case TransactionType.expense:
        return getWalletName(trx.sourceWalletId);

      case TransactionType.transfer:
        return "${getWalletName(trx.sourceWalletId)} → ${getWalletName(trx.destinationWalletId)}";
    }
  }

  static double getTotalTransfer() {
    return _transactionRepository
        .getAll()
        .where((e) => e.type == TransactionType.transfer)
        .fold(0, (sum, item) => sum + item.amount);
  }

  /// ============================
  /// SAVING TARGET
  /// ============================

  static double getSavingCurrent(SavingTargetModel target) {
    if (target.unit == SavingTargetUnit.gold) {
      double gram = 0;
      for (final id in target.walletIds) {
        gram += getWalletGram(id);
      }
      return gram;
    }

    double total = 0;
    for (final id in target.walletIds) {
      total += getWalletBalance(id);
    }

    return total;
  }

  static double getWalletGram(String walletId) {
    final wallet = _walletRepository.getAll().firstWhere(
      (e) => e.id == walletId,
    );
    return wallet.gram ?? 0;
  }

  static double getSavingPercent({
    required double current,
    required double target,
  }) {
    if (target <= 0) return 0;
    final value = current / target;
    if (value > 1) return 1;
    return value;
  }

  static double getSavingRemaining({
    required double current,
    required double target,
  }) {
    final remain = target - current;
    if (remain < 0) return 0;
    return remain;
  }

  static List<SavingTargetModel> getSavingTargets() {
    return _savingTargetRepository.getAll();
  }

  static Future<void> addSavingTarget(SavingTargetModel target) async {
    _savingTargetRepository.add(target);
    await notifyDataChanged();
  }

  static Future<void> updateSavingTarget(SavingTargetModel target) async {
    _savingTargetRepository.update(target);
    await notifyDataChanged();
  }

  static Future<void> deleteSavingTarget(String id) async {
    _savingTargetRepository.delete(id);
    await notifyDataChanged();
  }

  /// ============================
  /// WALLET VALIDATION & DEPENDENCIES
  /// ============================

  static bool isWalletUsed(String walletId) {
    final usedInTransaction = _transactionRepository.getAll().any(
      (trx) =>
          trx.sourceWalletId == walletId || trx.destinationWalletId == walletId,
    );

    final usedInSavingTarget = _savingTargetRepository.getAll().any(
      (target) => target.walletIds.contains(walletId),
    );

    return usedInTransaction || usedInSavingTarget;
  }

  static List<String> getWalletDependencies(String walletId) {
    final List<String> dependencies = [];

    final transactionCount = _transactionRepository
        .getAll()
        .where(
          (trx) =>
              trx.sourceWalletId == walletId ||
              trx.destinationWalletId == walletId,
        )
        .length;

    if (transactionCount > 0) {
      dependencies.add("$transactionCount transaksi");
    }

    for (final target in _savingTargetRepository.getAll()) {
      if (target.walletIds.contains(walletId)) {
        dependencies.add("Target ${target.title}");
      }
    }

    return dependencies;
  }

  /// ============================
  /// MANAJEMEN WALLET
  /// ============================

  static List<WalletModel> getWallets() {
    return _walletRepository.getAll();
  }

  static Future<void> addWallet(WalletModel wallet) async {
    _walletRepository.add(wallet);
    await notifyDataChanged();
  }

  static Future<void> updateWallet(WalletModel wallet) async {
    _walletRepository.update(wallet);
    await notifyDataChanged();
  }

  static Future<void> deleteWallet(String id) async {
    _walletRepository.delete(id);
    await notifyDataChanged();
  }

  static WalletModel getWalletById(String id) {
    return _walletRepository.getAll().firstWhere((e) => e.id == id);
  }

  /// ============================
  /// PROFILE
  /// ============================

  static ProfileModel getProfile() {
    return _profileRepository.get();
  }

  static Future<void> updateProfile(ProfileModel profile) async {
    _profileRepository.update(profile);
    await notifyDataChanged();
  }

  /// ============================
  /// CHARTS & UTILS
  /// ============================

  static List<ChartDataModel> getMonthlyCashFlow() {
    final transactions = _transactionRepository.getAll();

    if (transactions.isEmpty) {
      return [];
    }

    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Ags",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];

    final Map<int, double> incomeMap = {};
    final Map<int, double> expenseMap = {};

    for (final trx in transactions) {
      switch (trx.type) {
        case TransactionType.income:
          incomeMap[trx.date.month] =
              (incomeMap[trx.date.month] ?? 0) + trx.amount;
          break;

        case TransactionType.expense:
          expenseMap[trx.date.month] =
              (expenseMap[trx.date.month] ?? 0) + trx.amount;
          break;

        case TransactionType.transfer:
          break;
      }
    }

    final usedMonths = {...incomeMap.keys, ...expenseMap.keys}.toList()..sort();

    return usedMonths.map((month) {
      return ChartDataModel(
        label: months[month - 1],
        income: incomeMap[month] ?? 0,
        expense: expenseMap[month] ?? 0,
      );
    }).toList();
  }

  static List<NetWorthDataModel> getNetWorthHistory() {
    if (assetHistory.isEmpty) {
      return [];
    }

    final recentHistory = assetHistory.length > 5
        ? assetHistory.sublist(assetHistory.length - 5)
        : assetHistory;

    const labels = ["-30H", "-21H", "-14H", "-7H", "Now"];

    return List.generate(recentHistory.length, (i) {
      return NetWorthDataModel(
        label: labels[labels.length - recentHistory.length + i],
        amount: recentHistory[i].amount,
      );
    });
  }

  static double getAssetGrowthPercentage() {
    if (assetHistory.length < 2) {
      return 0;
    }

    final current = assetHistory.last.amount;
    final previous = assetHistory[assetHistory.length - 2].amount;

    if (previous == 0) {
      return 0;
    }

    return ((current - previous) / previous) * 100;
  }

  static bool hasAssetGrowthHistory() {
    return assetHistory.length >= 2;
  }

  static String formatGroupDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final trxDate = DateTime(date.year, date.month, date.day);
    final diff = today.difference(trxDate).inDays;

    if (diff == 0) return "Hari Ini";
    if (diff == 1) return "Kemarin";

    const bulan = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];

    return "${date.day} ${bulan[date.month - 1]} ${date.year}";
  }

  /// ============================
  /// BUDGET
  /// ============================

  static List<BudgetModel> getBudgets() {
    return _budgetRepository.getAll();
  }

  static Future<void> addBudget(BudgetModel budget) async {
    await _budgetRepository.add(budget);
    await notifyDataChanged();
  }

  static Future<void> updateBudget(BudgetModel budget) async {
    await _budgetRepository.update(budget);
    await notifyDataChanged();
  }

  static Future<void> deleteBudget(String id) async {
    await _budgetRepository.delete(id);
    await notifyDataChanged();
  }

  static bool budgetExists({
    required String category,
    required DateTime startDate,
    required DateTime endDate,
    String? excludeId,
  }) {
    return getBudgets().any(
      (budget) =>
          budget.category == category &&
          budget.startDate == startDate &&
          budget.endDate == endDate &&
          budget.id != excludeId,
    );
  }

  static double getExpenseByCategory({
    required String category,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    double total = 0;

    final targetCategory = category.trim().toLowerCase();

    final start = DateTime(startDate.year, startDate.month, startDate.day);

    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
      999,
    );

    for (final trx in _transactionRepository.getAll()) {
      if (trx.type != TransactionType.expense) continue;

      if (trx.category.trim().toLowerCase() != targetCategory) {
        continue;
      }

      if (trx.date.isBefore(start)) continue;
      if (trx.date.isAfter(end)) continue;

      total += trx.amount;
    }

    return total;
  }

  static double getBudgetUsed(BudgetModel budget) {
    return getExpenseByCategory(
      category: budget.category,
      startDate: budget.startDate,
      endDate: budget.endDate,
    );
  }

  static double getBudgetSpent(BudgetModel budget) {
    return getBudgetUsed(budget);
  }

  static double getBudgetProgress(BudgetModel budget) {
    final spent = getBudgetUsed(budget);

    if (budget.amount == 0) return 0;

    return spent / budget.amount;
  }

  static double getBudgetRemaining(BudgetModel budget) {
    final remain = budget.amount - getBudgetUsed(budget);

    return remain < 0 ? 0 : remain;
  }

  /// ============================
  /// INTERNAL UTILS & HISTORIES
  /// ============================

  static Future<void> notifyDataChanged() async {
    await _updateNetWorthHistory();
    await AssetHistoryService.recordCurrentAsset();
    refreshNotifier.value++;
  }

  static Future<void> _updateNetWorthHistory() async {
    final asset = getTotalAsset();

    if (assetHistory.isNotEmpty && assetHistory.last.amount == asset) {
      return;
    }

    assetHistory.add(AssetHistoryModel(date: DateTime.now(), amount: asset));

    if (assetHistory.length > 365) {
      assetHistory.removeAt(0);
    }

    await _assetHistoryRepository.save(assetHistory);
  }
}
