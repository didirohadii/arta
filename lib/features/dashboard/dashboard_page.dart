import 'package:flutter/material.dart';

import 'package:arta/data/models/profile_model.dart';
import 'package:arta/services/auth_service.dart';
import 'package:arta/services/financial_service.dart';
import 'widgets/insight_card.dart';
import 'widgets/latest_transaction_card.dart';
import 'widgets/saving_target_card.dart';
import 'widgets/total_asset_card.dart';
import 'widgets/wallet_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // Helper untuk menyapa pengguna berdasarkan waktu saat ini
  String greeting() {
    final hour = DateTime.now().hour;

    if (hour < 11) return "Selamat Pagi";
    if (hour < 15) return "Selamat Siang";
    if (hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  // Helper untuk menampilkan tanggal hari ini
  String _today() {
    const hari = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu",
    ];

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

    final now = DateTime.now();

    return "${hari[now.weekday - 1]}, ${now.day} ${bulan[now.month - 1]} ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ValueListenableBuilder(
        valueListenable: FinancialService.refreshNotifier,
        builder: (context, value, child) {
          // Mengambil data profile di dalam builder agar ikut ter-update secara reaktif
          final ProfileModel profile = FinancialService.getProfile();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar pengguna (Support foto Google / Avatar Aset Lokal)
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: AuthService.photoUrl != null
                            ? NetworkImage(AuthService.photoUrl!)
                            : AssetImage("assets/avatars/${profile.avatar}")
                                  as ImageProvider,
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Greeting
                            Text(
                              "${greeting()},",
                              style: const TextStyle(fontSize: 18),
                            ),

                            const SizedBox(height: 4),

                            // Nama pengguna dari AuthService
                            Text(
                              AuthService.userName,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (profile.financialGoal.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                profile.financialGoal,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Menampilkan tanggal hari ini
                  Text(
                    _today(),
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Deretan Card Informasi Keuangan
                  const TotalAssetCard(),
                  const SizedBox(height: 20),
                  const InsightCard(),
                  const SizedBox(height: 18),
                  const WalletCard(),
                  const SizedBox(height: 18),
                  const SavingTargetCard(),
                  const SizedBox(height: 18),
                  const LatestTransactionCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
