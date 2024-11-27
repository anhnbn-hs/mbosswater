abstract class FetchCustomerEvent {}

class FetchCustomerByProduct extends FetchCustomerEvent {
  final String productID;

  FetchCustomerByProduct(this.productID);
}
