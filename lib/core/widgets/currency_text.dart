import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyText extends StatelessWidget {
  final double amount;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const CurrencyText({
    super.key,
    required this.amount,
    this.fontSize = 18,
    this.fontWeight = FontWeight.bold,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Text(
      formatter.format(amount),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
