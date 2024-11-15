import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

abstract class ActiveGuaranteeState {}

class ActiveGuaranteeInitial extends ActiveGuaranteeState {}

class ActiveGuaranteeLoading extends ActiveGuaranteeState {}

class ActiveGuaranteeLoaded extends ActiveGuaranteeState {
  final Guarantee guarantees;
  final Customer customer;

  ActiveGuaranteeLoaded(this.guarantees, this.customer);
}

class ActiveGuaranteeError extends ActiveGuaranteeState {
  final String message;

  ActiveGuaranteeError(this.message);
}
