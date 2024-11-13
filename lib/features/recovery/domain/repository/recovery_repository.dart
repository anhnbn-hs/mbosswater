import 'package:mbosswater/features/user_info/data/model/user_model.dart';

abstract class RecoveryRepository {
  Future<bool> verifyEmail(String email);
  Future<void> sendOTP(String email);
  Future<UserModel> changePassword(String email, String newPassword);
}
