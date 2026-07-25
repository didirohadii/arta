import 'package:flutter/material.dart';
import '../../data/models/wallet_model.dart';

extension WalletTypeExtension on WalletType {
  IconData get icon {
    switch (this) {
      case WalletType.cash:
        return Icons.payments;

      case WalletType.bank:
        return Icons.account_balance;

      case WalletType.investment:
        return Icons.trending_up;

      case WalletType.gold:
        return Icons.workspace_premium;
    }
  }

  Color get color {
    switch (this) {
      case WalletType.cash:
        return Colors.green;

      case WalletType.bank:
        return Colors.blue;

      case WalletType.investment:
        return Colors.deepOrange;

      case WalletType.gold:
        return Colors.amber;
    }
  }
}
