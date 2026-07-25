import 'package:flutter/material.dart';

import '../../core/widgets/app_card.dart';
import '../../core/widgets/currency_text.dart';
import '../../data/models/profile_model.dart';
import '../../services/auth_service.dart';
import '../../services/financial_service.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FinancialService.refreshNotifier,
      builder: (context, _, _) {
        final ProfileModel profile = FinancialService.getProfile();

        final totalAsset = FinancialService.getTotalAsset();
        final totalWallet = FinancialService.getWallets().length;
        final totalTarget = FinancialService.getSavingTargets().length;
        final totalTransaction = FinancialService.getTransactions().length;

        return Scaffold(
          appBar: AppBar(title: const Text("Profil")),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  children: [
                    // CircleAvatar dinamis (Google Photo / Asset Avatar)
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: AuthService.hasPhoto
                          ? NetworkImage(AuthService.photoUrl!)
                          : AssetImage("assets/avatars/${profile.avatar}")
                                as ImageProvider,
                    ),

                    const SizedBox(height: 16),

                    // Nama pengguna dari AuthService
                    Text(
                      AuthService.userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Email pengguna dari AuthService
                    Text(
                      AuthService.email,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    const SizedBox(height: 12),

                    // Badge Account Provider (Google vs Email)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AuthService.isGoogleUser
                            ? "Google Account"
                            : "Email Account",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Mulai menggunakan Arta\n${profile.createdAt.day}/${profile.createdAt.month}/${profile.createdAt.year}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              AppCard(
                child: Column(
                  children: [
                    _StatTile(
                      title: "Total Asset",
                      child: CurrencyText(amount: totalAsset),
                    ),

                    const Divider(),

                    _StatTile(title: "Wallet", child: Text("$totalWallet")),

                    const Divider(),

                    _StatTile(
                      title: "Saving Target",
                      child: Text("$totalTarget"),
                    ),

                    const Divider(),

                    _StatTile(
                      title: "Transaksi",
                      child: Text("$totalTransaction"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );

                  if (result == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profil berhasil diperbarui 🎉"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profil"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final Widget child;

  const _StatTile({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: child,
    );
  }
}
