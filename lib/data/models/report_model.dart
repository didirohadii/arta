import 'wallet_model.dart';
import 'transaction_model.dart';
import 'saving_target_model.dart';

class ReportModel {
  final double asset;
  final double income;
  final double expense;
  final double balance;

  final List<WalletModel> wallets;
  final List<TransactionModel> transactions;
  final List<SavingTargetModel> savingTargets;

  const ReportModel({
    required this.asset,
    required this.income,
    required this.expense,
    required this.balance,
    required this.wallets,
    required this.transactions,
    required this.savingTargets,
  });
}
