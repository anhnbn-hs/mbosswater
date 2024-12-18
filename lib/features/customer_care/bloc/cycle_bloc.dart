import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/data/model/reminder.dart';

import 'cycle_event.dart';
import 'cycle_state.dart';

class GuaranteeDateModel {
  final DateTime dateTime;
  final List<Reminder> reminders;

  GuaranteeDateModel(this.dateTime, this.reminders);
}

class CycleBloc extends Bloc<CycleEvent, CycleState> {
  CycleBloc() : super(CycleInitial()) {
    on<FetchQuarterlyCycles>(_onFetchQuarterlyCycles);
  }

  QuerySnapshot? snapshot; // Cache for save reminders reminder snapshot

  Future<void> _onFetchQuarterlyCycles(
      FetchQuarterlyCycles event, Emitter<CycleState> emit) async {
    emit(CycleLoading());

    DateTime startDate = DateTime(event.year, event.month, 1);
    DateTime endDate = DateTime(event.year, event.month + 1, 0); // Last day of the month

    try {
      snapshot ??= await FirebaseFirestore.instance
          .collection('reminders')
          .where('reminderDates', isNotEqualTo: null) // Ensures the field exists
          .get();

      if(event.isFetchNew != null){
        if(event.isFetchNew == true){
          snapshot = await FirebaseFirestore.instance
              .collection('reminders')
              .where('reminderDates', isNotEqualTo: null) // Ensures the field exists
              .get();
        }
      }

      // Group reminders by the exact 'reminderDate'
      Map<DateTime, List<Reminder>> groupedReminders = {};

      for (var doc in snapshot!.docs) {
        Reminder reminder = Reminder.fromJson(doc.data() as Map<String, dynamic>, doc.id);

        // Filter relevant reminderDates for this month
        for (var reminderDateModel in reminder.reminderDates ?? []) {
          DateTime reminderDate = reminderDateModel.reminderDate.toDate();
          if (reminderDate.isAfter(startDate) && reminderDate.isBefore(endDate.add(const Duration(days: 1)))) {
            DateTime onlyDate = DateTime(reminderDate.year, reminderDate.month, reminderDate.day);

            // Group reminders by reminderDate
            if (groupedReminders.containsKey(onlyDate)) {
              groupedReminders[onlyDate]!.add(reminder);
            } else {
              groupedReminders[onlyDate] = [reminder];
            }
          }
        }
      }

      // Convert grouped data to List<GuaranteeDateModel>
      List<GuaranteeDateModel> results = groupedReminders.entries
          .map((entry) => GuaranteeDateModel(entry.key, entry.value))
          .toList();

      emit(CycleLoaded(results));
    } catch (e) {
      emit(CycleError("Lỗi khi truy vấn reminders: $e"));
    }
  }


}

