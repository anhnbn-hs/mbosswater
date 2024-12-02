import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/ageny/data/datasource/agency_datasource.dart';
import 'package:mbosswater/features/user_info/data/datasource/user_datasource.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class AgencyDatasourceImpl extends AgencyDatasource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final UserDatasource userDatasource;

  AgencyDatasourceImpl(this.userDatasource);

  @override
  Future<void> deleteStaff(String userID) async {
    return await userDatasource.deleteUserInformation(userID);
  }

  @override
  Future<List<UserModel>> fetchUsersOfAgency(String agencyID) async {
    final usersSnapshot = await firebaseFirestore
        .collection("users")
        .where("agency", isEqualTo: agencyID)
        .get();

    return usersSnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> updateStaff(UserModel userUpdate) async {
    return await userDatasource.updateUserInformation(userUpdate);
  }

  @override
  Future<List<UserModel>> fetchUsersOfAgencyByRole(
      String agencyID, String role) async {
    final usersSnapshot = await firebaseFirestore
        .collection("users")
        .where("agency", isEqualTo: agencyID)
        .where("role", isEqualTo: role)
        .get();

    return usersSnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }
}
