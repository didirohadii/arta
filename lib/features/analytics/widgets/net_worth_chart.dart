import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../data/models/analytics_range.dart';
import '../../../services/analytics_service.dart';
import 'net_worth_painter.dart';

import '../../../services/financial_service.dart';

class NetWorthChart extends StatefulWidget {
  const NetWorthChart({super.key});

  @override
  State<NetWorthChart> createState() => _NetWorthChartState();
}

class _NetWorthChartState extends State<NetWorthChart> {
  AnalyticsRange selectedRange = AnalyticsRange.month;

  // Formatter untuk mempersingkat tampilan angka besar asset
  String formatAsset(double amount) {
    if (amount >= 1000000000) {
      return "${(amount / 1000000000).toStringAsFixed(1)}B";
    }

    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}M";
    }

    if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}K";
    }

    return amount.toStringAsFixed(0);
  }

  // Formatter tanggal yang lebih bagus (Hari/Bulan)
  String formatDate(DateTime date) {
    return "${date.day}/${date.month}";
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data history dari AnalyticsService berdasarkan range yang dipilih
    final values = AnalyticsService.getNetWorthHistory(selectedRange);
    final hasHistory = FinancialService.assetHistory.isNotEmpty;

    // Empty State: Tetap menampilkan Card dan Judul jika data kosong
    if (!hasHistory) {
      return AppCard(
        child: SizedBox(
          height: 260,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart_rounded,
                size: 56,
                color: Colors.grey.shade500,
              ),

              const SizedBox(height: 18),

              const Text(
                "Belum ada perkembangan asset",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),

              const SizedBox(height: 8),

              Text(
                "Tambah transaksi untuk mulai\nmelihat pertumbuhan aset.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Perkembangan Asset",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const SizedBox(height: 16),

          // Filter Rentang Waktu
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<AnalyticsRange>(
              style: const ButtonStyle(
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              segments: const [
                ButtonSegment(
                  value: AnalyticsRange.week,
                  label: Text("7 Hari", style: TextStyle(fontSize: 13)),
                ),
                ButtonSegment(
                  value: AnalyticsRange.month,
                  label: Text("1 Bulan", style: TextStyle(fontSize: 13)),
                ),
                ButtonSegment(
                  value: AnalyticsRange.threeMonths,
                  label: Text("3 Bulan", style: TextStyle(fontSize: 13)),
                ),
                ButtonSegment(
                  value: AnalyticsRange.year,
                  label: Text("1 Tahun", style: TextStyle(fontSize: 13)),
                ),
              ],
              selected: {selectedRange},
              onSelectionChanged: (value) {
                setState(() {
                  selectedRange = value.first;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: CustomPaint(
              painter: NetWorthPainter(values),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}
