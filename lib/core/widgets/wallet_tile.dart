import 'package:flutter/material.dart';

import 'currency_text.dart';

class WalletTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final double amount;

  /// true jika wallet emas
  final bool isGold;

  const WalletTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.amount,
    this.isGold = false,
  });

  /// Helper untuk merapikan tampilan desimal gram
  String _formatGram(double gram) {
    if (gram % 1 == 0) {
      return "${gram.toInt()} gr";
    }
    return "${gram.toStringAsFixed(2)} gr";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 8),

          isGold
              ? Text(
                  _formatGram(amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
              : CurrencyText(amount: amount),
        ],
      ),
    );
  }
}
