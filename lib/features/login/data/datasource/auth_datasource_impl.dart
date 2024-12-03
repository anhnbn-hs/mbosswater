import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mbosswater/features/login/data/datasource/auth_datasource.dart';

class AuthDatasourceImpl extends AuthDatasource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception(
            "Không thể lấy thông tin người dùng sau khi đăng nhập.");
      }

      // Get FCM Token
      String? token = "";
      if (Platform.isAndroid) {
        token = await FirebaseMessaging.instance.getToken();
        if (token == null) {
          throw Exception("Không thể lấy FCM token.");
        }
      }

      if (Platform.isIOS) {
        token = await FirebaseMessaging.instance.getAPNSToken();
        if (token == null) {
          throw Exception("Không thể lấy FCM token.");
        }
      }

      // Assign Token to user
      await assignFCMToken(user.uid, token);

      return user;
    } on Exception {
      return null;
    }
  }

  @override
  Future<void> assignFCMToken(String userID, String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .update({'fcmToken': token});

      print("FCM token đã được gán cho người dùng: $userID");
    } catch (e) {
      print("Lỗi khi gán FCM token cho người dùng $userID: $e");
      rethrow;
    }
  }
}
