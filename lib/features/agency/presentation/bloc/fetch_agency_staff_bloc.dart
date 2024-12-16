import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/agency/data/agency_datasource.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class FetchAgencyStaffBloc extends Cubit<List<UserModel>> {
  final AgencyDatasource repository;
  List<UserModel> _allStaff = []; // Cache for all staff
  bool isLoading = false;
  List<UserModel> get getStaffsOriginal => _allStaff;
  FetchAgencyStaffBloc(this.repository) : super([]);

  Future<void> fetchAgencyStaffs(String agencyID) async {
    if (isLoading) return;
    isLoading = true;
    emit([]);

    try {
      final staffList = await repository.fetchUsersOfAgencyForAdmin(agencyID);
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