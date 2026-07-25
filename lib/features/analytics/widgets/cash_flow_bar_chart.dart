import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../services/financial_service.dart';

class CashFlowBarChart extends StatelessWidget {
  const CashFlowBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = FinancialService.getMonthlyCashFlow();

    if (data.isEmpty) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Cash Flow Bulanan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Center(
              child: Text(
                "Belum ada transaksi",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    final maxValue = data.fold<double>(0, (previous, e) {
      final biggest = e.income > e.expense ? e.income : e.expense;
      return biggest > previous ? biggest : previous;
    });

    final safeMax = maxValue == 0 ? 1000 : maxValue;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cash Flow Bulanan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                maxY: safeMax * 1.2,

                // Tambahkan fitur interaksi & tooltip saat bar ditekan
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = rodIndex == 0 ? "Income" : "Expense";
                      final value = rod.toY.toStringAsFixed(0);

                      return BarTooltipItem(
                        "$label\nRp$value",
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),

                borderData: FlBorderData(show: false),

                gridData: FlGridData(show: true),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),

                  // Tampilkan teks nominal singkat di sisi kiri chart
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: safeMax / 4,
                      getTitlesWidget: (value, meta) {
                        String text;

                        if (value >= 1000000) {
                          text = "${(value / 1000000).toStringAsFixed(0)} Jt";
                        } else if (value >= 1000) {
                          text = "${(value / 1000).toStringAsFixed(0)} Rb";
                        } else {
                          text = value.toInt().toString();
                        }

                        return Text(
                          text,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= data.length) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data[value.toInt()].label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                barGroups: List.generate(data.length, (index) {
                  final item = data[index];

                  return BarChartGroupData(
                    x: index,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: item.income,
                        width: 7,
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: item.expense,
                        width: 7,
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.circle, color: Colors.green, size: 10),
              SizedBox(width: 6),
              Text("Income"),

              SizedBox(width: 20),

              Icon(Icons.circle, color: Colors.red, size: 10),
              SizedBox(width: 6),
              Text("Expense"),
            ],
          ),
        ],
      ),
    );
  }
}
