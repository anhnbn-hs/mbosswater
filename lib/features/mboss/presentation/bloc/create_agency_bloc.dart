import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class CreateAgencyBloc extends Cubit<bool> {
  bool isLoading = false;

  CreateAgencyBloc() : super(false);

  Future<void> createAgency({
    required Agency agency,
    required UserModel boss,
  }) async {
    if (isLoading) return;
    isLoading = true;
    emit(false);

    try {
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      await firebaseFirestore.runTransaction((transaction) async {
        // Reference to the agency collection
        final agencyRef = firebaseFirestore.collection('agency').doc(agency.id);

        // Reference to the boss user collection
        final bossRef = firebaseFirestore.collection('users').doc(boss.id);

        // Add agency data
        transaction.set(agencyRef, agency.toJson());

        // Add boss data
        transaction.set(bossRef, boss.toJson());
      });

      emit(true);
    } catch (e) {
      print("Error creating MBoss Staff: $e");
    } finally {
      isLoading = false;
    }
  }
}
