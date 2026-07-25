import 'package:flutter/material.dart';

import '../../data/models/transaction_model.dart';

extension TransactionTypeExtension on TransactionType {
  IconData get icon {
    switch (this) {
      case TransactionType.income:
        return Icons.south_west_rounded;

      case TransactionType.expense:
        return Icons.north_east_rounded;

      case TransactionType.transfer:
        return Icons.swap_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.income:
        return Colors.green;

      case TransactionType.expense:
        return Colors.red;

      case TransactionType.transfer:
        return Colors.blue;
    }
  }
}
