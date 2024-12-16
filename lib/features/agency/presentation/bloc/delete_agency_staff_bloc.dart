import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/agency/data/agency_datasource.dart';
import 'package:mbosswater/features/mboss/domain/repository/mboss_manager_repository.dart';
import 'package:mbosswater/features/user_info/data/model/user_model.dart';

class DeleteAgencyStaffBloc extends Cubit<bool> {
  final AgencyDatasource datasource;


  bool isLoading = false;

  DeleteAgencyStaffBloc(this.datasource) : super(false);

  Future<void> deleteStaff(String id) async {
    if (isLoading) return;
    isLoading = true;
    emit(false);
    try {
      await datasource.deleteStaff(id);
      emit(true);
    } catch (e) {
      print("Error creating MBoss Staff: $e");
    } finally {
      isLoading = false;
    }
  }
}
