import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/mboss/domain/repository/mboss_manager_repository.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class FetchAgenciesBloc extends Cubit<List<Agency>> {
  final MbossManagerRepository repository;

  bool isLoading = false;
  List<Agency> _allAgency = [];

  FetchAgenciesBloc(this.repository) : super([]);

  List<Agency> get getAgenciesOriginal => _allAgency;

  Future<void> fetchAllAgencies() async {
    if (isLoading) return;
    isLoading = true;
    emit([]);

    try {
      final agencies = await repository.fetchAgencies();
      _allAgency = agencies;
      emit(agencies);
    } catch (e) {
      print("Error fetching Agencies: $e");
    } finally {
      isLoading = false;
    }
  }

  void searchAgency(String query) {
    if (query.isEmpty) {
      emit(_allAgency);
    } else {
      final filteredAgencies = _allAgency
          .where((agency) =>
              agency.name.toLowerCase().contains(query) ||
              agency.address!.displayAddress().toLowerCase().contains(query))
          .toList();
      emit(filteredAgencies);
    }
  }

  Future<UserModel?> fetchAdminOfAgency(String agencyID) async {
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    try {
      final userQuerySnapshot = await firebaseFirestore
          .collection("users")
          .where("agency", isEqualTo: agencyID)
          .where("role", isEqualTo: Roles.AGENCY_BOSS)
          .limit(1)
          .get();
      if (userQuerySnapshot.docs.isNotEmpty) {
        final userData = userQuerySnapshot.docs.first.data();
        final user = UserModel.fromJson(userData);
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching admin for agency $agencyID: $e");
      return null;
    }
  }
}
