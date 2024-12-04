import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mbosswater/core/utils/encryption_helper.dart';
import 'package:mbosswater/core/utils/storage.dart';
import 'package:mbosswater/features/login/data/datasource/auth_datasource.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthDatasourceImpl extends AuthDatasource {
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

  @override
  Future<UserModel> loginWithPhoneNumberAndPassword(
      String phoneNumber, String password) async {
    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('No user found with this phone number.');
      }

      // Get the user document
      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();

      String passwordDecrypted = EncryptionHelper.decryptData(
          userData['password'], dotenv.env["SECRET_KEY_PASSWORD_HASH"]!);

      if (passwordDecrypted != password) {
        throw Exception('Password is not correct.');
      }

      String? token;
      if (Platform.isAndroid) {
        token = await FirebaseMessaging.instance.getToken();
        if (token == null) {
          throw Exception("Không thể lấy FCM token.");
        }
      }

      if (Platform.isIOS) {
        // token = await FirebaseMessaging.instance.getAPNSToken();
        // if (token == null) {
        //   throw Exception("Không thể lấy FCM token.");
        // }
      }

      if (token != null) {
        await assignFCMToken(userData['id'], token);
      }

      // Save user login session
      await PreferencesUtils.saveString(
        loginSessionKey,
        userData['id'],
      );

      return UserModel.fromJson(userData);
    } on Exception catch (e) {
      throw Exception('Password or Phone is not correct.');
    }
  }
}
