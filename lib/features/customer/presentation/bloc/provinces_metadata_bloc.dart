
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ProvincesMetaDataEvent {}

class FetchProvincesMetaData extends ProvincesMetaDataEvent {}

class SearchProvincesMetaData extends ProvincesMetaDataEvent {
  String query;

  SearchProvincesMetaData(this.query);
}

// States
abstract class ProvincesMetaDataState {}

class ProvincesMetaDataInitial extends ProvincesMetaDataState {}

class ProvincesMetaDataLoading extends ProvincesMetaDataState {}

class ProvincesMetaDataLoaded extends ProvincesMetaDataState {
  final List<String> provinces;

  ProvincesMetaDataLoaded(this.provinces);
}

class ProvincesMetaDataError extends ProvincesMetaDataState {
  final String message;

  ProvincesMetaDataError(this.message);
}

class ProvincesMetadataBloc extends Bloc<ProvincesMetaDataEvent, ProvincesMetaDataState> {
  List<String>? provinces;

  ProvincesMetadataBloc() : super(ProvincesMetaDataInitial()) {
    on<FetchProvincesMetaData>((event, emit) async {
      emit(ProvincesMetaDataLoading());
      try {
        // Simulate a data fetch or use your repository/service here
        final fetchedProvinces = await getProvinces();
        provinces = fetchedProvinces;
        emit(ProvincesMetaDataLoaded(provinces!));
      } catch (e) {
        emit(ProvincesMetaDataError("Failed to load provinces: ${e.toString()}"));
      }
    });

    on<SearchProvincesMetaData>((event, emit) async {
      if (provinces == null || provinces!.isEmpty) {
        emit(ProvincesMetaDataError("No provinces available to search"));
        return;
      }

      // Perform the search based on the query
      final filteredProvinces = provinces!
          .where((province) =>
              province.toLowerCase().contains(event.query.toLowerCase()))
          .toList();

      if (filteredProvinces.isNotEmpty) {
        emit(ProvincesMetaDataLoaded(filteredProvinces));
      } else {
        emit(ProvincesMetaDataError("No provinces match the search query"));
      }
    });
  }

  Future<List<String>> getProvinces() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('metadata')
        .doc('provinces')
        .get();

    return List<String>.from(doc['provinces']);
  }


  void emitProvincesFullList() {
    if (provinces != null) {
      emit(ProvincesMetaDataLoaded(provinces!));
    }
  }
}
