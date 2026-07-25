import 'package:flutter/material.dart';

import '../data/models/budget_model.dart';
import '../data/models/insight_model.dart';
import '../data/models/saving_target_model.dart';
import 'financial_service.dart';

class InsightService {
  static List<InsightModel> getInsights() {
    final List<InsightModel> insights = [];

    // ==========================================
    // 1. Cashflow Insight
    // ==========================================
    final income = FinancialService.getTotalIncome();
    final expense = FinancialService.getTotalExpense();

    if (income == 0 && expense == 0) {
      insights.add(
        const InsightModel(
          priority: 10,
          icon: Icons.info_outline,
          color: Colors.grey,
          title: "Belum ada transaksi",
          description:
              "Mulai catat pemasukan dan pengeluaran agar kami dapat memberikan insight.",
        ),
      );
    } else if (income > expense) {
      insights.add(
        const InsightModel(
          priority: 50,
          icon: Icons.trending_up,
          color: Colors.green,
          title: "Cashflow Positif",
          description:
              "Selamat! Penghasilan bulan ini lebih besar daripada pengeluaran.",
        ),
      );
    } else if (expense > income) {
      insights.add(
        const InsightModel(
          priority: 80,
          icon: Icons.warning_amber_rounded,
          color: Colors.red,
          title: "Cashflow Negatif",
          description: "Pengeluaran bulan ini lebih besar daripada pemasukan.",
        ),
      );
    } else {
      insights.add(
        const InsightModel(
          priority: 50,
          icon: Icons.balance,
          color: Colors.blue,
          title: "Cashflow Seimbang",
          description:
              "Pemasukan dan pengeluaran bulan ini memiliki nilai yang sama.",
        ),
      );
    }

    // ==========================================
    // 2. Budget Insight
    // ==========================================
    for (final BudgetModel budget in FinancialService.getBudgets()) {
      final progress = FinancialService.getBudgetProgress(budget);

      if (progress >= 1) {
        insights.add(
          InsightModel(
            priority: 100,
            icon: Icons.error_outline,
            color: Colors.red,
            title: "Budget Terlampaui",
            description:
                "Budget ${budget.category} telah melebihi batas yang ditentukan.",
          ),
        );
      } else if (progress >= 0.8) {
        insights.add(
          InsightModel(
            priority: 90,
            icon: Icons.warning_amber,
            color: Colors.orange,
            title: "Budget Hampir Habis",
            description:
                "Budget ${budget.category} sudah terpakai ${(progress * 100).toStringAsFixed(0)}%.",
          ),
        );
      }
    }

    // ==========================================
    // 3. Asset Insight
    // ==========================================
    if (FinancialService.hasAssetGrowthHistory()) {
      final growth = FinancialService.getAssetGrowthPercentage();

      insights.add(
        InsightModel(
          priority: 60,
          icon: growth >= 0 ? Icons.trending_up : Icons.trending_down,
          color: growth >= 0 ? Colors.green : Colors.red,
          title: "Perkembangan Asset",
          description: growth >= 0
              ? "Total asset meningkat ${growth.toStringAsFixed(1)}% dibanding pencatatan sebelumnya."
              : "Total asset menurun ${growth.abs().toStringAsFixed(1)}% dibanding pencatatan sebelumnya.",
        ),
      );
    }

    // ==========================================
    // 4. Saving Target Insight
    // ==========================================
    for (final SavingTargetModel target
        in FinancialService.getSavingTargets()) {
      final progress = FinancialService.getSavingPercent(
        current: FinancialService.getSavingCurrent(target),
        target: target.targetAmount,
      );

      if (progress >= 0.8 && progress < 1) {
        insights.add(
          InsightModel(
            priority: 70,
            icon: Icons.flag,
            color: Colors.green,
            title: "Target Hampir Tercapai",
            description:
                "${target.title} sudah mencapai ${(progress * 100).toStringAsFixed(0)}%.",
          ),
        );
      }
    }

    // ==========================================
    // STEP 3 — Sort otomatis berdasarkan Prioritas
    // ==========================================
    insights.sort((a, b) => b.priority.compareTo(a.priority));

    return insights;
  }
}
