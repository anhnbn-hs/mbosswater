import 'package:mbosswater/features/customer/domain/entity/customer_entity.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';

abstract class FetchCustomerState {}

class FetchCustomerInitial extends FetchCustomerState {}

class FetchCustomerLoading extends FetchCustomerState {}

class FetchCustomerSuccess extends FetchCustomerState {
  final Customer customer;

  FetchCustomerSuccess(this.customer);
}


class FetchCustomerError extends FetchCustomerState {
  String error;

  FetchCustomerError(this.error);
}
