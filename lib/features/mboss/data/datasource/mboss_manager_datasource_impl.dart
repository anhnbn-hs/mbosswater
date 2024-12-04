import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/core/services/firebase_cloud_functions.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/mboss/data/datasource/mboss_manager_datasource.dart';
import 'package:mbosswater/features/user_info/data/datasource/user_datasource.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class MbossManagerDatasourceImpl extends MbossManagerDatasource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseCloudFunctions cloudFunctions = FirebaseCloudFunctions.instance;
  final UserDatasource userDatasource;

  MbossManagerDatasourceImpl(this.userDatasource);

  @override
  Future<void> createStaff(UserModel newStaff) async {
    try {
      await firebaseFirestore
          .collection("users")
          .doc(newStaff.id)
          .set(newStaff.toJson(), SetOptions(merge: true));
    } catch (e) {
      print("Error creating staff: $e");
      rethrow; // Propagate error if needed
    }
  }

  @override
  Future<void> deleteAgency(String agencyID) async {
    await firebaseFirestore.collection("agency").doc(agencyID).delete();
  }

  @override
  Future<void> deleteStaff(String userID) async {
    try {
      await firebaseFirestore.collection("users").doc(userID).update({
        "isDelete": true,
        "fcmToken": "",
        "phoneNumber": "",
        "email": "",
        "address": "",
      });
      print('User $userID deleted successfully.');
    } catch (e) {
      print('Error deleting user $userID: $e');
      rethrow;
    }
  }

  @override
  Future<List<Agency>> fetchAgencies() async {
    final querySnapshot = await firebaseFirestore.collection("agency").get();
    return querySnapshot.docs
        .map((doc) => Agency.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<Agency> fetchAgencyByID(String id) async {
    final docSnapshot =
        await firebaseFirestore.collection("agency").doc(id).get();
    if (docSnapshot.exists) {
      return Agency.fromJson(docSnapshot.data() as Map<String, dynamic>, id);
    } else {
      throw Exception("Agency not found");
    }
  }

  @override
  Future<List<UserModel>> fetchMBossStaffs() async {
    final querySnapshot = await firebaseFirestore
        .collection("users")
        .where(
          "role",
          whereIn: [
            Roles.MBOSS_CUSTOMERCARE,
            Roles.MBOSS_TECHNICAL,
          ],
        )
        .where("isDelete", isEqualTo: false)
        .get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<UserModel> fetchStaffByID(String id) async {
    final docSnapshot =
        await firebaseFirestore.collection("users").doc(id).get();
    if (docSnapshot.exists) {
      return UserModel.fromJson(docSnapshot.data() as Map<String, dynamic>);
    } else {
      throw Exception("Staff not found");
    }
  }

  @override
  Future<UserModel> fetchStaffByPhoneNumber(String phoneNumber) async {
    final querySnapshot = await firebaseFirestore
        .collection("users")
        .where("phoneNumber", isEqualTo: phoneNumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return UserModel.fromJson(querySnapshot.docs.first.data());
    } else {
      throw Exception("Staff with phone number $phoneNumber not found");
    }
  }

  @override
  Future<void> updateAgency(String agencyID, Agency agencyUpdate) async {
    await firebaseFirestore
        .collection("agencies")
        .doc(agencyID)
        .update(agencyUpdate.toJson());
  }

  @override
  Future<void> updateStaff(String userID, UserModel userUpdate) async {
    return await userDatasource.updateUserInformation(userUpdate);
  }
}
