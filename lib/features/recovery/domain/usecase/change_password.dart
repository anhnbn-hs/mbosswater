import 'package:mbosswater/features/recovery/domain/repository/recovery_repository.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class ChangePasswordUseCase {
  final RecoveryRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<UserModel> call(String email, String newPassword) async {
    return await _repository.changePassword(email, newPassword);
  }

}