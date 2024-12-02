import 'package:mbosswater/features/user_info/data/model/user_model.dart';

abstract class UserDatasource {
  Future<UserModel> fetchUserInformation(String userID);

  Future<void> updateUserInformation(UserModel userUpdate);

  Future<void> deleteUserInformation(String userID);
}