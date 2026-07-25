import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tentang Arta")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          // Ganti Container lamamu dengan kode presisi ini:
          Center(
            child: Container(
              width: 95, // Sedikit lebih besar untuk kompensasi border
              height: 95,
              decoration: BoxDecoration(
                // 1. Kasih bentuk lingkaran
                shape: BoxShape.circle,
                // 2. Tambahin Border (Outline) berwarna ungu kebiruan (Indigo)
                border: Border.all(
                  color: Colors.indigo.shade400, // Warna ungu kebiruan
                  width: 3, // Ketebalan outline
                ),
                // Optional: Kasih shadow tipis biar kelihatan popup
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              // 3. !!! PENTING !!! Potong logo kotak jadi bulat sempurna
              child: ClipOval(
                child: Image.asset(
                  'assets/images/about.png', // Pastiin path ini bener (gw balikin ke arta_logo.png)
                  fit: BoxFit
                      .cover, // !!! PENTING !!! Pake 'cover' biar penuhin lingkaran, bukan 'contain'
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Center(
            child: Text(
              "Arta",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 6),

          const Center(
            child: Text(
              "Personal Finance Manager",
              style: TextStyle(color: Colors.grey),
            ),
          ),

          const SizedBox(height: 30),

          const Card(
            child: ListTile(
              leading: Icon(Icons.verified),
              title: Text("Versi"),
              trailing: Text("1.0.0"),
            ),
          ),

          const Card(
            child: ListTile(
              leading: Icon(Icons.flutter_dash),
              title: Text("Framework"),
              trailing: Text("Flutter"),
            ),
          ),

          const Card(
            child: ListTile(
              leading: Icon(Icons.storage),
              title: Text("Database"),
              trailing: Text("Dummy Repository"),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Arta adalah aplikasi pencatat keuangan pribadi yang membantu pengguna mengelola aset, transaksi, wallet, serta target menabung dalam satu aplikasi yang sederhana dan mudah digunakan.",
            textAlign: TextAlign.justify,
          ),

          const SizedBox(height: 30),

          const Divider(),

          const SizedBox(height: 10),

          Center(
            child: Text(
              "Developed with ❤️ using Flutter",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),

          const SizedBox(height: 6),

          Center(
            child: Text("© 2026 Aldiya", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
