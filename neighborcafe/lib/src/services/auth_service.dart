import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    if (credential.user != null) {
      final token = await credential.user!.getIdToken();
      await _storage.write(key: 'authToken', value: token);
    }

    return credential;
  }

  Future<UserCredential> register(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    if (credential.user != null) {
      final token = await credential.user!.getIdToken();
      await _storage.write(key: 'authToken', value: token);
    }

    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.delete(key: 'authToken');
  }

  Future<bool> isSignedIn() async {
    final token = await _storage.read(key: 'authToken');
    return token != null;
  }

  Future<User?> getUser() async {
    final token = await _storage.read(key: 'authToken');
    if (token != null && _auth.currentUser == null) {
      try {
        await _auth.signInWithCustomToken(token);
      } catch (e) {
        await _storage.delete(key: 'authToken');
      }
    }
    return _auth.currentUser;
  }

  Future<bool> checkEmailVerified() async {
    User? user = _auth.currentUser;

    if (user != null) {
      await user.reload();
      user = _auth.currentUser;
      return user!.emailVerified;
    }

    return false;
  }

  Future<Map<String, bool>> getAuthStatus() async {
    bool signedIn = await isSignedIn();
    bool emailVerified = signedIn ? await checkEmailVerified() : false;
    return {
      'isSignedIn': signedIn,
      'isEmailVerified': emailVerified,
    };
  }

  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}
