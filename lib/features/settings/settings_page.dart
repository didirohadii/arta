import 'package:flutter/material.dart';

import '../goals/saving_target_page.dart';
import '../profile/profile_page.dart';
import '../wallet/wallet_page.dart';
import '../../services/auth_service.dart';
import '../../services/export_service.dart';
import '../../services/financial_service.dart';
import 'about_page.dart';
import 'currency_page.dart';
import 'rate_app_page.dart';
import 'theme_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = FinancialService.getProfile();

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card Profile Interaktif (bisa di-tap untuk ke ProfilePage)
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 20),
            child: ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: AuthService.photoUrl != null
                    ? NetworkImage(AuthService.photoUrl!)
                    : AssetImage("assets/avatars/${profile.avatar}")
                          as ImageProvider,
              ),
              title: Text(AuthService.userName),
              subtitle: Text(AuthService.email),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
          ),

          const _SectionTitle("General"),

          _SettingTile(
            icon: Icons.attach_money,
            title: "Mata Uang",
            subtitle: "Rupiah (IDR)",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CurrencyPage()),
              );
            },
          ),

          _SettingTile(
            icon: Icons.dark_mode,
            title: "Tema",
            subtitle: "Light / Dark",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThemePage()),
              );
            },
          ),

          const SizedBox(height: 24),

          const _SectionTitle("Data"),

          _SettingTile(
            icon: Icons.account_balance_wallet,
            title: "Kelola Wallet",
            subtitle: "Lihat seluruh wallet",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WalletPage()),
              );
            },
          ),

          _SettingTile(
            icon: Icons.flag,
            title: "Kelola Target",
            subtitle: "Target menabung",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavingTargetPage()),
              );
            },
          ),

          const SizedBox(height: 24),

          const _SectionTitle("Backup"),

          _SettingTile(
            icon: Icons.table_view,
            title: "Export Excel",
            subtitle: "Export seluruh data",
            onTap: () async {
              await ExportService.exportExcel();
            },
          ),

          _SettingTile(
            icon: Icons.picture_as_pdf,
            title: "Export PDF",
            subtitle: "Laporan keuangan",
            onTap: () async {
              await ExportService.exportPdf();
            },
          ),

          const SizedBox(height: 24),

          const _SectionTitle("About"),

          _SettingTile(
            icon: Icons.star_rate,
            title: "Beri Rating",
            subtitle: "Dukung aplikasi",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RateAppPage()),
              );
            },
          ),

          _SettingTile(
            icon: Icons.info,
            title: "Tentang Aplikasi",
            subtitle: "Versi 1.0.0",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            },
          ),

          const SizedBox(height: 24),

          // Card Logout
          Card(
            elevation: 0,
            color: Theme.of(
              context,
            ).colorScheme.errorContainer.withValues(alpha: 0.3),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                "Logout",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Keluar Akun?"),
                      content: const Text(
                        "Apakah kamu yakin ingin keluar dari akun ini?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Batal"),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Logout"),
                        ),
                      ],
                    );
                  },
                );

                if (confirm != true) return;

                // Cukup logout dari Firebase, StreamBuilder di app.dart akan menangani sisanya
                await AuthService.logout();

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Berhasil logout")),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
