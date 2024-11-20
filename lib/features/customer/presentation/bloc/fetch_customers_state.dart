import 'package:mbosswater/features/guarantee/data/model/customer.dart';

abstract class FetchCustomersState {}

class FetchCustomersInitial extends FetchCustomersState {}

class FetchCustomersLoading extends FetchCustomersState {}

class FetchCustomersSuccess extends FetchCustomersState {
  final List<Customer> customer;

  FetchCustomersSuccess(this.customer);
}

class FetchCustomersError extends FetchCustomersState {}
