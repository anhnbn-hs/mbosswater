abstract class FetchCustomerEvent {}

class FetchCustomerByProduct extends FetchCustomerEvent {
  final String productID;

  FetchCustomerByProduct(this.productID);
}

class FetchCustomerByPhoneNumber extends FetchCustomerEvent {
  final String phoneNumber;

  FetchCustomerByPhoneNumber(this.phoneNumber);
}
