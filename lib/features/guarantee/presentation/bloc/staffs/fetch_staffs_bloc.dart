import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/core/constants/roles.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

abstract class FetchStaffsState{}
class FetchStaffsInitial extends FetchStaffsState {}
class FetchStaffsLoading extends FetchStaffsState {}
class FetchStaffsSuccess extends FetchStaffsState {
  final List<UserModel> users;

  FetchStaffsSuccess(this.users);

}
class FetchStaffsError extends FetchStaffsState {}

class FetchStaffsCubit extends Cubit<FetchStaffsState> {
  FetchStaffsCubit() : super(FetchStaffsInitial());

  UserModel? selectedUser;
  List<UserModel> users = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> fetchAllStaffsForMBoss() async {
    emit(FetchStaffsLoading());

    try {
      final querySnapshot = await firestore.collection('users')
          .where("role", isNotEqualTo: Roles.MBOSS_ADMIN)
          .get();

      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel.fromJson(data);
      }).toList();
      this.users = List.from(users);
      emit(FetchStaffsSuccess(users));
    } catch (e) {
      emit(FetchStaffsError());
    }
  }

  Future<void> fetchAllStaffsForAnyone() async {
    emit(FetchStaffsLoading());

    try {
      final querySnapshot = await firestore.collection('users')
          .where("role", whereNotIn: [Roles.MBOSS_ADMIN, Roles.AGENCY_BOSS])
          .get();

      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel.fromJson(data);
      }).toList();
      this.users = List.from(users);
      emit(FetchStaffsSuccess(users));
    } catch (e) {
      emit(FetchStaffsError());
    }
  }

  void selectUser(UserModel user) {
    final currentState = state;
    if (currentState is FetchStaffsSuccess) {
      selectedUser = user;
      emit(FetchStaffsSuccess(currentState.users));
    }
  }

  void searchUser(String query) {
    final currentState = state;
    if (currentState is FetchStaffsSuccess) {
      final filteredUsers = users.where((user) {
        return user.fullName!.toLowerCase().contains(query.toLowerCase()) ||
            user.phoneNumber!.toLowerCase().contains(query.toLowerCase());
      }).toList();

      emit(FetchStaffsSuccess(filteredUsers));
    }
  }

  void reset() {
    selectedUser = null;
    users = [];
    emit(FetchStaffsInitial());
  }
}