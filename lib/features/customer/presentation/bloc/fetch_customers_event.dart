abstract class FetchCustomersEvent {}

class FetchAllCustomers extends FetchCustomersEvent {}

class SearchCustomers extends FetchCustomersEvent {
  final String query;

  SearchCustomers(this.query);
}

class FetchAllCustomersByAgency extends FetchCustomersEvent {
  final String agency;

  FetchAllCustomersByAgency(this.agency);
}
