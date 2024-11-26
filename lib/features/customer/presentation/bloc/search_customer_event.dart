abstract class CustomerSearchEvent {}

class SearchAllCustomersByPhone extends CustomerSearchEvent {
  final String query;

  SearchAllCustomersByPhone(this.query);
}

class SearchAgencyCustomersByPhone extends CustomerSearchEvent {
  final String query;
  final String agencyID;

  SearchAgencyCustomersByPhone(this.query, this.agencyID);
}
