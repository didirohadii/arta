import 'package:flutter/material.dart';

import '../../data/models/profile_model.dart';
import '../../services/auth_service.dart';
import '../../services/financial_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController();
  final goalController = TextEditingController();

  late DateTime createdAt;
  late String selectedAvatar;

  // Daftar avatar lokal yang bisa dipilih
  final List<String> avatars = [
    "avatar_1.png",
    "avatar_2.png",
    "avatar_3.png",
    "avatar_4.png",
  ];

  @override
  void initState() {
    super.initState();

    final profile = FinancialService.getProfile();

    // Mengambil nama langsung dari AuthService
    nameController.text = AuthService.userName;
    goalController.text = profile.financialGoal;
    createdAt = profile.createdAt;
    selectedAvatar = profile.avatar.isNotEmpty ? profile.avatar : avatars.first;
  }

  @override
  void dispose() {
    nameController.dispose();
    goalController.dispose();
    super.dispose();
  }

  // Dialog untuk memilih avatar lokal (Khusus akun Email)
  Future<void> pickAvatar() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * .65,
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: 16,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final avatar = "avatar_${index + 1}.png";

              return InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  setState(() {
                    selectedAvatar = avatar;
                  });

                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage("assets/avatars/$avatar"),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: createdAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (result != null) {
      setState(() {
        createdAt = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Tampilan Avatar Dinamis (Google / Local Avatar Selection)
          Center(
            child: AuthService.isGoogleUser
                ? CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: AuthService.hasPhoto
                        ? NetworkImage(AuthService.photoUrl!)
                        : null,
                    child: !AuthService.hasPhoto
                        ? const Icon(Icons.person, size: 45)
                        : null,
                  )
                : InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: pickAvatar,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: AssetImage(
                        "assets/avatars/$selectedAvatar",
                      ),
                    ),
                  ),
          ),

          // Tombol Ubah Avatar / Keterangan Akun Google
          if (!AuthService.isGoogleUser)
            Center(
              child: TextButton(
                onPressed: pickAvatar,
                child: const Text("Ubah Avatar"),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "Foto profil menggunakan akun Google",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 20),

          // Field Email (Disabled / Read-only)
          TextFormField(
            initialValue: AuthService.email,
            enabled: false,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),

          const SizedBox(height: 20),

          // Field Nama (Dapat diubah)
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Nama",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),

          const SizedBox(height: 20),

          // Field Target Finansial
          TextField(
            controller: goalController,
            decoration: const InputDecoration(
              labelText: "Target Finansial",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag),
            ),
          ),

          const SizedBox(height: 20),

          // Pemilih Tanggal
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month),
            title: const Text("Mulai Menggunakan"),
            subtitle: Text(
              "${createdAt.day}/${createdAt.month}/${createdAt.year}",
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: pickDate,
          ),

          const SizedBox(height: 30),

          // Tombol Simpan
          FilledButton(
            onPressed: () async {
              // 1. Update Nama ke Firebase Auth
              await AuthService.updateName(nameController.text.trim());

              // 2. Update data profil lokal
              final profile = ProfileModel(
                name: nameController.text.trim(),
                financialGoal: goalController.text.trim(),
                createdAt: createdAt,
                avatar: selectedAvatar,
              );

              FinancialService.updateProfile(profile);

              // 3. Pengecekan context.mounted tepat sebelum Navigator
              if (!context.mounted) return;

              Navigator.pop(context, true);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
