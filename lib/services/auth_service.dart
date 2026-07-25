import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static bool get isLoggedIn => _auth.currentUser != null;

  // Getter data pengguna
  static String get userName {
    return _auth.currentUser?.displayName ?? "User";
  }

  static String get email {
    return _auth.currentUser?.email ?? "";
  }

  static String? get photoUrl {
    return _auth.currentUser?.photoURL;
  }

  // Cek apakah pengguna memiliki foto profil
  static bool get hasPhoto {
    return _auth.currentUser?.photoURL?.isNotEmpty ?? false;
  }

  // Cek apakah pengguna login menggunakan Google Account
  static bool get isGoogleUser {
    return _auth.currentUser?.providerData.any(
          (e) => e.providerId == "google.com",
        ) ??
        false;
  }

  // Method untuk memperbarui nama pengguna
  static Future<void> updateName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    await _auth.currentUser?.reload();
  }

  // Method Login dengan Email & Password
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Method Register dengan Email, Password, & Nama
  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Menyimpan Nama ke displayName Firebase
    if (name.isNotEmpty) {
      await credential.user?.updateDisplayName(name);
    }
  }

  // Method Login dengan Google
  static Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  // Method Logout
  static Future<void> logout() async {
    await GoogleSignIn().signOut(); // Logout dari akun Google
    await _auth.signOut(); // Logout dari Firebase Auth
  }
}
