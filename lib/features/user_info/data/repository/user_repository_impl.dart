import 'package:mbosswater/features/user_info/data/datasource/user_datasource.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';
import 'package:mbosswater/features/user_info/domain/repository/user_repository.dart';

class UserRepositoryImpl extends UserRepository {
  final UserDatasource datasource;

  UserRepositoryImpl(this.datasource);

  @override
  Future<UserModel> fetchUserInformation(String userID) async {
    return await datasource.fetchUserInformation(userID);
  }
}
