import 'package:encrypt/encrypt.dart' as encrypt;


class EncryptionHelper {
  static String encryptData(String data, String secretKey) {
    try {
      final key = encrypt.Key.fromUtf8(secretKey.padRight(32, ' ').substring(0, 32)); // Đảm bảo độ dài 32 ký tự
      final iv = encrypt.IV.fromLength(16); // IV dài 16 byte

      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      // Mã hóa dữ liệu và lưu IV cùng với dữ liệu mã hóa (base64)
      final encrypted = encrypter.encrypt(data, iv: iv);
      // Lưu IV cùng với dữ liệu mã hóa (hoặc sử dụng một cách khác để lưu trữ IV)
      return iv.base64 + encrypted.base64; // Gộp IV và dữ liệu mã hóa
    } on Exception catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  static String decryptData(String encryptedData, String secretKey) {
    try {
      final key = encrypt.Key.fromUtf8(secretKey.padRight(32, ' ').substring(0, 32)); // Đảm bảo độ dài 32 ký tự

      // Tách IV và dữ liệu mã hóa
      final ivBase64 = encryptedData.substring(0, 24); // IV có độ dài 16 byte (24 ký tự base64)
      final encryptedBase64 = encryptedData.substring(24); // Dữ liệu mã hóa còn lại

      final iv = encrypt.IV.fromBase64(ivBase64); // Chuyển đổi IV từ base64
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      // Giải mã dữ liệu
      final decrypted = encrypter.decrypt64(encryptedBase64, iv: iv);
      return decrypted;
    } on Exception catch (e) {
      print("Error during decryption: $e");
      rethrow;
    }
  }
}