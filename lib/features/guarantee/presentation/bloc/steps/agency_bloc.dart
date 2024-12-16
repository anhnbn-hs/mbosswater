// Save state for step 1 - Product

import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/guarantee/data/model/agency.dart';
import 'package:mbosswater/features/guarantee/domain/usecase/agency_usecase.dart';

class AgencyBloc extends Cubit<AgencyState> {
  final AgencyUseCase useCase;
  Agency? selectedAgency;
  List<Agency> agencies = [];

  AgencyBloc(this.useCase) : super(AgencyInitial());

  // Fetch agency by ID
  Future<void> fetchAgency(String agencyID) async {
    try {
      emit(AgencyLoading()); // Emit loading state
      Agency agency = await useCase.getAgency(agencyID);

      emit(AgencyLoaded(agency));
    } catch (e) {
      emit(AgencyError(e.toString()));
    }
  }

  Future<void> fetchAgencies() async {
    try {
      emit(AgencyLoading()); // Emit loading state
      var agencies = await useCase.getAgencies();
      this.agencies = List.from(agencies);
      emit(AgenciesLoaded(agencies));
    } catch (e) {
      emit(AgencyError(e.toString())); // Emit error state
    }
  }

  void selectAgency(Agency agency) {
    final currentState = state;
    if (currentState is AgenciesLoaded) {
      selectedAgency = agency;
      emit(AgenciesLoaded(currentState.agencies));
    }
  }

  void searchAgency(String query) {
    final currentState = state;
    if (currentState is AgenciesLoaded) {
      final filteredAgencies = agencies.where((agency) {
        return agency.name.toLowerCase().contains(query.toLowerCase()) ||
            agency.id.toLowerCase().contains(query.toLowerCase());
      }).toList();

      emit(AgenciesLoaded(filteredAgencies));
    }
  }

  void reset() {
    emit(AgencyInitial());
  }
}

abstract class AgencyState {}

class AgencyInitial extends AgencyState {}

class AgencyLoading extends AgencyState {}

class AgencyLoaded extends AgencyState {
  final Agency agency;

  AgencyLoaded(this.agency);
}

class AgenciesLoaded extends AgencyState {
  final List<Agency> agencies;

  AgenciesLoaded(this.agencies);
}

class AgencyError extends AgencyState {
  final String error;

  AgencyError(this.error);
}
