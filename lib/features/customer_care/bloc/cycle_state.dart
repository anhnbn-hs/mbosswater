abstract class CycleState {}

class CycleInitial extends CycleState {}

class CycleLoading extends CycleState {}

class CycleLoaded extends CycleState {
  final List<DateTime> validDates;

  CycleLoaded({required this.validDates});
}

class CycleError extends CycleState {
  final String message;

  CycleError({required this.message});
}
