import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/guarantee/data/model/commune.dart';
import 'package:mbosswater/features/guarantee/domain/usecase/address_usecase.dart';

abstract class CommunesEvent {}

class FetchCommunes extends CommunesEvent {
  final String districtId;

  FetchCommunes(this.districtId);
}

abstract class CommunesState {}

class CommunesInitial extends CommunesState {}

class CommunesLoading extends CommunesState {}

class CommunesLoaded extends CommunesState {
  final List<Commune> communes;

  CommunesLoaded(this.communes);
}

class CommunesError extends CommunesState {
  final String message;

  CommunesError(this.message);
}

class CommunesBloc extends Bloc<CommunesEvent, CommunesState> {
  final AddressUseCase addressUseCase;

  String? selectedCommune;

  CommunesBloc(this.addressUseCase) : super(CommunesInitial()) {
    on<FetchCommunes>((event, emit) async {
      emit(CommunesLoading());
      try {
        final communes = await addressUseCase.getCommunes(event.districtId);
        if (communes != null) {
          emit(CommunesLoaded(communes));
        } else {
          emit(CommunesError("Failed to fetch communes"));
        }
      } catch (e) {
        emit(CommunesError(e.toString()));
      }
    });
  }

}
