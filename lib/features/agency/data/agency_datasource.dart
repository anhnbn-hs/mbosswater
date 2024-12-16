import 'package:mbosswater/features/user_info/data/model/user_model.dart';

abstract class AgencyDatasource {
  // For Boss Agency
  Future<List<UserModel>> fetchUsersOfAgencyForAdmin(String agencyID);

  Future<List<UserModel>> fetchUsersOfAgencyByRole(
      String agencyID, String role);

  Future<void> createStaff(UserModel newStaff);

  Future<void> updateStaff(UserModel userUpdate);

  Future<void> deleteStaff(String userID);
}
