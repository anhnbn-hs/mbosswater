abstract class CustomerSearchEvent {}

class SearchCustomersByPhone extends CustomerSearchEvent {
  final String query;
  SearchCustomersByPhone(this.query);
}
