import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/guarantee/data/model/commune.dart';
import 'package:mbosswater/features/guarantee/domain/usecase/address_usecase.dart';
import 'package:collection/collection.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/communes_bloc.dart';

class CommunesAgencyBloc extends Bloc<CommunesEvent, CommunesState> {
  final AddressUseCase addressUseCase;

  Commune? selectedCommune;
  List<Commune>? communes;

  CommunesAgencyBloc(this.addressUseCase) : super(CommunesInitial()) {
    on<FetchCommunes>((event, emit) async {
      emit(CommunesLoading());
      try {
        final communes = await addressUseCase.getCommunes(event.districtId);
        if (communes != null) {
          emit(CommunesLoaded(communes));
          this.communes = communes;
        } else {
          emit(CommunesError("Failed to fetch communes"));
        }
      } catch (e) {
        emit(CommunesError(e.toString()));
      }
    });

    on<SearchCommunes>((event, emit) async {
      if (communes == null || communes!.isEmpty) {
        emit(CommunesError("No provinces available to search"));
        return;
      }

      // Perform the search based on the query
      final filteredCommune = communes!
          .where((commune) => commune.name!.toLowerCase().contains(event.query.toLowerCase()))
          .toList();

      if (filteredCommune.isNotEmpty) {
        emit(CommunesLoaded(filteredCommune));
      } else {
        emit(CommunesError("No provinces match the search query"));
      }
    });
  }

  void selectCommune(Commune commune) {
    if (state is CommunesLoaded) {
      final currentState = state as CommunesLoaded;
      selectedCommune = commune;
      emit(CommunesLoaded(currentState.communes));
    }
  }


  void emitCommune(Commune commune){
    selectedCommune = commune;
    emit(CommunesInitial());
  }

  Commune? getCommuneByName(String name) {
    return communes?.firstWhereOrNull((p) => p.name == name);
  }

}
