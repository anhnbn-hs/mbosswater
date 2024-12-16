import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class FetchAgencyAdminCubit extends Cubit<UserModel?> {
  FetchAgencyAdminCubit() : super(null);

  bool isLoading = false;

  Future<void> fetchAdminOfAgency(String agencyID) async {
    isLoading = true;
    emit(null);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("agency", isEqualTo: agencyID)
          .where("role", isEqualTo: Roles.AGENCY_BOSS)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final user = UserModel.fromJson(userData);
        emit(user);
      } else {
        emit(null); // No admin found
      }
    } catch (e) {
      print("Error fetching admin for agency $agencyID: $e");
      emit(null); // Emit null on error
    } finally {
      isLoading = false;
    }
  }
}