import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/currency_text.dart';
import '../../../services/financial_service.dart';

class IncomeExpenseCard extends StatelessWidget {
  const IncomeExpenseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FinancialService.refreshNotifier,
      builder: (context, _, _) {
        final income = FinancialService.getTotalIncome();
        final expense = FinancialService.getTotalExpense();

        final balance = income - expense;

        final maxValue = income > expense ? income : expense;

        double incomePercent = 0;
        double expensePercent = 0;

        if (maxValue > 0) {
          incomePercent = income / maxValue;
          expensePercent = expense / maxValue;
        }

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Income vs Expense",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              const Text("Income"),
              const SizedBox(height: 6),

              CurrencyText(
                amount: income,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: incomePercent,
                minHeight: 8,
                color: Colors.green,
              ),

              const SizedBox(height: 24),

              const Text("Expense"),
              const SizedBox(height: 6),

              CurrencyText(
                amount: expense,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: expensePercent,
                minHeight: 8,
                color: Colors.red,
              ),

              const Divider(height: 36),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Selisih",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  CurrencyText(
                    amount: balance,
                    color: balance >= 0 ? Colors.blue : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
