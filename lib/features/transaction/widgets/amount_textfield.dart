import 'package:flutter/material.dart';

class AmountTextField extends StatelessWidget {
  final TextEditingController controller;

  const AmountTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Nominal",
        prefixText: "Rp ",
        border: OutlineInputBorder(),
      ),
    );
  }
}
