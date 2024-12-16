import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;


class EncryptionHelper {
  static String encryptData(String data, String secretKey) {
    try {
      // Ensure the key is exactly 32 characters long
      final key = encrypt.Key.fromUtf8(secretKey.padRight(32, ' ').substring(0, 32));

      // Generate a fixed-length IV
      final iv = encrypt.IV.fromLength(16);

      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

      // Encrypt the data
      final encrypted = encrypter.encrypt(data, iv: iv);

      // Combine base64 encoded IV and base64 encoded encrypted data
      return base64.encode(iv.bytes) + encrypted.base64;
    } catch (e) {
      print("Encryption Error: $e");
      rethrow;
    }
  }

  static String decryptData(String encryptedData, String secretKey) {
    try {
      // Ensure the key is exactly 32 characters long
      final key = encrypt.Key.fromUtf8(secretKey.padRight(32, ' ').substring(0, 32));

      // Split the base64 encoded IV and encrypted data
      // First 24 characters are the base64 encoded IV (16 bytes = 24 base64 chars)
      final ivBase64 = encryptedData.substring(0, 24);
      final encryptedBase64 = encryptedData.substring(24);

      // Decode the IV
      final ivBytes = base64.decode(ivBase64);
      final iv = encrypt.IV(ivBytes);

      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

      // Decrypt the data
      final decrypted = encrypter.decrypt64(encryptedBase64, iv: iv);

      return decrypted;
    } catch (e) {
      print("Decryption Error: $e");
      rethrow;
    }
  }
}