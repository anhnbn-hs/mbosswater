import 'package:firebase_auth/firebase_auth.dart';
import 'package:mbosswater/features/login/data/datasource/auth_datasource.dart';

class AuthDatasourceImpl extends AuthDatasource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } on Exception catch (e) {
      return null;
    }
  }
}
