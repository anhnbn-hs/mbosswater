import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthDatasource {
  Future<User?> loginWithEmailAndPassword(String email, String password);
}