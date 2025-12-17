import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> ensureSignedIn() async {
    if (_auth.currentUser != null) return;
    await _auth.signInAnonymously();
  }

  String get uid => _auth.currentUser!.uid;
}
