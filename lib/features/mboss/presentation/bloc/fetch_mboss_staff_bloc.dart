import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/mboss/domain/repository/mboss_manager_repository.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class FetchMbossStaffBloc extends Cubit<List<UserModel>> {
  final MbossManagerRepository repository;

  bool isLoading = false;
  List<UserModel> _allStaff = []; // Cache for all staff
  FetchMbossStaffBloc(this.repository) : super([]);

  List<UserModel> get getStaffsOriginal => _allStaff;

  Future<void> fetchMbossStaffs() async {
    if (isLoading) return;
    isLoading = true;
    emit([]);

    try {
      final staffList = await repository.fetchMBossStaffs();
      _allStaff = staffList;
      emit(staffList);
    } catch (e) {
      print("Error fetching MBoss Staff: $e");
    } finally {
      isLoading = false;
    }
  }

  void searchStaff(String query) {
    if (query.isEmpty) {
      emit(_allStaff);
    } else {
      final filteredStaff = _allStaff
          .where(
            (staff) =>
                staff.fullName!.toLowerCase().contains(query.toLowerCase()) ||
                staff.phoneNumber!.contains(query),
          )
          .toList();
      emit(filteredStaff);
    }
  }
}
