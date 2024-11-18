import 'package:mbosswater/features/user_info/data/model/user_model.dart';
import 'package:mbosswater/features/user_info/domain/repository/user_repository.dart';

class FetchUserInfoUseCase {
  final UserRepository _repository;

  FetchUserInfoUseCase(this._repository);

  Future<UserModel> call(String userID) async {
    return await _repository.fetchUserInformation(userID);
  }
}