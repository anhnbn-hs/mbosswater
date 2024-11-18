abstract class CustomerGuaranteeEvent {}

class FetchCustomerGuarantees extends CustomerGuaranteeEvent {
  final String customerID;

  FetchCustomerGuarantees(this.customerID);
}
