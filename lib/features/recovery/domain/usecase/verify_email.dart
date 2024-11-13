import 'package:mbosswater/features/recovery/domain/repository/recovery_repository.dart';

class VerifyEmailUseCase {
  final RecoveryRepository _repository;

  VerifyEmailUseCase(this._repository);

  Future<bool> call(String email) async {
    return _repository.verifyEmail(email);
  }

  Future<void> sendOTP(String email) async {
    return await _repository.sendOTP(email);
  }
}