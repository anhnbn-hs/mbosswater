import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/agency/data/datasource/agency_datasource.dart';
import 'package:mbosswater/features/agency/domain/repository/agency_repository.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class AgencyRepositoryImpl extends AgencyRepository {
  final AgencyDatasource datasource;

  AgencyRepositoryImpl(this.datasource);

  @override
  Future<void> deleteStaff(String userID) async {
    return await datasource.deleteStaff(userID);
  }

  @override
  Future<List<UserModel>> fetchUsersOfAgencyForAdmin(String agencyID) async {
    return await datasource.fetchUsersOfAgencyForAdmin(agencyID);
  }

  @override
  Future<void> updateStaff(UserModel userUpdate) async {
    return await datasource.updateStaff(userUpdate);
  }

  @override
  Future<List<UserModel>> fetchUsersOfAgencyByRole(
      String agencyID, String role) async {
    return await datasource.fetchUsersOfAgencyByRole(agencyID, role);
  }
}
