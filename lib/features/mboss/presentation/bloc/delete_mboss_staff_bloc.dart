import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/mboss/domain/repository/mboss_manager_repository.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class DeleteMbossStaffBloc extends Cubit<bool> {
  final MbossManagerRepository repository;

  bool isLoading = false;

  DeleteMbossStaffBloc(this.repository) : super(false);

  Future<void> deleteStaff(String id) async {
    if (isLoading) return;
    isLoading = true;
    emit(false);
    try {
      await repository.deleteStaff(id);
      emit(true);
    } catch (e) {
      print("Error creating MBoss Staff: $e");
    } finally {
      isLoading = false;
    }
  }
}
