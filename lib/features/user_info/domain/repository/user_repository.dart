import 'package:mbosswater/features/user_info/data/model/user_model.dart';

abstract class UserRepository {
  Future<UserModel> fetchUserInformation(String userID);
}