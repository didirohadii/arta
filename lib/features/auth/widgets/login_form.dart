import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // State untuk berpindah mode Login/Register
  bool isLogin = true;

  // State untuk visibilitas password
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // Controllers untuk Form Input
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Method untuk mengubah error Firebase menjadi pesan bahasa Indonesia yang ramah pengguna
  String getFirebaseMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-credential':
          return 'Email atau password salah.';
        case 'user-not-found':
          return 'Akun tidak ditemukan.';
        case 'wrong-password':
          return 'Password salah.';
        case 'email-already-in-use':
          return 'Email sudah terdaftar.';
        case 'weak-password':
          return 'Password minimal 6 karakter.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'network-request-failed':
          return 'Tidak ada koneksi internet.';
        default:
          return e.message ?? 'Terjadi kesalahan.';
      }
    }

    return e.toString();
  }

  // Method untuk menangani proses login/register
  Future<void> _handleAuth() async {
    try {
      if (emailController.text.trim().isEmpty ||
          passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email dan Password wajib diisi")),
        );
        return;
      }

      if (isLogin) {
        await AuthService.login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      } else {
        if (nameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Nama wajib diisi")));
          return;
        }

        if (passwordController.text != confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Konfirmasi password tidak sama")),
          );
          return;
        }

        // Mengirimkan name, email, dan password ke AuthService.register
        await AuthService.register(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      }

      // StreamBuilder di app.dart mendeteksi autentikasi Firebase secara otomatis.
    } catch (e, stackTrace) {
      debugPrint("========== AUTH ERROR ==========");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(getFirebaseMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Input Nama (Hanya tampil saat Register)
        if (!isLogin) ...[
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Nama",
              prefixIcon: const Icon(Icons.person_outline),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Input Email
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            labelText: "Email",
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const SizedBox(height: 16),

        // Input Password
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            labelText: "Password",
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        // Input Konfirmasi Password (Hanya tampil saat Register)
        if (!isLogin) ...[
          const SizedBox(height: 16),
          TextField(
            controller: confirmPasswordController,
            obscureText: obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: "Konfirmasi Password",
              prefixIcon: const Icon(Icons.lock_reset),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    obscureConfirmPassword = !obscureConfirmPassword;
                  });
                },
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Tombol Utama (Login / Buat Akun)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _handleAuth,
            child: Text(
              isLogin ? "Login" : "Buat Akun",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Pembatas / Divider
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text("atau"),
            ),
            Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 16),

        // Tombol Google
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () async {
              try {
                await AuthService.signInWithGoogle();
              } catch (e, stackTrace) {
                debugPrint("========== AUTH GOOGLE ERROR ==========");
                debugPrint(e.toString());
                debugPrint(stackTrace.toString());

                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(getFirebaseMessage(e))));
              }
            },
            icon: const Icon(Icons.g_mobiledata, size: 30),
            label: Text(
              isLogin ? "Masuk dengan Google" : "Daftar dengan Google",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Toggle Switcher (Switch antara Login & Register)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isLogin ? "Belum punya akun?" : "Sudah punya akun?"),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(isLogin ? "Daftar" : "Masuk"),
            ),
          ],
        ),
      ],
    );
  }
}
