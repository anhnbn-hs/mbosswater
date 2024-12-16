import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/agency/data/agency_datasource.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class UpdateAgencyStaffBloc extends Cubit<bool> {
  final AgencyDatasource datasource;

  bool isLoading = false;

  UpdateAgencyStaffBloc(this.datasource) : super(false);

  Future<void> updateStaff(UserModel user) async {
    if (isLoading) return;
    isLoading = true;
    emit(false);
    try {
      await datasource.updateStaff(user);
      emit(true);
    } catch (e) {
      print("Error creating MBoss Staff: $e");
    } finally {
      isLoading = false;
    }
  }
}
