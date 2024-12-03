import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/mboss/data/datasource/mboss_manager_datasource.dart';
import 'package:mbosswater/features/mboss/domain/repository/mboss_manager_repository.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class MbossManagerRepositoryImpl extends MbossManagerRepository {
  final MbossManagerDatasource datasource;

  MbossManagerRepositoryImpl(this.datasource);

  @override
  Future<void> createStaff(UserModel newStaff) async {
    return await datasource.createStaff(newStaff);
  }

  @override
  Future<void> deleteAgency(String agencyID) async {
    return await datasource.deleteAgency(agencyID);
  }

  @override
  Future<void> deleteStaff(String userID) async {
    return await datasource.deleteStaff(userID);
  }

  @override
  Future<List<Agency>> fetchAgencies() async {
    return await datasource.fetchAgencies();
  }

  @override
  Future<Agency> fetchAgencyByID(String id) async {
    return await datasource.fetchAgencyByID(id);
  }

  @override
  Future<List<UserModel>> fetchMBossStaffs() async {
    return await datasource.fetchMBossStaffs();
  }

  @override
  Future<UserModel> fetchStaffByID(String id) async {
    return await datasource.fetchStaffByID(id);
  }

  @override
  Future<UserModel> fetchStaffByPhoneNumber(String phoneNumber) async {
    return await datasource.fetchStaffByPhoneNumber(phoneNumber);
  }

  @override
  Future<void> updateAgency(String agencyID, Agency agencyUpdate) async {
    return await datasource.updateAgency(agencyID, agencyUpdate);
  }

  @override
  Future<void> updateStaff(String userID, UserModel userUpdate) async {
    return await datasource.updateStaff(userID, userUpdate);
  }
}
