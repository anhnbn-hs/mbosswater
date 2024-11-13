import 'package:mbosswater/features/recovery/data/datasource/recovery_datasource.dart';
import 'package:mbosswater/features/recovery/domain/repository/recovery_repository.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class RecoveryRepositoryImpl extends RecoveryRepository {
  final RecoveryDatasource _datasource;

  RecoveryRepositoryImpl(this._datasource);

  @override
  Future<void> sendOTP(String email) async {
    return await _datasource.sendOTP(email);
  }

  @override
  Future<bool> verifyEmail(String email) async {
    return await _datasource.verifyEmail(email);
  }

  @override
  Future<UserModel> changePassword(String email, String newPassword) async {
    return await _datasource.changePassword(email, newPassword);
  }
}
