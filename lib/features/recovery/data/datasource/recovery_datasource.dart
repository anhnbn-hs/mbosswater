import 'package:mbosswater/features/user_info/data/model/user_model.dart';

abstract class RecoveryDatasource {
  Future<void> sendOTP(String phoneNumber);
  Future<UserModel> changePassword(String phoneNumber, String newPassword);
}