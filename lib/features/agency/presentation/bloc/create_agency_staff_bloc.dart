import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/agency/data/agency_datasource.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class CreateAgencyStaffBloc extends Cubit<bool> {
  final AgencyDatasource datasource;

  bool isLoading = false;

  CreateAgencyStaffBloc(this.datasource) : super(false);

  Future<void> createStaff(UserModel user) async {
    if (isLoading) return;
    isLoading = true;
    emit(false);

    try {
      await datasource.createStaff(user);
      emit(true);
    } catch (e) {
      print("Error creating MBoss Staff: $e");
    } finally {
      isLoading = false;
    }
  }
}
