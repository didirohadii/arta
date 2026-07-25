import 'package:flutter/material.dart';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  String selectedCurrency = "IDR";

  final currencies = const [
    {"code": "IDR", "name": "Indonesian Rupiah", "symbol": "Rp"},
    {"code": "USD", "name": "US Dollar", "symbol": "\$"},
    {"code": "EUR", "name": "Euro", "symbol": "€"},
    {"code": "SGD", "name": "Singapore Dollar", "symbol": "S\$"},
    {"code": "JPY", "name": "Japanese Yen", "symbol": "¥"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mata Uang")),
      body: ListView.builder(
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final currency = currencies[index];

          return RadioListTile<String>(
            value: currency["code"]!,
            groupValue: selectedCurrency,
            title: Text(currency["code"]!),
            subtitle: Text(currency["name"]!),
            secondary: Text(
              currency["symbol"]!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onChanged: (value) {
              setState(() {
                selectedCurrency = value!;
              });

              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
