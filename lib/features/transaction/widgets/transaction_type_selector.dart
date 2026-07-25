import 'package:flutter/material.dart';

class TransactionTypeSelector extends StatelessWidget {
  final bool isExpense;
  final VoidCallback onExpense;
  final VoidCallback onIncome;

  const TransactionTypeSelector({
    super.key,
    required this.isExpense,
    required this.onExpense,
    required this.onIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Text("Pengeluaran"),
            selected: isExpense,
            onSelected: (_) => onExpense(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ChoiceChip(
            label: const Text("Pemasukan"),
            selected: !isExpense,
            onSelected: (_) => onIncome(),
          ),
        ),
      ],
    );
  }
}
