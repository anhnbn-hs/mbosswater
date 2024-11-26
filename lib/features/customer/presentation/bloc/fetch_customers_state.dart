import 'package:mbosswater/features/customer/domain/entity/customer_entity.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';

abstract class FetchCustomersState {}

class FetchCustomersInitial extends FetchCustomersState {}

class FetchCustomersLoading extends FetchCustomersState {}

class FetchCustomersSuccess extends FetchCustomersState {
  final List<Customer> customers;

  FetchCustomersSuccess(this.customers);
}

class FetchCustomersAgencySuccess extends FetchCustomersState {
  final List<CustomerEntity> originalCustomers; // Danh sách gốc
  final List<CustomerEntity> filteredCustomers; // Danh sách đã lọc

  FetchCustomersAgencySuccess(this.originalCustomers, [this.filteredCustomers = const []]);

  FetchCustomersAgencySuccess copyWith({
    List<CustomerEntity>? filteredCustomers,
  }) {
    return FetchCustomersAgencySuccess(
      originalCustomers,
      filteredCustomers ?? this.filteredCustomers,
    );
  }
}

class FetchCustomersError extends FetchCustomersState {
  String error;

  FetchCustomersError(this.error);
}
