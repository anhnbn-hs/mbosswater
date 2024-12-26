abstract class FetchCustomersPaginateEvent {}

class FetchCustomers extends FetchCustomersPaginateEvent {
  final int limit;

  final String? provinceFilter;
  final String? dateFilter;
  final String? searchQuery;
  final String? agencyID;

  FetchCustomers({
    required this.limit,
    this.provinceFilter,
    this.dateFilter,
    this.searchQuery,
    this.agencyID,
  });
}

class FetchNextPage extends FetchCustomersPaginateEvent {
  final int limit;

  FetchNextPage(this.limit);
}
