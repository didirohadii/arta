import 'package:flutter/material.dart';

import '../../../data/models/wallet_model.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../services/financial_service.dart';

class AddGoldBottomSheet extends StatefulWidget {
  final WalletModel wallet;

  const AddGoldBottomSheet({super.key, required this.wallet});

  @override
  State<AddGoldBottomSheet> createState() => _AddGoldBottomSheetState();
}

class _AddGoldBottomSheetState extends State<AddGoldBottomSheet> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Tambah Emas",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Jumlah Gram",
              hintText: "Contoh 0.25",
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final gram = double.tryParse(_controller.text);

                if (gram == null || gram <= 0) return;

                final updatedWallet = widget.wallet.copyWith(
                  gram: (widget.wallet.gram ?? 0) + gram,
                );

                WalletRepository().update(updatedWallet);

                FinancialService.refreshNotifier.value++;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Emas berhasil ditambahkan")),
                );
              },
              child: const Text("Simpan"),
            ),
          ),
        ],
      ),
    );
  }
}
