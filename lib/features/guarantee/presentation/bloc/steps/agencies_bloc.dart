import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/guarantee/domain/usecase/agency_usecase.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/steps/agency_bloc.dart';

class AgenciesBloc extends Cubit<AgencyState> {
  final AgencyUseCase useCase;

  AgenciesBloc(this.useCase) : super(AgencyInitial());

  Future<void> fetchAgencies() async {
    try {
      emit(AgencyLoading());
      final agencies = await useCase.getAgencies();
      emit(AgenciesLoaded(agencies));
    } catch (e) {
      emit(AgencyError(e.toString())); // Emit error state
    }
  }

  void reset() {
    emit(AgencyInitial());
  }
}
