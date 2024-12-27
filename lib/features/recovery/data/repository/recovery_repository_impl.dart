import 'package:mbosswater/features/recovery/data/datasource/recovery_datasource.dart';
import 'package:mbosswater/features/recovery/domain/repository/recovery_repository.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class RecoveryRepositoryImpl extends RecoveryRepository {
  final RecoveryDatasource _datasource;

  RecoveryRepositoryImpl(this._datasource);

  @override
  Future<void> sendOTP(String phoneNumber) async {
    return await _datasource.sendOTP(phoneNumber);
  }

  @override
  Future<UserModel> changePassword(String phoneNumber, String newPassword) async {
    return await _datasource.changePassword(phoneNumber, newPassword);
  }
}
