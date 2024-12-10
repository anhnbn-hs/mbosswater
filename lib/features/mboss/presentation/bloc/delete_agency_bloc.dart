import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/mboss/domain/repository/mboss_manager_repository.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class DeleteAgencyBloc extends Cubit<bool> {
  final MbossManagerRepository repository;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  bool isLoading = false;

  DeleteAgencyBloc(this.repository) : super(false);

  Future<void> deleteAgency({
    required Agency agency,
    required UserModel agencyAdmin,
  }) async {
    if (isLoading) return;
    isLoading = true;

    emit(false);
    try {
      await firebaseFirestore.runTransaction((transaction) async {
        final agencyRef = firebaseFirestore.collection('agency').doc(agency.id);

        transaction.update(agencyRef, {'isDelete': true});

        final userRef = await firebaseFirestore
            .collection("users")
            .where('agency', isEqualTo: agency.id)
            .get();

        for (final userDoc in userRef.docs) {
          final userRef = firebaseFirestore.collection("users").doc(userDoc.id);
          transaction.update(userRef, {
            "isDelete": true,
            "fcmToken": "",
            "phoneNumber": "",
            "email": "",
            "address": "",
          });
        }
      });

      emit(true);
    } catch (e) {
      print("Error deleting agency: $e");
      emit(false);
    } finally {
      isLoading = false;
    }
  }
}
