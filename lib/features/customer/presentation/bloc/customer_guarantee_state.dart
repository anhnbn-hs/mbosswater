import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

abstract class CustomerGuaranteeState {}

class CustomerGuaranteeInitial extends CustomerGuaranteeState {}

class CustomerGuaranteeLoading extends CustomerGuaranteeState {}

class CustomerGuaranteeLoaded extends CustomerGuaranteeState {
  final List<Guarantee> guarantees;

  CustomerGuaranteeLoaded(this.guarantees);
}

class CustomerGuaranteeError extends CustomerGuaranteeState {
  String message;

  CustomerGuaranteeError(this.message);
}
