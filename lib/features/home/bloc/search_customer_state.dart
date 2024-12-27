import 'package:mbosswater/features/guarantee/data/model/customer.dart';

abstract class CustomerSearchState {}

class CustomerSearchInitial extends CustomerSearchState {}

class CustomerSearchLoading extends CustomerSearchState {}

class CustomerSearchLoaded extends CustomerSearchState {
  final List<Customer> customers;
  CustomerSearchLoaded(this.customers);
}

class CustomerSearchError extends CustomerSearchState {
  final String message;
  CustomerSearchError(this.message);
}