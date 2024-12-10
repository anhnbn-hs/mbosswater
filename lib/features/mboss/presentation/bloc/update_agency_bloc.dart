import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/mboss/domain/repository/mboss_manager_repository.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class UpdateAgencyBloc extends Cubit<bool> {
  final MbossManagerRepository repository;

  bool isLoading = false;

  UpdateAgencyBloc(this.repository) : super(false);

  Future<void> updateAgency({
    required Agency agency,
    required UserModel user,
  }) async {
    if (isLoading) return;
    isLoading = true;
    emit(false);

    try {
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      await firebaseFirestore.runTransaction((transaction) async {
        // Reference to the existing agency document
        final agencyRef = firebaseFirestore.collection('agency').doc(agency.id);

        // Reference to the user document
        final userRef = firebaseFirestore.collection('users').doc(user.id);

        // Update agency data
        transaction.update(agencyRef, agency.toJson());

        // Update user data
        transaction.update(userRef, user.toJson());
      });

      emit(true);
    } catch (e) {
      print("Error updating agency: $e");
    } finally {
      isLoading = false;
    }
  }

}
