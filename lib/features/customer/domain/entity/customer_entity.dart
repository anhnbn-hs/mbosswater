import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';

class CustomerEntity {
  final Customer customer;
  final List<Guarantee> guarantees;

  CustomerEntity(this.customer, this.guarantees);
}
