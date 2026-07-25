import '../data/models/report_model.dart';
import 'financial_service.dart';

class ReportService {
  static ReportModel generate() {
    final asset = FinancialService.getTotalAsset();
    final income = FinancialService.getTotalIncome();
    final expense = FinancialService.getTotalExpense();

    return ReportModel(
      asset: asset,
      income: income,
      expense: expense,
      balance: income - expense,
      wallets: FinancialService.getWallets(),
      transactions: FinancialService.getTransactions(),
      savingTargets: FinancialService.getSavingTargets(),
    );
  }
}
