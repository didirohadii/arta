import 'package:flutter/material.dart';

import '../../services/financial_service.dart';
import 'widgets/budget_card.dart';
import 'widgets/cash_flow_bar_chart.dart';
import 'widgets/category_expense_card.dart';
import 'widgets/financial_summary_card.dart';
import 'widgets/net_worth_chart.dart';
import 'widgets/saving_progress_card.dart';
import 'widgets/wallet_distribution_card.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FinancialService.refreshNotifier,
      builder: (context, _, _) {
        return Scaffold(
          appBar: AppBar(title: const Text("Analytics")),
          body: RefreshIndicator(
            onRefresh: () async {
              await FinancialService.notifyDataChanged();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                FinancialSummaryCard(),
                SizedBox(height: 20),
                BudgetCard(),
                SizedBox(height: 20),
                NetWorthChart(),
                SizedBox(height: 20),
                CashFlowBarChart(),
                SizedBox(height: 20),
                CategoryExpenseCard(),
                SizedBox(height: 20),
                WalletDistributionCard(),
                SizedBox(height: 20),
                SavingProgressCard(),
              ],
            ),
          ),
        );
      },
    );
  }
}
