abstract class CycleEvent {}

class FetchValidCycleDates extends CycleEvent {
  final DateTime createdAt;
  final DateTime endDate;

  FetchValidCycleDates({required this.createdAt, required this.endDate});
}
