import 'package:mbosswater/features/user_info/data/model/user_model.dart';

abstract class AuthDatasource {
  Future<UserModel> loginWithPhoneNumberAndPassword(
    String phoneNumber,
    String password,
  );

  Future<void> assignFCMToken(String userID, String token);
}
