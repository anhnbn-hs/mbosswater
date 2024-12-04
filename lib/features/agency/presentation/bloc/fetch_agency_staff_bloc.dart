import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/agency/data/agency_datasource.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class FetchAgencyStaffBloc extends Cubit<List<UserModel>> {
  final AgencyDatasource repository;

  bool isLoading = false;

  FetchAgencyStaffBloc(this.repository) : super([]);

  Future<void> fetchAgencyStaffs(String agencyID) async {
    if (isLoading) return;
    isLoading = true;
    emit([]);

    try {
      final staffList = await repository.fetchUsersOfAgencyForAdmin(agencyID);
      emit(staffList);
    } catch (e) {
      print("Error fetching MBoss Staff: $e");
    } finally {
      isLoading = false;
    }
  }
}