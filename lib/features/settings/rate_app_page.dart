import 'package:flutter/material.dart';

class RateAppPage extends StatelessWidget {
  const RateAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Beri Rating")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Icon(Icons.star_rounded, size: 90, color: Colors.amber),

            const SizedBox(height: 24),

            const Text(
              "Terima kasih telah menggunakan Arta",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            const Text(
              "Dukungan Anda sangat berarti.\n"
              "Berikan rating agar Arta terus berkembang menjadi aplikasi keuangan yang lebih baik.",
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Fitur akan tersedia setelah aplikasi dipublikasikan di Play Store.",
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.star),
              label: const Text("Beri Rating"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
