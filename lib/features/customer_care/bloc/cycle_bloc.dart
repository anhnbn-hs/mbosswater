import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'cycle_event.dart';
import 'cycle_state.dart';

class CycleBloc extends Bloc<CycleEvent, CycleState> {
  CycleBloc() : super(CycleInitial()) {
    on<FetchValidCycleDates>(_onFetchValidCycleDates);
  }

  // Tính danh sách chu kỳ
  List<DateTime> _calculateQuarterlyCycles(
      DateTime createdAt, DateTime endDate) {
    List<DateTime> cycles = [];
    DateTime current = createdAt;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      cycles.add(current);
      current = DateTime(current.year, current.month + 3, current.day);
    }

    return cycles;
  }

  // Xử lý FetchValidCycleDates
  Future<void> _onFetchValidCycleDates(
      FetchValidCycleDates event, Emitter<CycleState> emit) async {
    try {
      emit(CycleLoading());

      // Tính các ngày chu kỳ
      List<DateTime> cycles =
          _calculateQuarterlyCycles(event.createdAt, event.endDate);

      // Tìm các ngày hợp lệ trong Firestore
      List<DateTime> validDates = [];

      for (DateTime cycle in cycles) {
        Timestamp startOfDay = Timestamp.fromDate(
            DateTime(cycle.year, cycle.month, cycle.day, 0, 0, 0));
        Timestamp endOfDay = Timestamp.fromDate(
            DateTime(cycle.year, cycle.month, cycle.day, 23, 59, 59));

        // Truy vấn Firestore trong khoảng ngày
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('guarantees')
            .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
            .where('createdAt', isLessThanOrEqualTo: endOfDay)
            .get();

        if (snapshot.docs.isNotEmpty) {
          validDates.add(cycle); // Ngày hợp lệ
        }
      }

      emit(CycleLoaded(validDates: validDates));
    } catch (e) {
      emit(CycleError(message: e.toString()));
    }
  }
}
