// districts_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:mbosswater/features/guarantee/data/model/district.dart';
import 'package:mbosswater/features/guarantee/domain/usecase/address_usecase.dart';
import 'package:collection/collection.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/districts_bloc.dart';


class DistrictsAgencyBloc extends Bloc<DistrictsEvent, DistrictsState> {
  final AddressUseCase addressUseCase;

  District? selectedDistrict;

  List<District>? districts;

  DistrictsAgencyBloc(this.addressUseCase) : super(DistrictsInitial()) {
    on<FetchDistricts>((event, emit) async {
      emit(DistrictsLoading());
      try {
        final districts = await addressUseCase.getDistricts(event.provinceId);
        if (districts != null) {
          emit(DistrictsLoaded(districts));
          this.districts = districts;
        } else {
          emit(DistrictsError("Failed to fetch districts"));
        }
      } catch (e) {
        emit(DistrictsError(e.toString()));
      }
    });

    on<SearchDistrict>((event, emit) async {
      if (districts == null || districts!.isEmpty) {
        emit(DistrictsError("No provinces available to search"));
        return;
      }

      // Perform the search based on the query
      final filteredDistrict = districts!
          .where((district) => district.name!.toLowerCase().contains(event.query.toLowerCase()))
          .toList();

      if (filteredDistrict.isNotEmpty) {
        emit(DistrictsLoaded(filteredDistrict));
      } else {
        emit(DistrictsError("No provinces match the search query"));
      }
    });
  }

  void selectDistrict(District district){
    if(state is DistrictsLoaded){
      final currentState = state as DistrictsLoaded;
      selectedDistrict = district;
      emit(DistrictsLoaded(currentState.districts));
    }
  }


  void emitDistrict(District district){
    selectedDistrict = district;
    emit(DistrictsInitial());
  }

  District? getDistrictByName(String name) {
    return districts?.firstWhereOrNull((d) => d.name == name);
  }

}
