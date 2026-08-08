import 'package:flutter/material.dart';

import '../analytics/analytics_page.dart';
import '../dashboard/dashboard_page.dart';
import '../settings/settings_page.dart';
import '../transaction/transaction_page.dart';
import '../wallet/wallet_page.dart';
import '../transaction/add_transaction_page.dart';

// 1. Notifier global untuk kontrol tab navigasi dari mana saja
final ValueNotifier<int> mainPageIndexNotifier = ValueNotifier<int>(0);

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    WalletPage(),
    TransactionPage(),
    AnalyticsPage(),
    SettingsPage(),
  ];

  // 2. Pasang listener untuk memantau perubahan tab
  @override
  void initState() {
    super.initState();
    mainPageIndexNotifier.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!mounted) return;
    setState(() {
      currentIndex = mainPageIndexNotifier.value;
    });
  }

  @override
  void dispose() {
    mainPageIndexNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      floatingActionButton: (currentIndex == 0 || currentIndex == 2)
          ? SizedBox(
              width: 62,
              height: 62,
              child: FloatingActionButton(
                elevation: 8,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionPage(),
                    ),
                  );
                },
                child: const Icon(Icons.add, size: 30),
              ),
            )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        height: 70,

        // 3. Update nilai notifier ketika tab ditekan
        onDestinationSelected: (index) {
          mainPageIndexNotifier.value = index;
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),

          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: "Wallet",
          ),

          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: "Transaksi",
          ),

          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: "Analisis",
          ),

          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: "Setting",
          ),
        ],
      ),
    );
  }
}
