import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/mboss/domain/repository/mboss_manager_repository.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class UpdateMbossStaffBloc extends Cubit<bool> {
  final MbossManagerRepository repository;

  bool isLoading = false;

  UpdateMbossStaffBloc(this.repository) : super(false);

  Future<void> updateStaff(UserModel user) async {
    if (isLoading) return;
    isLoading = true;
    emit(false);

    try {
      await repository.updateStaff(user.id, user);
      emit(true);
    } catch (e) {
      print("Error creating MBoss Staff: $e");
    } finally {
      isLoading = false;
    }
  }
}
