import 'package:mbosswater/features/customer_care/bloc/cycle_bloc.dart';

abstract class CycleState {}

class CycleInitial extends CycleState {}

class CycleLoading extends CycleState {}

class CycleLoaded extends CycleState {
  final List<GuaranteeDateModel> guaranteesDate;

  CycleLoaded(this.guaranteesDate);
}

class CycleError extends CycleState {
  final String error;

  CycleError(this.error);
}

