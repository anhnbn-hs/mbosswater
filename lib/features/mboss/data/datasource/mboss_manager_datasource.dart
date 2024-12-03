import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

abstract class MbossManagerDatasource {
  // Agency Management
  Future<List<Agency>> fetchAgencies();

  Future<Agency> fetchAgencyByID(String id);

  Future<void> updateAgency(String agencyID, Agency agencyUpdate);

  Future<void> deleteAgency(String agencyID);

  // Staff Management
  Future<List<UserModel>> fetchMBossStaffs();

  Future<UserModel> fetchStaffByID(String id);

  Future<UserModel> fetchStaffByPhoneNumber(String phoneNumber);

  Future<void> createStaff(UserModel newStaff);

  Future<void> updateStaff(String userID, UserModel userUpdate);

  Future<void> deleteStaff(String userID);
}
