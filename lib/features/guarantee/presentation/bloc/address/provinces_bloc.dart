// provinces_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mbosswater/features/guarantee/data/model/province.dart';
import 'package:mbosswater/features/guarantee/domain/usecase/address_usecase.dart';
import 'package:collection/collection.dart';

// Events
abstract class ProvincesEvent {}

class FetchProvinces extends ProvincesEvent {}

// States
abstract class ProvincesState {}

class ProvincesInitial extends ProvincesState {}

class ProvincesLoading extends ProvincesState {}

class ProvincesLoaded extends ProvincesState {
  final List<Province> provinces;

  ProvincesLoaded(this.provinces);
}

class ProvincesError extends ProvincesState {
  final String message;

  ProvincesError(this.message);
}

class ProvincesBloc extends Bloc<ProvincesEvent, ProvincesState> {
  final AddressUseCase addressUseCase;

  String? selectedProvince;

  ProvincesBloc(this.addressUseCase) : super(ProvincesInitial()) {
    on<FetchProvinces>((event, emit) async {
      emit(ProvincesLoading());
      try {
        final provinces = await addressUseCase.getProvinces();
        if (provinces != null) {
          emit(ProvincesLoaded(provinces));
        } else {
          emit(ProvincesError("Failed to fetch provinces"));
        }
      } catch (e) {
        emit(ProvincesError(e.toString()));
      }
    });
  }

  String? getProvinceIDByName(String province) {
    if (state is ProvincesLoaded) {
      final provinces = (state as ProvincesLoaded).provinces;
      try {
        return provinces
            .firstWhereOrNull((p) => p.name == selectedProvince)
            ?.id;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
