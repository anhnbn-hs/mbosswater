import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

// States
abstract class FetchGuaranteeState {}

class FetchGuaranteeInitial extends FetchGuaranteeState {}

class FetchGuaranteeLoading extends FetchGuaranteeState {}

class FetchGuaranteeLoaded extends FetchGuaranteeState {
  final Guarantee guarantee;

  FetchGuaranteeLoaded(this.guarantee);
}

class FetchGuaranteeError extends FetchGuaranteeState {
  final String message;

  FetchGuaranteeError(this.message);
}

// Cubit
class FetchGuaranteeByIdCubit extends Cubit<FetchGuaranteeState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FetchGuaranteeByIdCubit() : super(FetchGuaranteeInitial());

  Future<void> fetchGuaranteeById(String guaranteeId) async {
    emit(FetchGuaranteeLoading());

    try {
      final guaranteeDoc =
      await _firestore.collection('guarantees').doc(guaranteeId).get();

      if (!guaranteeDoc.exists) {
        throw Exception('Guarantee not found');
      }

      final guarantee = Guarantee.fromJson(guaranteeDoc.data()!);
      emit(FetchGuaranteeLoaded(guarantee));
    } catch (e) {
      emit(FetchGuaranteeError('Failed to fetch guarantee: $e'));
    }
  }
}