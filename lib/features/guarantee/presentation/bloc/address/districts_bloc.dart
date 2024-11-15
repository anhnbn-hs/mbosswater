// districts_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/guarantee/data/model/district.dart';
import 'package:mbosswater/features/guarantee/domain/usecase/address_usecase.dart';
import 'package:collection/collection.dart';

abstract class DistrictsEvent {}

class FetchDistricts extends DistrictsEvent {
  final String provinceId;

  FetchDistricts(this.provinceId);
}

abstract class DistrictsState {}

class DistrictsInitial extends DistrictsState {}

class DistrictsLoading extends DistrictsState {}

class DistrictsLoaded extends DistrictsState {
  final List<District> districts;

  DistrictsLoaded(this.districts);
}

class DistrictsError extends DistrictsState {
  final String message;

  DistrictsError(this.message);
}

class DistrictsBloc extends Bloc<DistrictsEvent, DistrictsState> {
  final AddressUseCase addressUseCase;

  String? selectedDistrict;

  DistrictsBloc(this.addressUseCase) : super(DistrictsInitial()) {
    on<FetchDistricts>((event, emit) async {
      emit(DistrictsLoading());
      try {
        final districts = await addressUseCase.getDistricts(event.provinceId);
        if (districts != null) {
          emit(DistrictsLoaded(districts));
        } else {
          emit(DistrictsError("Failed to fetch districts"));
        }
      } catch (e) {
        emit(DistrictsError(e.toString()));
      }
    });
  }

  String? getDistrictIDByName(String district) {
    if (state is DistrictsLoaded) {
      final districts = (state as DistrictsLoaded).districts;
      try {
        return districts
            .firstWhereOrNull(
              (p) => p.name == selectedDistrict,
            )
            ?.id;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
