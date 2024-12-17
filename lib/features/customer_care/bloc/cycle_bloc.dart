import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

import 'cycle_event.dart';
import 'cycle_state.dart';

class GuaranteeDateModel {
  final DateTime dateTime;
  final List<Guarantee> guarantees;

  GuaranteeDateModel(this.dateTime, this.guarantees);
}

class CycleBloc extends Bloc<CycleEvent, CycleState> {
  CycleBloc() : super(CycleInitial()) {
    on<FetchQuarterlyCycles>(_onFetchQuarterlyCycles);
  }

  Future<void> _onFetchQuarterlyCycles(
      FetchQuarterlyCycles event, Emitter<CycleState> emit) async {
    emit(CycleLoading());

    DateTime startDate = DateTime(event.year, event.month - 3, 1);
    DateTime endDate = DateTime(event.year, event.month - 2, 0);

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('guarantees')
          .where('createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      Map<DateTime, List<Guarantee>> groupedGuarantees = {};

      for (var doc in snapshot.docs) {
        Guarantee guarantee =
        Guarantee.fromJson(doc.data() as Map<String, dynamic>);

        DateTime endDateParsed = guarantee.endDate;

        if (endDateParsed.isAfter(endDate) ||
            endDateParsed.isAtSameMomentAs(endDate)) {
          DateTime onlyDate = DateTime(
            event.year,
            event.month,
            guarantee.createdAt.toDate().day,
          );

          // Nhóm guarantee theo ngày
          if (groupedGuarantees.containsKey(onlyDate)) {
            groupedGuarantees[onlyDate]!.add(guarantee);
          } else {
            groupedGuarantees[onlyDate] = [guarantee];
          }
        }
      }

      // Chuyển Map thành List<GuaranteeDateModel>
      List<GuaranteeDateModel> results = groupedGuarantees.entries
          .map((entry) => GuaranteeDateModel(entry.key, entry.value))
          .toList();

      emit(CycleLoaded(results));
    } catch (e) {
      emit(CycleError("Lỗi khi truy vấn guarantees: $e"));
    }
  }
}

