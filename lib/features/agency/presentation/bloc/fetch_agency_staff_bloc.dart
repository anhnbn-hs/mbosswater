import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/mboss/domain/repository/mboss_manager_repository.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class FetchMbossStaffBloc extends Cubit<List<UserModel>> {
  final MbossManagerRepository repository;

  bool isLoading = false;

  FetchMbossStaffBloc(this.repository) : super([]);

  Future<void> fetchAStaffs() async {
    if (isLoading) return;
    isLoading = true;
    emit([]);

    try {
      final staffList = await repository.fetchMBossStaffs();
      emit(staffList);
    } catch (e) {
      print("Error fetching MBoss Staff: $e");
    } finally {
      isLoading = false;
    }
  }
}