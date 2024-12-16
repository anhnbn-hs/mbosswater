// provinces_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:mbosswater/features/guarantee/data/model/province.dart';
import 'package:mbosswater/features/guarantee/domain/usecase/address_usecase.dart';
import 'package:mbosswater/features/guarantee/presentation/bloc/address/provinces_bloc.dart';

class ProvincesAgencyBloc extends Bloc<ProvincesEvent, ProvincesState> {
  final AddressUseCase addressUseCase;

  Province? selectedProvince;
  List<Province>? provinces;

  ProvincesAgencyBloc(this.addressUseCase) : super(ProvincesInitial()) {
    on<FetchProvinces>((event, emit) async {
      emit(ProvincesLoading());
      try {
        final provinces = await addressUseCase.getProvinces();
        if (provinces != null) {
          emit(ProvincesLoaded(provinces));
          this.provinces = provinces;
        } else {
          emit(ProvincesError("Failed to fetch provinces"));
        }
      } catch (e) {
        emit(ProvincesError(e.toString()));
      }
    });

    on<SearchProvinces>((event, emit) async {
      if (provinces == null || provinces!.isEmpty) {
        emit(ProvincesError("No provinces available to search"));
        return;
      }

      // Perform the search based on the query
      final filteredProvinces = provinces!
          .where((province) =>
              province.name!.toLowerCase().contains(event.query.toLowerCase()))
          .toList();

      if (filteredProvinces.isNotEmpty) {
        emit(ProvincesLoaded(filteredProvinces));
      } else {
        emit(ProvincesError("No provinces match the search query"));
      }
    });
  }

  void selectProvince(Province province) {
    if (state is ProvincesLoaded) {
      final currentState = state as ProvincesLoaded;
      selectedProvince = province;
      emit(ProvincesLoaded(currentState.provinces));
    }
  }


  void emitProvincesFullList() {
    if (provinces != null) {
      emit(ProvincesLoaded(provinces!));
    }
  }

  Province? getProvinceByName(String name) {
    return provinces?.firstWhereOrNull((p) => p.name == name);
  }

}
